# Offline Quran source data

Arabic Uthmani text, Saheeh International English translation, and Fateh Muhammad Jalandhari Urdu translation are fetched unmodified from AlQuran Cloud editions `quran-uthmani`, `en.sahih`, and `ur.jalandhry`.

The 548-page IndoPak 16-line word layout and IndoPak Nastaleeq text are fetched from Quran Foundation's Quran CDN, Mushaf 7. See https://api-docs.quran.com/docs/tutorials/fonts/page-layout/ and https://api-docs.quran.foundation/docs/tutorials/fonts/font-rendering/.

The compatible `IndopakNastaleeq-Regular.ttf` font is the unmodified IndoPak Nastaleeq waqf-lazim v4.2.1 font from the Quran Foundation font CDN (https://verses.quran.foundation/fonts/quran/hafs/nastaleeq/indopak/indopak-nastaleeq-waqf-lazim-v4.2.1.ttf). Attribution: IndoPak text and font contributors, Quran.com, QuranWBW and QUL/Tarteel.

`tool/bundle_quran_content.py` reproduces these compressed downloads and validates all 114 surahs, 6236 ayahs, 548 pages, line coordinates, and absence of duplicated word records. `manifest.json` records source URLs and SHA-256 hashes.

These downloads preserve their respective source attribution and rights. The app does not generate scripture or claim ownership of the text, translations, or font. Translations are interpretations; consult Arabic and qualified teachers for detailed study.
