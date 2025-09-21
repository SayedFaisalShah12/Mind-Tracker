import 'package:flutter_bloc/flutter_bloc.dart';
import 'habit_event.dart';
import 'habit_state.dart';
import '../../services/habit_service.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitService _habitService;

  HabitBloc({required HabitService habitService})
    : _habitService = habitService,
      super(HabitInitial()) {
    on<LoadHabits>(_onLoadHabits);
    on<AddHabit>(_onAddHabit);
    on<UpdateHabit>(_onUpdateHabit);
    on<DeleteHabit>(_onDeleteHabit);
    on<ToggleHabitActive>(_onToggleHabitActive);
    on<LoadHabitEntries>(_onLoadHabitEntries);
    on<ToggleHabitEntry>(_onToggleHabitEntry);
    on<GetHabitEntriesByDate>(_onGetHabitEntriesByDate);
  }

  Future<void> _onLoadHabits(LoadHabits event, Emitter<HabitState> emit) async {
    try {
      print('DEBUG: HabitBloc._onLoadHabits - Starting to load habits');
      emit(HabitLoading());
      final habits = await _habitService.getHabits();
      final habitEntries = await _habitService.getHabitEntries();
      final todayHabitEntries = await _habitService.getHabitEntriesByDate(
        DateTime.now(),
      );

      print('DEBUG: HabitBloc._onLoadHabits - Loaded ${habits.length} habits');
      print(
        'DEBUG: HabitBloc._onLoadHabits - Loaded ${habitEntries.length} habit entries',
      );
      print(
        'DEBUG: HabitBloc._onLoadHabits - Today habit entries: ${todayHabitEntries.length}',
      );

      emit(
        HabitLoaded(
          habits: habits,
          habitEntries: habitEntries,
          todayHabitEntries: todayHabitEntries,
        ),
      );
    } catch (e) {
      print('DEBUG: HabitBloc._onLoadHabits - Error: $e');
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onAddHabit(AddHabit event, Emitter<HabitState> emit) async {
    try {
      await _habitService.addHabit(event.habit);
      emit(HabitAdded(event.habit));

      // Reload habits to update the list
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
      emit(HabitUpdated(event.habit));

      // Reload habits to update the list
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
      emit(HabitDeleted(event.habitId));

      // Reload habits to update the list
      add(LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onToggleHabitActive(
    ToggleHabitActive event,
    Emitter<HabitState> emit,
  ) async {
    try {
      await _habitService.toggleHabitActive(event.habitId, event.isActive);

      // Reload habits to update the list
      add(LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onLoadHabitEntries(
    LoadHabitEntries event,
    Emitter<HabitState> emit,
  ) async {
    try {
      final habitEntries = await _habitService.getHabitEntries(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      if (state is HabitLoaded) {
        final currentState = state as HabitLoaded;
        emit(
          HabitLoaded(
            habits: currentState.habits,
            habitEntries: habitEntries,
            todayHabitEntries: currentState.todayHabitEntries,
          ),
        );
      }
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onToggleHabitEntry(
    ToggleHabitEntry event,
    Emitter<HabitState> emit,
  ) async {
    try {
      final habitEntry = await _habitService.toggleHabitEntry(
        event.habitId,
        event.date,
        event.completed,
        event.notes,
      );
      emit(HabitEntryToggled(habitEntry));

      // Reload habit entries to update the list
      add(LoadHabitEntries());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onGetHabitEntriesByDate(
    GetHabitEntriesByDate event,
    Emitter<HabitState> emit,
  ) async {
    try {
      final habitEntries = await _habitService.getHabitEntriesByDate(
        event.date,
      );

      if (state is HabitLoaded) {
        final currentState = state as HabitLoaded;
        emit(
          HabitLoaded(
            habits: currentState.habits,
            habitEntries: currentState.habitEntries,
            todayHabitEntries: habitEntries,
          ),
        );
      }
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }
}
