# Local-only PipoPay interceptor for mitmdump.
# No external backend. Emits only business lines for XXTE GUI.
import json, re, sys, time
from pathlib import Path
from urllib.parse import urlparse, parse_qs
import urllib.request, urllib.error

STATE = {}
DEBUG_LOG = Path(__file__).with_name('localpp_debug_flows.jsonl')

SENSITIVE_KEYS = re.compile(r'(?i)(token|cookie|session|authorization|passport|odin|email|mail|phone|card|name)')
EMAIL_RE = re.compile(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')


def emit(msg):
    print(msg, flush=True)

def redact(s):
    if not s:
        return ''
    s = EMAIL_RE.sub('<EMAIL>', s)
    s = re.sub(r'[A-Za-z0-9_-]{40,}', '<LONG>', s)
    s = re.sub(r'(?i)(token|cookie|session|authorization|passport|odin_tt|email|mail|phone|name)(["\'\s:=]+)[^"&\s,}]{3,}', r'\1\2<REDACTED>', s)
    return s[:8000]

def debug_flow(kind, flow, body=''):
    try:
        obj = {
            'ts': time.strftime('%H:%M:%S'),
            'kind': kind,
            'method': flow.request.method,
            'url': flow.request.pretty_url,
            'status': flow.response.status_code if getattr(flow, 'response', None) else None,
            'body': redact(body),
        }
        with DEBUG_LOG.open('a', encoding='utf-8', errors='ignore') as f:
            f.write(json.dumps(obj, ensure_ascii=False) + '\n')
    except Exception:
        pass


def get_text(obj):
    try:
        return obj.get_text(strict=False) or ''
    except Exception:
        return ''


def find_jsonish(text):
    if not text:
        return None
    # direct JSON
    try:
        return json.loads(text)
    except Exception:
        pass
    return None


def walk(obj, out):
    if isinstance(obj, dict):
        for k, v in obj.items():
            lk = str(k).lower()
            if lk in ('order_id','orderid','detail_id','merchant_id','merchant_user_id','payment_method','payment_type','status','pre_amount','amount','min_amount','max_amount','currency','brand','product_code','source','confirm_url','notify_url','cashier_url','amount_actual','currency_actual','token_amount'):
                out[lk] = v
            walk(v, out)
    elif isinstance(obj, list):
        for v in obj:
            walk(v, out)


def parse_initial_state_html(text):
    out = {}
    if not text:
        return out
    # cheap regex extraction from window.initialState HTML
    patterns = {
        'status': r'"status"\s*:\s*"([^"]+)"',
        'pre_amount': r'"pre_amount"\s*:\s*"?([0-9.]+)"?',
        'amount': r'"(?:cash_amount|amount)"\s*:\s*"?([0-9.]+)"?',
        'min_amount': r'"min_amount"\s*:\s*"?([0-9.]+)"?',
        'max_amount': r'"max_amount"\s*:\s*"?([0-9.]+)"?',
        'currency': r'"currency"\s*:\s*"([A-Z_]+)"',
        'payment_method': r'"payment_method"\s*:\s*"([^"]+)"',
        'payment_type': r'"payment_type"\s*:\s*"([^"]+)"',
        'brand': r'"brand"\s*:\s*"([^"]+)"',
        'product_code': r'"product_code"\s*:\s*"([^"]+)"',
        'source': r'"source"\s*:\s*"([^"]+)"',
        'merchant_id': r'"merchant_id"\s*:\s*"([^"]+)"',
        'merchant_user_id': r'"merchant_user_id"\s*:\s*"([^"]+)"',
    }
    for k,p in patterns.items():
        m = re.search(p, text)
        if m:
            out[k] = m.group(1)
    return out



def patch_response(flow, resp_text):
    """Match old Pipo behavior: preselect the minimum gift amount so user doesn't need manual denomination tap."""
    url = (flow.request.pretty_url or '').lower()
    if 'virtual/brand_detail_query' not in url or not resp_text:
        return resp_text, False
    try:
        data = json.loads(resp_text)
        products = (((data.get('data') or {}).get('product_info_list')) or [])
        if not products:
            return resp_text, False
        # Prefer 100 JPY / minimum valid product.
        chosen = 0
        for i, it in enumerate(products):
            if str(it.get('amount', '')).strip() == '100':
                chosen = i; break
        for i, it in enumerate(products):
            if isinstance(it, dict):
                it['default_check'] = (i == chosen)
        return json.dumps(data, ensure_ascii=False, separators=(',', ':')), True
    except Exception:
        return resp_text, False


def _http_call_url(url, label):
    try:
        headers = dict(STATE.get('_last_headers') or {})
        headers.setdefault('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148')
        headers.setdefault('Accept', 'application/json,text/plain,*/*')
        headers.setdefault('Referer', STATE.get('_last_referer') or STATE.get('cashier_url') or 'https://cashier-sg.pipopay.com/')
        req = urllib.request.Request(url, method='GET', headers=headers)
        with urllib.request.urlopen(req, timeout=20) as r:
            body = r.read(4096).decode('utf-8', 'replace')
            emit('%s: HTTP %s' % (label, getattr(r, 'status', '?')))
            return getattr(r, 'status', 0), body
    except urllib.error.HTTPError as e:
        body = e.read(4096).decode('utf-8', 'replace')
        emit('%s: HTTP %s' % (label, e.code))
        return e.code, body
    except Exception as e:
        emit('%s l?i: %s: %s' % (label, type(e).__name__, e))
        return 0, str(e)

def try_local_confirm(trigger=''):
    # Old pipo backend acts like a toll gate: after Pipo order is ORDERED, it calls LuckyCat confirm_url.
    # LocalPP does this locally using the confirm_url from initial-state. Do it once per order.
    order = STATE.get('order_id')
    url = STATE.get('confirm_url')
    if not order or not url or STATE.get('_confirm_called_for') == order:
        return
    STATE['_confirm_called_for'] = order
    emit('LocalPP confirm order: %s' % order)
    code, body = _http_call_url(url, 'LocalPP confirm')
    low = (body or '').lower()
    if code and code < 400 and any(x in low for x in ('success','ok','completed','ordered','0')):
        if not STATE.get('_emitted_success'):
            emit('R?t ti?n th?nh c?ng')
            STATE['_emitted_success'] = True
    try:
        obj = {'ts': time.strftime('%H:%M:%S'), 'kind': 'local_confirm', 'method': 'GET', 'url': url, 'status': code, 'body': redact(body)}
        with DEBUG_LOG.open('a', encoding='utf-8', errors='ignore') as f:
            f.write(json.dumps(obj, ensure_ascii=False) + '\n')
    except Exception:
        pass

def update_state(flow, req_text='', resp_text=''):
    url = flow.request.pretty_url
    host = flow.request.host or ''
    if not any(x in host for x in ('pipopay.com','polaris-sg-api.byteintl.net','giftee')):
        return
    p = urlparse(url)
    qs = {k: v[-1] for k, v in parse_qs(p.query).items() if v}
    info = {}
    for k in ('order_id','brand','currency','country_code','device_id'):
        if k in qs: info[k] = qs[k]
    if req_text:
        j = find_jsonish(req_text)
        if j is not None: walk(j, info)
    if resp_text:
        j = find_jsonish(resp_text)
        if j is not None: walk(j, info)
        info.update(parse_initial_state_html(resp_text))
    changed = False
    for k,v in info.items():
        if v not in (None,'') and STATE.get(k) != v:
            STATE[k] = v; changed = True
    if changed:
        order = STATE.get('order_id') or qs.get('order_id')
        if order and not STATE.get('_emitted_order'):
            emit('Phát hiện order: %s' % order)
            STATE['_emitted_order'] = True
        amt = STATE.get('pre_amount') or STATE.get('amount')
        cur = STATE.get('currency') or qs.get('currency') or ''
        mn = STATE.get('min_amount')
        mx = STATE.get('max_amount')
        if amt and not STATE.get('_emitted_fee'):
            extra = ''
            if mn or mx: extra = ' (min=%s max=%s)' % (mn or '?', mx or '?')
            emit('Tổng phí rút: %s %s%s' % (amt, cur, extra))
            STATE['_emitted_fee'] = True
    text = (req_text or '') + '\n' + (resp_text or '')
    m = EMAIL_RE.search(text)
    if m and not STATE.get('_emitted_mail'):
        emit('Phát hiện Mail Trong Pay: %s' % m.group(0))
        STATE['_emitted_mail'] = True
    low = text.lower()
    url_low = url.lower()
    # Do NOT treat Pipo ORDERED as final withdraw. It only means Pipo order created.
    # Final proof is visible confirm/callback/redeem/completed/success after LuckyCat/provider stage.
    final_path = any(x in url_low for x in ('confirm', 'callback', 'redeem', 'order/confirm'))
    final_success = any(x in low for x in ('withdraw_success','redeem_success','"status":"completed"','"status":"success"','"result_code":"success"'))
    if 'confirm_url' in STATE and 'order_id' in STATE and '"status":"ORDERED"'.lower() in low:
        try_local_confirm('ordered')
    if final_path and final_success and not STATE.get('_emitted_success'):
        emit('R?t ti?n th?nh c?ng')
        STATE['_emitted_success'] = True

def request(flow):
    host = flow.request.host or ''
    if any(x in host for x in ('pipopay.com','polaris-sg-api.byteintl.net','giftee')):
        req = get_text(flow.request)
        try:
            STATE['_last_headers'] = {k: v for k, v in flow.request.headers.items() if k.lower() in ('cookie','user-agent','x-tt-token','x-tt-trace-id','x-khronos','x-gorgon','x-ladon','x-argus','x-ss-stub','referer','origin','accept-language','accept')}
            STATE['_last_referer'] = flow.request.pretty_url
        except Exception:
            pass
        debug_flow('request', flow, req)
        update_state(flow, req, '')

def response(flow):
    host = flow.request.host or ''
    if any(x in host for x in ('pipopay.com','polaris-sg-api.byteintl.net','giftee')):
        req = get_text(flow.request)
        resp = get_text(flow.response) if flow.response else ''
        # Observe only; do not force UI denomination. Old Pipo withdraws full amount via capture path.
        debug_flow('response', flow, resp)
        update_state(flow, req, resp)
