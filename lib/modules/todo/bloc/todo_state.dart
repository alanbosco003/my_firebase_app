part of 'todo_bloc.dart';

abstract class TodoState extends Equatable {
  @override
  List<Object> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Map<String, String>> tasks;

  TodoLoaded({required this.tasks});

  @override
  List<Object> get props => [tasks];
}

class TodoFailure extends TodoState {}

class TodoSyncInProgress extends TodoState {}

class TodoSyncSuccess extends TodoState {}

class TodoSyncFailure extends TodoState {}
