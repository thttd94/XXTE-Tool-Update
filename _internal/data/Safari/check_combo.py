import urllib.request
s=urllib.request.urlopen('http://127.0.0.1:8788/api/combo_lua?machine=114&t=1', timeout=5).read().decode('utf-8','replace')
print('StoreKit', 'StoreKit' in s)
print('WebKit.Networking', 'com.apple.WebKit.Networking' in s)
print('google_find', '*google*' in s)
i=s.find('local clear_targets')
print('idx', i)
print(s[i:i+1800])
