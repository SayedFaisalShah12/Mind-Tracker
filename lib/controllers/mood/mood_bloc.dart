import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/mood_entry.dart';
import '../../services/mood_service.dart';

// Events
abstract class MoodEvent extends Equatable {
  const MoodEvent();

  @override
  List<Object?> get props => [];
}

class LoadMoodEntries extends MoodEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadMoodEntries({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class AddMoodEntry extends MoodEvent {
  final MoodEntry moodEntry;

  const AddMoodEntry(this.moodEntry);

  @override
  List<Object> get props => [moodEntry];
}

class UpdateMoodEntry extends MoodEvent {
  final MoodEntry moodEntry;

  const UpdateMoodEntry(this.moodEntry);

  @override
  List<Object> get props => [moodEntry];
}

class DeleteMoodEntry extends MoodEvent {
  final String moodEntryId;

  const DeleteMoodEntry(this.moodEntryId);

  @override
  List<Object> get props => [moodEntryId];
}

// States
abstract class MoodState extends Equatable {
  const MoodState();

  @override
  List<Object?> get props => [];
}

class MoodInitial extends MoodState {}

class MoodLoading extends MoodState {}

class MoodLoaded extends MoodState {
  final List<MoodEntry> moodEntries;
  final MoodEntry? todayMood;

  const MoodLoaded({
    required this.moodEntries,
    this.todayMood,
  });

  @override
  List<Object?> get props => [moodEntries, todayMood];
}

class MoodError extends MoodState {
  final String message;

  const MoodError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final MoodService _moodService;

  MoodBloc({required MoodService moodService})
      : _moodService = moodService,
        super(MoodInitial()) {
    on<LoadMoodEntries>(_onLoadMoodEntries);
    on<AddMoodEntry>(_onAddMoodEntry);
    on<UpdateMoodEntry>(_onUpdateMoodEntry);
    on<DeleteMoodEntry>(_onDeleteMoodEntry);
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
      final todayMood = await _moodService.getTodayMood();
      emit(MoodLoaded(moodEntries: moodEntries, todayMood: todayMood));
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
      add(const LoadMoodEntries());
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
      add(const LoadMoodEntries());
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
      add(const LoadMoodEntries());
    } catch (e) {
      emit(MoodError(e.toString()));
    }
  }
}
