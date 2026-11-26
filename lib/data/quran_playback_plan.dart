class QuranPlaybackStep {
  const QuranPlaybackStep(this.ayahIndex, {this.silenceSeconds = 0});
  final int ayahIndex;
  final int silenceSeconds;
  bool get isSilence => silenceSeconds > 0;
}

List<QuranPlaybackStep> buildQuranPlaybackPlan(
    {required int ayahCount,
    int firstAyah = 1,
    int? lastAyah,
    int repeats = 1,
    int pauseSeconds = 0}) {
  if (ayahCount <= 0) return [];
  final start = firstAyah.clamp(1, ayahCount);
  final end = (lastAyah ?? ayahCount).clamp(start, ayahCount);
  return [
    for (int ayah = start - 1; ayah < end; ayah++)
      for (int repeat = 0; repeat < repeats.clamp(1, 10); repeat++) ...[
        QuranPlaybackStep(ayah),
        if (pauseSeconds > 0 && repeat < repeats.clamp(1, 10) - 1)
          QuranPlaybackStep(ayah, silenceSeconds: pauseSeconds.clamp(0, 10)),
      ],
  ];
}
