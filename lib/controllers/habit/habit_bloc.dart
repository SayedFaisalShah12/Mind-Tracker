import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/habit.dart';
import '../../services/habit_service.dart';

// Events
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

class ToggleHabitEntry extends HabitEvent {
  final String habitId;
  final DateTime date;
  final bool completed;

  const ToggleHabitEntry({
    required this.habitId,
    required this.date,
    required this.completed,
  });

  @override
  List<Object> get props => [habitId, date, completed];
}

// States
abstract class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object?> get props => [];
}

class HabitInitial extends HabitState {}

class HabitLoading extends HabitState {}

class HabitLoaded extends HabitState {
  final List<Habit> habits;
  final Map<String, List<HabitEntry>> habitEntries;

  const HabitLoaded({
    required this.habits,
    required this.habitEntries,
  });

  @override
  List<Object> get props => [habits, habitEntries];
}

class HabitError extends HabitState {
  final String message;

  const HabitError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitService _habitService;

  HabitBloc({required HabitService habitService})
      : _habitService = habitService,
        super(HabitInitial()) {
    on<LoadHabits>(_onLoadHabits);
    on<AddHabit>(_onAddHabit);
    on<UpdateHabit>(_onUpdateHabit);
    on<DeleteHabit>(_onDeleteHabit);
    on<ToggleHabitEntry>(_onToggleHabitEntry);
  }

  Future<void> _onLoadHabits(
    LoadHabits event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(HabitLoading());
      final habits = await _habitService.getHabits();
      final habitEntries = await _habitService.getHabitEntries();
      emit(HabitLoaded(habits: habits, habitEntries: habitEntries));
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onAddHabit(
    AddHabit event,
    Emitter<HabitState> emit,
  ) async {
    try {
      await _habitService.addHabit(event.habit);
      add(LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onUpdateHabit(
    UpdateHabit event,
    Emitter<HabitState> emit,
  ) async {
    try {
      await _habitService.updateHabit(event.habit);
      add(LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onDeleteHabit(
    DeleteHabit event,
    Emitter<HabitState> emit,
  ) async {
    try {
      await _habitService.deleteHabit(event.habitId);
      add(LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onToggleHabitEntry(
    ToggleHabitEntry event,
    Emitter<HabitState> emit,
  ) async {
    try {
      await _habitService.toggleHabitEntry(
        event.habitId,
        event.date,
        event.completed,
      );
      add(LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }
}
