import 'package:flutter/material.dart';
import '../../data/ai_service.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'ai_chat_screen.dart';

/// Page 26 — Voice AI Companion. Emerald header, "Speak your
/// question", large emerald listening circle with white waveform
/// bars, Listening… state, transcript pill, Try asking rows.
/// Tap circle toggles Listening / Tap to speak. Phase 9: stopping
/// a "listening" tap runs the design's sample transcript through
/// AiService (NoorAi -> LocalAiService) and shows the sample answer
/// labelled as such. TODO live: real speech-to-text + TTS — no
/// microphone is claimed to be listening yet.
class VoiceAiScreen extends StatefulWidget {
  const VoiceAiScreen({super.key});
  @override
  State<VoiceAiScreen> createState() => _VoiceAiScreenState();
}

class _VoiceAiScreenState extends State<VoiceAiScreen> {
  final AiService _ai = NoorAi();
  bool _listening = false;
  String? _sampleAnswer;

  Future<void> _toggleListening() async {
    final wasListening = _listening;
    setState(() => _listening = !_listening);
    // Stopping the (simulated) listening state resolves the sample
    // transcript through the AI service, honestly labelled sample.
    if (wasListening) {
      final answer = await _ai.ask(SampleData.voicePromptSample);
      if (!mounted) return;
      setState(() => _sampleAnswer = answer.text);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          Container(
            color: NoorColors.emeraldDark,
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 22),
            child: Row(children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 19),
                  onPressed: () => Navigator.of(context).maybePop()),
              Expanded(
                  child: Column(children: [
                Text('AI Companion',
                    style: NoorType.screenTitle.copyWith(color: Colors.white)),
                const SizedBox(height: 2),
                Text('Islamic Q&A · Sample answers (offline)',
                    style: NoorType.meta.copyWith(color: Colors.white70)),
              ])),
              IconButton(
                  tooltip: 'Voice options',
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  // Phase 16 audit: honest info + real text-chat route.
                  onPressed: () => showNoorOverflowSheet(context,
                      title: 'Voice companion',
                      info: const [
                        'Voice input is a demo in this version — the microphone is not connected. Type instead:',
                      ],
                      actions: [
                        (
                          Icons.chat_outlined,
                          'Open text chat',
                          () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const AiChatScreen()))
                        ),
                      ])),
            ]),
          ),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  children: [
                const Text('Speak your question',
                    style:
                        NoorType.screenTitle),
                const SizedBox(height: 26),
                Center(
                    child: Semantics(button: true, child: GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                      width: 232,
                      height: 232,
                      decoration: const BoxDecoration(
                          color: NoorColors.emeraldDark,
                          shape: BoxShape.circle,
                          boxShadow: NoorShadows.hero),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final h in [
                              26.0,
                              48.0,
                              64.0,
                              84.0,
                              56.0,
                              72.0,
                              36.0
                            ])
                              Container(
                                  width: 9,
                                  height: _listening ? h : 22,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(99))),
                          ])),
                ))),
                const SizedBox(height: 22),
                Center(
                    child: Text(_listening ? 'Listening...' : 'Tap to speak',
                        style: NoorType.cardTitle.copyWith(color: NoorColors.emeraldDark))),
                const SizedBox(height: 8),
                const Center(
                    child: Text('Self-check demo — microphone is not connected',
                        style: NoorType.meta)),
                if (_listening) ...[
                  const SizedBox(height: 12),
                  Center(
                      child: FilledButton.icon(
                    onPressed: _toggleListening,
                    icon: const Icon(Icons.stop, size: 18),
                    label: const Text('Stop'),
                    style: FilledButton.styleFrom(
                        backgroundColor: NoorColors.emeraldDark,
                        minimumSize: const Size(120, 44)),
                  )),
                ],
                const SizedBox(height: 18),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                        color: NoorColors.emeraldSoft,
                        borderRadius: BorderRadius.circular(28)),
                    child: Text(SampleData.voicePromptSample,
                        style:
                            NoorType.secondary.copyWith(color: NoorColors.ink))),
                if (_sampleAnswer != null) ...[
                  const SizedBox(height: 14),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: NoorColors.hairline)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sample answer (offline)',
                                style: NoorType.meta.copyWith(color: NoorColors.emeraldDark)),
                            const SizedBox(height: 6),
                            Text(_sampleAnswer!,
                                style: NoorType.secondary.copyWith(height: 1.5)),
                          ])),
                ],
                const SizedBox(height: 26),
                const Text('Try asking',
                    style:
                        NoorType.cardTitle),
                const SizedBox(height: 12),
                for (final s in SampleData.voiceSuggestions) ...[
                  Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const AiChatScreen())),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 17),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: NoorColors.hairline)),
                              child: Text(s,
                                  style: NoorType.body)))),
                  const SizedBox(height: 10),
                ],
                Row(children: [
                  const Icon(Icons.lock_outline, size: 15, color: NoorColors.muted),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(
                          'Private mode: voice sessions are not saved unless you choose.',
                          style: NoorType.meta.copyWith(color: NoorColors.muted)))
                ]),
              ])),
        ])),
      );
}
