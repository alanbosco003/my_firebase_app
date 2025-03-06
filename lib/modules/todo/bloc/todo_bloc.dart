import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final FirebaseFirestore firestore;

  TodoBloc({required this.firestore}) : super(TodoInitial()) {
    on<SyncTasksEvent>(_syncTasks);
  }

  Future<void> _syncTasks(SyncTasksEvent event, Emitter<TodoState> emit) async {
    emit(TodoSyncInProgress());

    try {
      await firestore.collection('tasks').doc('user_tasks').set({
        'tasks': event.tasks,
      });

      emit(TodoSyncSuccess());
    } catch (e) {
      emit(TodoSyncFailure());
    }
  }
}
