import '../../../data/models/novena_model.dart';

class NovenaProgress {
  const NovenaProgress({
    required this.activeNovenaId,
    required this.completedDays,
  });

  final String? activeNovenaId;
  final Set<int> completedDays;

  bool get hasActiveNovena => activeNovenaId != null;

  int get nextDay {
    if (completedDays.isEmpty) {
      return 1;
    }

    final maxCompleted = completedDays.reduce((a, b) => a > b ? a : b);
    return (maxCompleted + 1).clamp(1, 9);
  }

  double get completionRatio => (completedDays.length / 9).clamp(0, 1);

  bool isCompleted(int day) => completedDays.contains(day);
}

enum NovenaDayStatus { completed, current, open, locked, notStarted }

class NovenaSession {
  const NovenaSession({required this.novena, required this.progress});

  final NovenaModel novena;
  final NovenaProgress progress;

  bool get isActive => progress.activeNovenaId == novena.id;

  NovenaDayStatus statusForDay(int day) {
    if (progress.completedDays.contains(day)) {
      return NovenaDayStatus.completed;
    }

    if (!isActive) {
      return day == 1 ? NovenaDayStatus.open : NovenaDayStatus.notStarted;
    }

    if (day == progress.nextDay) {
      return NovenaDayStatus.current;
    }

    if (day < progress.nextDay) {
      return NovenaDayStatus.open;
    }

    return NovenaDayStatus.locked;
  }

  bool canOpenDay(int day) {
    return switch (statusForDay(day)) {
      NovenaDayStatus.completed ||
      NovenaDayStatus.current ||
      NovenaDayStatus.open => true,
      NovenaDayStatus.locked || NovenaDayStatus.notStarted => false,
    };
  }
}
