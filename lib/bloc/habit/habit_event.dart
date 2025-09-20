import 'package:equatable/equatable.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

class LoadHabits extends HabitEvent {}

class AddHabit extends HabitEvent {
  final Habit habit;

  const AddHabit(this.habit);

  @override
  List<Object> get props => [habit];
}

class UpdateHabit extends HabitEvent {
  final Habit habit;

  const UpdateHabit(this.habit);

  @override
  List<Object> get props => [habit];
}

class DeleteHabit extends HabitEvent {
  final String habitId;

  const DeleteHabit(this.habitId);

  @override
  List<Object> get props => [habitId];
}

class ToggleHabitActive extends HabitEvent {
  final String habitId;
  final bool isActive;

  const ToggleHabitActive(this.habitId, this.isActive);

  @override
  List<Object> get props => [habitId, isActive];
}

class LoadHabitEntries extends HabitEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadHabitEntries({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class ToggleHabitEntry extends HabitEvent {
  final String habitId;
  final DateTime date;
  final bool completed;
  final String? notes;

  const ToggleHabitEntry({
    required this.habitId,
    required this.date,
    required this.completed,
    this.notes,
  });

  @override
  List<Object?> get props => [habitId, date, completed, notes];
}

class GetHabitEntriesByDate extends HabitEvent {
  final DateTime date;

  const GetHabitEntriesByDate(this.date);

  @override
  List<Object> get props => [date];
}
