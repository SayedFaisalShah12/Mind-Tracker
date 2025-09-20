import 'package:equatable/equatable.dart';
import '../../models/mood_entry.dart';

abstract class MoodState extends Equatable {
  const MoodState();

  @override
  List<Object?> get props => [];
}

class MoodInitial extends MoodState {}

class MoodLoading extends MoodState {}

class MoodLoaded extends MoodState {
  final List<MoodEntry> moodEntries;
  final MoodEntry? todayMoodEntry;

  const MoodLoaded({
    required this.moodEntries,
    this.todayMoodEntry,
  });

  @override
  List<Object?> get props => [moodEntries, todayMoodEntry];
}

class MoodError extends MoodState {
  final String message;

  const MoodError(this.message);

  @override
  List<Object> get props => [message];
}

class MoodEntryAdded extends MoodState {
  final MoodEntry moodEntry;

  const MoodEntryAdded(this.moodEntry);

  @override
  List<Object> get props => [moodEntry];
}

class MoodEntryUpdated extends MoodState {
  final MoodEntry moodEntry;

  const MoodEntryUpdated(this.moodEntry);

  @override
  List<Object> get props => [moodEntry];
}

class MoodEntryDeleted extends MoodState {
  final String moodEntryId;

  const MoodEntryDeleted(this.moodEntryId);

  @override
  List<Object> get props => [moodEntryId];
}
