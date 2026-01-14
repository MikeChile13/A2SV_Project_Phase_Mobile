import json
import os
import re

root = os.path.join(os.path.dirname(__file__), '..', 'assets', 'Bible-kjv-master')
books_path = os.path.join(root, 'Books.json')

with open(books_path, 'r', encoding='utf-8') as f:
    books = json.load(f)

missing = []
malformed = []

for name in books:
    fname = re.sub(r'[^0-9A-Za-z]', '', name) + '.json'
    fpath = os.path.join(root, fname)
    if not os.path.isfile(fpath):
        missing.append(fname)
        continue
    try:
        with open(fpath, 'r', encoding='utf-8') as bf:
            data = json.load(bf)
        chapters = data.get('chapters')
        if not isinstance(chapters, list):
            malformed.append((fname, 'chapters not a list'))
            continue
        # check at least one chapter with verses having text
        ok = False
        for ch in chapters:
            verses = ch.get('verses') if isinstance(ch, dict) else None
            if isinstance(verses, list) and len(verses)>0:
                if any(isinstance(v, dict) and 'text' in v for v in verses):
                    ok = True
                    break
        if not ok:
            malformed.append((fname, 'no verses/text found'))
    except Exception as e:
        malformed.append((fname, f'parse error: {e}'))

print('Checked', len(books), 'books')
print('Missing files:', len(missing))
for m in missing:
    print(' -', m)
print('Malformed files:', len(malformed))
for f, reason in malformed:
    print(' -', f, ':', reason)

if len(missing)==0 and len(malformed)==0:
    print('All files present and appear well-formed.')
else:
    print('See lists above.')
