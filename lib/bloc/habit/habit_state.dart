import 'package:equatable/equatable.dart';
import '../../models/habit.dart';
import '../../models/habit_entry.dart';

abstract class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object?> get props => [];
}

class HabitInitial extends HabitState {}

class HabitLoading extends HabitState {}

class HabitLoaded extends HabitState {
  final List<Habit> habits;
  final List<HabitEntry> habitEntries;
  final Map<String, HabitEntry> todayHabitEntries;

  const HabitLoaded({
    required this.habits,
    required this.habitEntries,
    required this.todayHabitEntries,
  });

  @override
  List<Object> get props => [habits, habitEntries, todayHabitEntries];
}

class HabitError extends HabitState {
  final String message;

  const HabitError(this.message);

  @override
  List<Object> get props => [message];
}

class HabitAdded extends HabitState {
  final Habit habit;

  const HabitAdded(this.habit);

  @override
  List<Object> get props => [habit];
}

class HabitUpdated extends HabitState {
  final Habit habit;

  const HabitUpdated(this.habit);

  @override
  List<Object> get props => [habit];
}

class HabitDeleted extends HabitState {
  final String habitId;

  const HabitDeleted(this.habitId);

  @override
  List<Object> get props => [habitId];
}

class HabitEntryToggled extends HabitState {
  final HabitEntry habitEntry;

  const HabitEntryToggled(this.habitEntry);

  @override
  List<Object> get props => [habitEntry];
}
