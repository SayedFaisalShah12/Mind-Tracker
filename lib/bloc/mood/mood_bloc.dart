import 'package:flutter_bloc/flutter_bloc.dart';
import 'mood_event.dart';
import 'mood_state.dart';
import '../../services/mood_service.dart';

class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final MoodService _moodService;

  MoodBloc({required MoodService moodService})
      : _moodService = moodService,
        super(MoodInitial()) {
    on<LoadMoodEntries>(_onLoadMoodEntries);
    on<AddMoodEntry>(_onAddMoodEntry);
    on<UpdateMoodEntry>(_onUpdateMoodEntry);
    on<DeleteMoodEntry>(_onDeleteMoodEntry);
    on<GetMoodEntryByDate>(_onGetMoodEntryByDate);
  }

  Future<void> _onLoadMoodEntries(
    LoadMoodEntries event,
    Emitter<MoodState> emit,
  ) async {
    try {
      emit(MoodLoading());
      final moodEntries = await _moodService.getMoodEntries(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      final todayMoodEntry = await _moodService.getMoodEntryByDate(DateTime.now());
      
      emit(MoodLoaded(
        moodEntries: moodEntries,
        todayMoodEntry: todayMoodEntry,
      ));
    } catch (e) {
      emit(MoodError(e.toString()));
    }
  }

  Future<void> _onAddMoodEntry(
    AddMoodEntry event,
    Emitter<MoodState> emit,
  ) async {
    try {
      await _moodService.addMoodEntry(event.moodEntry);
      emit(MoodEntryAdded(event.moodEntry));
      
      // Reload mood entries to update the list
      add(LoadMoodEntries());
    } catch (e) {
      emit(MoodError(e.toString()));
    }
  }

  Future<void> _onUpdateMoodEntry(
    UpdateMoodEntry event,
    Emitter<MoodState> emit,
  ) async {
    try {
      await _moodService.updateMoodEntry(event.moodEntry);
      emit(MoodEntryUpdated(event.moodEntry));
      
      // Reload mood entries to update the list
      add(LoadMoodEntries());
    } catch (e) {
      emit(MoodError(e.toString()));
    }
  }

  Future<void> _onDeleteMoodEntry(
    DeleteMoodEntry event,
    Emitter<MoodState> emit,
  ) async {
    try {
      await _moodService.deleteMoodEntry(event.moodEntryId);
      emit(MoodEntryDeleted(event.moodEntryId));
      
      // Reload mood entries to update the list
      add(LoadMoodEntries());
    } catch (e) {
      emit(MoodError(e.toString()));
    }
  }

  Future<void> _onGetMoodEntryByDate(
    GetMoodEntryByDate event,
    Emitter<MoodState> emit,
  ) async {
    try {
      final moodEntry = await _moodService.getMoodEntryByDate(event.date);
      if (state is MoodLoaded) {
        final currentState = state as MoodLoaded;
        emit(MoodLoaded(
          moodEntries: currentState.moodEntries,
          todayMoodEntry: moodEntry,
        ));
      }
    } catch (e) {
      emit(MoodError(e.toString()));
    }
  }
}
