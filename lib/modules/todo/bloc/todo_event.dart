part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// class SyncTasksEvent extends TodoEvent {
//   final List<Map<String, String>> tasks;
//   SyncTasksEvent({required this.tasks});

//   @override
//   List<Object> get props => [tasks];
// }

class SyncTasksEvent extends TodoEvent {
  final String userId; // Add user ID
  final List<Map<String, String>> tasks;

  SyncTasksEvent({required this.userId, required this.tasks});

  @override
  List<Object> get props => [userId, tasks];
}

class FetchTasksEvent extends TodoEvent {
  final String userId;

  FetchTasksEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}
