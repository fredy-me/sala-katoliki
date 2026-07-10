import '../../../data/models/novena_model.dart';

class NovenaProgress {
  const NovenaProgress({
    required this.activeNovenaId,
    required this.completedDaysByNovenaId,
  });

  final String? activeNovenaId;
  final Map<String, Set<int>> completedDaysByNovenaId;

  bool get hasActiveNovena => activeNovenaId != null;

  Set<int> get completedDays {
    final activeId = activeNovenaId;
    if (activeId == null) {
      return const {};
    }
    return completedDaysFor(activeId);
  }

  Set<int> completedDaysFor(String novenaId) {
    return completedDaysByNovenaId[novenaId] ?? const {};
  }

  bool hasStarted(String novenaId) {
    return activeNovenaId == novenaId ||
        completedDaysByNovenaId.containsKey(novenaId);
  }

  int nextDayFor(String novenaId, int totalDays) {
    final completedDays = completedDaysFor(novenaId);
    if (completedDays.isEmpty) {
      return 1;
    }

    final maxCompleted = completedDays.reduce((a, b) => a > b ? a : b);
    return (maxCompleted + 1).clamp(1, totalDays);
  }

  double completionRatioFor(String novenaId, int totalDays) =>
      (completedDaysFor(novenaId).length / totalDays).clamp(0, 1);

  bool isCompleted(String novenaId, int day) {
    return completedDaysFor(novenaId).contains(day);
  }
}

enum NovenaDayStatus { completed, current, open, locked, notStarted }

class NovenaSession {
  const NovenaSession({required this.novena, required this.progress});

  final NovenaModel novena;
  final NovenaProgress progress;

  bool get isActive => progress.activeNovenaId == novena.id;

  bool get hasStarted => progress.hasStarted(novena.id);

  int get totalDays => novena.days.length;

  int get nextDay => progress.nextDayFor(novena.id, totalDays);

  double get completionRatio =>
      progress.completionRatioFor(novena.id, totalDays);

  NovenaDayStatus statusForDay(int day) {
    if (!hasStarted) {
      return day == 1 ? NovenaDayStatus.open : NovenaDayStatus.notStarted;
    }

    if (progress.isCompleted(novena.id, day)) {
      return NovenaDayStatus.completed;
    }

    if (day == nextDay) {
      return NovenaDayStatus.current;
    }

    if (day < nextDay) {
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
