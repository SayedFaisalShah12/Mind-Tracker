import 'package:equatable/equatable.dart';
import '../models/mood_entry.dart';

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

class GetMoodEntryByDate extends MoodEvent {
  final DateTime date;

  const GetMoodEntryByDate(this.date);

  @override
  List<Object> get props => [date];
}
