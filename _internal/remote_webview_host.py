import os
import sys
import time
import traceback
from pathlib import Path

_BASE_DIR = Path(sys.executable).resolve().parent if getattr(sys, 'frozen', False) else Path(__file__).resolve().parent
_FIXED_WEBVIEW2_DIR = _BASE_DIR / 'web2'
if not _FIXED_WEBVIEW2_DIR.exists():
    _FIXED_WEBVIEW2_DIR = _BASE_DIR / 'WebView2Runtime'
if _FIXED_WEBVIEW2_DIR.exists():
    # Microsoft WebView2 Fixed Version Runtime. pywebview/Edge reads this env var.
    os.environ.setdefault('WEBVIEW2_BROWSER_EXECUTABLE_FOLDER', str(_FIXED_WEBVIEW2_DIR))

def _host_log(msg):
    try:
        log_dir = _BASE_DIR / 'logs'
        log_dir.mkdir(parents=True, exist_ok=True)
        with open(log_dir / 'remote_webview_host.log', 'a', encoding='utf-8', errors='replace') as f:
            f.write(time.strftime('%Y-%m-%d %H:%M:%S') + ' ' + str(msg) + '\n')
    except Exception:
        pass

try:
    import webview
    _host_log('import webview OK fixed_runtime=' + str(_FIXED_WEBVIEW2_DIR if _FIXED_WEBVIEW2_DIR.exists() else 'NOT_FOUND'))
except Exception:
    _host_log('import webview FAILED: ' + traceback.format_exc())
    raise


def clean_ui(window):
    js = r'''
(function(){
  function apply(){
    if (!window.__oc_quality_patch) {
      window.__oc_quality_patch = true;
      try {
        if (window.jQuery && jQuery.fn && jQuery.fn.height) {
          var oldHeight = jQuery.fn.height;
          jQuery.fn.height = function() {
            if (this && this.length && this[0] === window && arguments.length === 0) {
              return (window.innerHeight || oldHeight.apply(this, arguments) || 0) + 100;
            }
            return oldHeight.apply(this, arguments);
          };
        }
      } catch(e) {}
      try {
        var desc = Object.getOwnPropertyDescriptor(HTMLImageElement.prototype, 'src');
        if (desc && desc.set && desc.get) {
          Object.defineProperty(HTMLImageElement.prototype, 'src', {
            get: desc.get,
            set: function(v) {
              if (typeof v === 'string' && v.indexOf('snapshot?') >= 0) {
                v = v.replace('compress=0.33', 'compress=0.45').replace('compress=0.92', 'compress=0.45').replace('zoom=1', 'zoom=1');
              }
              return desc.set.call(this, v);
            }
          });
        }
      } catch(e) {}
    }
    document.body.className = '';
    document.documentElement.style.margin='0';
    document.documentElement.style.padding='0';
    document.documentElement.style.overflow='hidden';
    document.documentElement.style.background='#000';
    document.body.style.margin='0';
    document.body.style.padding='0';
    document.body.style.overflow='hidden';
    document.body.style.background='#000';
    var hdr=document.querySelector('header'); if(hdr) hdr.style.display='none';
    var drawer=document.getElementById('main-drawer'); if(drawer) drawer.style.display='none';
    var wrap=document.querySelector('.mdui-container-fluid');
    if(wrap){
      wrap.style.position='fixed'; wrap.style.left='0'; wrap.style.top='0'; wrap.style.right='0'; wrap.style.bottom='0';
      wrap.style.width='100%'; wrap.style.height='100%'; wrap.style.margin='0'; wrap.style.padding='0';
      wrap.style.display='flex'; wrap.style.alignItems='center'; wrap.style.justifyContent='center';
      wrap.style.background='#000'; wrap.style.overflow='hidden';
    }
    var c=document.getElementById('all_canvas');
    if(c){
      c.style.position='static'; c.style.top='auto'; c.style.margin='0'; c.style.display='block';
      c.style.transform='none'; c.style.transformOrigin='center center';
      var ww = window.innerWidth || 1, wh = window.innerHeight || 1;
      var cw = c.width || c.naturalWidth || c.offsetWidth || 1;
      var ch = c.height || c.naturalHeight || c.offsetHeight || 1;
      var scale = Math.min(ww / cw, wh / ch);
      var fitW = Math.max(1, Math.floor(cw * scale));
      var fitH = Math.max(1, Math.floor(ch * scale));
      c.style.width = fitW + 'px';
      c.style.height = fitH + 'px';
      c.style.maxWidth = '100vw';
      c.style.maxHeight = '100vh';
    }
    var junk=document.querySelectorAll('.mdui-snackbar,.mdui-dialog,.mdui-overlay');
    for(var i=0;i<junk.length;i++){ junk[i].style.display='none'; }
  }
  apply();
  if(!window.__oc_clean_timer){ window.__oc_clean_timer=setInterval(apply, 1500); }
})();
'''
    for _ in range(4):
        try:
            window.evaluate_js(js)
        except Exception:
            pass
        time.sleep(0.6)


def main():
    if len(sys.argv) < 4:
        return 2
    title = sys.argv[1]
    url = sys.argv[2]
    _host_log(f'main title={title} url={url} argv={sys.argv}')
    try:
        width = int(sys.argv[3])
        height = int(sys.argv[4]) if len(sys.argv) > 4 else 700
    except Exception:
        width, height = 390, 700
    # Put the temporary top-level host off-screen first; Tk will embed/show it inside the assigned slot.
    window = webview.create_window(title, url, width=width, height=height, x=-32000, y=-32000, resizable=True, frameless=True, easy_drag=False)
    storage = str(_BASE_DIR / 'data' / 'remote_webview_cache')
    _host_log(f'create_window OK storage={storage}')
    try:
        webview.start(clean_ui, window, gui='edgechromium', debug=False, private_mode=False, storage_path=storage)
        _host_log('webview.start returned')
    except Exception:
        _host_log('webview.start FAILED: ' + traceback.format_exc())
        raise
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
