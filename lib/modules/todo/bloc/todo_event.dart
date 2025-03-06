part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SyncTasksEvent extends TodoEvent {
  final List<Map<String, String>> tasks;
  SyncTasksEvent({required this.tasks});

  @override
  List<Object> get props => [tasks];
}
