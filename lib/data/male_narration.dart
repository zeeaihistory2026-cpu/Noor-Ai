import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'noor_store.dart';

class NarrationException implements Exception {
  const NarrationException(this.message);
  final String message;
}

abstract final class MaleNarration {
  static bool explicitlyFemale(Map voice) =>
      voice['gender']?.toString().trim().toLowerCase() == 'female' ||
      RegExp(r'\bfemale\b', caseSensitive: false)
          .hasMatch(voice['name']?.toString() ?? '');
  static bool explicitlyMale(Map voice) {
    final gender = voice['gender']?.toString().trim().toLowerCase();
    if (gender != null && gender.isNotEmpty) return gender == 'male';
    return RegExp(r'\bmale\b', caseSensitive: false)
        .hasMatch(voice['name']?.toString() ?? '');
  }

  static Future<Map<String, String>?> choose(
      BuildContext context, FlutterTts tts, String language,
      {bool force = false}) async {
    final prefix = language.split('-').first.toLowerCase();
    final raw = await tts.getVoices;
    final voices = (raw as List).whereType<Map>().where((voice) {
      final locale =
          voice['locale']?.toString().replaceAll('_', '-').toLowerCase() ?? '';
      return !explicitlyFemale(voice) &&
          voice['name'] != null &&
          (locale == prefix || locale.startsWith('$prefix-'));
    }).toList();
    if (voices.isEmpty) {
      throw const NarrationException(
          'No matching speech voice is installed. Add a voice in Android text-to-speech settings.');
    }
    final saved = force ? null : await NoorStore.getMaleNarrator(language);
    Map<String, String> asVoice(Map voice) => {
          'name': voice['name'].toString(),
          'locale': voice['locale'].toString()
        };
    if (saved != null &&
        voices.any((v) =>
            v['name'] == saved['name'] && v['locale'] == saved['locale'])) {
      return saved;
    }
    if (!force) {
      final male = voices.where(explicitlyMale).firstOrNull;
      if (male != null) {
        final voice = asVoice(male);
        await NoorStore.setMaleNarrator(language, voice);
        return voice;
      }
    }
    if (!context.mounted) return null;
    // Android engines often omit gender. Require an audition and explicit
    // selection instead of guessing from opaque voice IDs or changing pitch.
    int? selected;
    String? previewError;
    final heard = <int>{};
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
          builder: (context, update) => AlertDialog(
                title: const Text('Choose a male narrator'),
                content: SizedBox(
                    width: double.maxFinite,
                    height: 340,
                    child: Column(children: [
                      const Text(
                          'Preview the voices, then confirm a male voice for Hadith and Dua. Your choice is saved.'),
                      if (previewError != null)
                        Text(previewError!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      const SizedBox(height: 12),
                      Expanded(
                          child: ListView.builder(
                              itemCount: voices.length,
                              itemBuilder: (context, index) {
                                final voice = asVoice(voices[index]);
                                final locale = voice['locale']!;
                                return ListTile(
                                  selected: selected == index,
                                  leading: Icon(selected == index
                                      ? Icons.check_circle
                                      : Icons.volume_up_outlined),
                                  title: Text(
                                      '${prefix == 'ar' ? 'Arabic' : prefix == 'ur' ? 'Urdu' : 'English'} voice ${index + 1}'),
                                  subtitle: Text(locale),
                                  onTap: () async {
                                    try {
                                      await tts.stop();
                                      await tts.setVoice(voice);
                                      await tts.setPitch(1.0);
                                      await tts.setSpeechRate(0.4);
                                      final sample = prefix == 'ar'
                                          ? 'السلام عليكم. هذا مثال للصوت.'
                                          : prefix == 'ur'
                                              ? 'السلام علیکم۔ یہ آواز کا نمونہ ہے۔'
                                              : 'Assalamu alaikum. This is a voice preview.';
                                      final ok = await tts.speak(sample);
                                      if (!context.mounted) return;
                                      update(() {
                                        if (ok == 1) {
                                          selected = index;
                                          heard.add(index);
                                          previewError = null;
                                        } else {
                                          previewError =
                                              'This voice could not play. Try another voice.';
                                        }
                                      });
                                    } catch (_) {
                                      if (context.mounted) {
                                        update(() => previewError =
                                            'This voice could not play. Try another voice.');
                                      }
                                    }
                                  },
                                );
                              })),
                    ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: selected == null || !heard.contains(selected)
                          ? null
                          : () => Navigator.pop(
                              dialogContext, asVoice(voices[selected!])),
                      child: const Text('Use this male voice')),
                ],
              )),
    );
    await tts.stop();
    if (result != null) await NoorStore.setMaleNarrator(language, result);
    return result;
  }
}
