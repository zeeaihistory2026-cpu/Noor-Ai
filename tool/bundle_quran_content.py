"""Rebuild offline Quran text and the authentic 548-page IndoPak 16-line layout.

Only source text and layout fields are retained; no text is synthesized.
Run: python tool/bundle_quran_content.py
"""
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
import gzip
import hashlib
import json
import time
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets' / 'quran'
OUT.mkdir(parents=True, exist_ok=True)
CACHE = ROOT / 'build' / 'quran-source'
CACHE.mkdir(parents=True, exist_ok=True)


def fetch(url):
    for attempt in range(4):
        try:
            request = urllib.request.Request(url, headers={'User-Agent': 'MuslimGo/1.0', 'Accept': 'application/json'})
            with urllib.request.urlopen(request, timeout=25) as response:
                return json.load(response)
        except Exception:
            if attempt == 3:
                raise
            time.sleep(1 + attempt)


def page(number):
    cached = CACHE / f'{number}.json'
    if cached.exists():
        existing = json.loads(cached.read_text(encoding='utf-8'))
        if 'text_indopak_nastaleeq' in existing['verses'][0]['words'][0]:
            return number, existing
    verses = []
    page_index = 1
    while True:
        url = f'https://api.qurancdn.com/api/qdc/verses/by_page/{number}?mushaf=7&words=true&word_fields=line_number,text_indopak_nastaleeq,text_indopak,text_uthmani&per_page=50&page={page_index}'
        data = fetch(url)
        assert data.get('verses'), f'Empty page {number}'
        for verse in data['verses']:
            words = []
            for word in verse.get('words', []):
                if int(word.get('page_number', number)) != number:
                    continue
                assert 1 <= word['line_number'] <= 16
                assert word.get('text_indopak') or word.get('text_uthmani')
                words.append({key: word.get(key) for key in ['id', 'position', 'line_number', 'text_indopak_nastaleeq', 'text_indopak', 'text_uthmani', 'char_type_name', 'page_number']})
            if words:
                verses.append({'verse_key': verse['verse_key'], 'verse_number': verse['verse_number'], 'juz_number': verse['juz_number'], 'words': words})
        next_page = data.get('pagination', {}).get('next_page')
        if not next_page:
            break
        page_index = next_page
    assert verses, f'No words on page {number}'
    cached.write_text(json.dumps({'verses': verses}, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    return number, {'verses': verses}


def save(name, data):
    raw = json.dumps(data, ensure_ascii=False, separators=(',', ':')).encode()
    packed = gzip.compress(raw, mtime=0)
    (OUT / name).write_bytes(packed)
    return {'file': name, 'sha256': hashlib.sha256(packed).hexdigest(), 'bytes': len(packed)}


if __name__ == '__main__':
    artifacts = []
    for edition in ['quran-uthmani', 'en.sahih', 'ur.jalandhry']:
        data = fetch(f'https://api.alquran.cloud/v1/quran/{edition}')['data']
        assert len(data['surahs']) == 114
        assert sum(len(surah['ayahs']) for surah in data['surahs']) == 6236
        artifacts.append(save(f'{edition}.json.gz', data))
        print(f'Bundled {edition}: 114 surahs, 6236 ayahs', flush=True)
    pages = {}
    with ThreadPoolExecutor(max_workers=4) as pool:
        jobs = [pool.submit(page, number) for number in range(1, 549)]
        for job in as_completed(jobs):
            number, value = job.result()
            pages[str(number)] = value
            if len(pages) % 40 == 0:
                print(f'16-line pages: {len(pages)}/548', flush=True)
    assert len(pages) == 548
    verse_keys = {verse['verse_key'] for value in pages.values() for verse in value['verses']}
    assert len(verse_keys) == 6236, f'Unexpected coverage: {len(verse_keys)}'
    words = [(word['id'], verse['verse_key']) for value in pages.values() for verse in value['verses'] for word in verse['words']]
    assert len(words) == len(set(words)), 'Duplicated words between pages'
    artifacts.append(save('mushaf16.json.gz', {key: pages[key] for key in sorted(pages, key=int)}))
    (OUT / 'manifest.json').write_text(json.dumps({'sources': ['https://alquran.cloud/api', 'https://api-docs.quran.com/docs/tutorials/fonts/page-layout/', 'https://api.qurancdn.com/api/qdc'], 'mushaf': 7, 'pages': 548, 'verses': 6236, 'artifacts': artifacts}, indent=2), encoding='utf-8')
    print('Verified all 548 pages and all 6236 ayahs.', flush=True)
