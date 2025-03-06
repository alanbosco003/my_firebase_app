import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final FirebaseFirestore firestore;

  TodoBloc({required this.firestore}) : super(TodoInitial()) {
    on<SyncTasksEvent>(_syncTasks);
    on<FetchTasksEvent>(_fetchTasks);
  }

  Future<void> _fetchTasks(
      FetchTasksEvent event, Emitter<TodoState> emit) async {
    emit(TodoLoading());

    try {
      final doc = await firestore.collection('tasks').doc(event.userId).get();

      if (doc.exists) {
        final Map<String, dynamic>? data = doc.data();

        if (data != null && data.containsKey('tasks')) {
          final List<dynamic> tasksList = data['tasks'] as List<dynamic>;

          final List<Map<String, String>> tasks = tasksList.map((task) {
            return {
              "title": task["title"]?.toString() ?? "", // Handle missing title
              "details":
                  task["details"]?.toString() ?? "", // Handle missing details
            };
          }).toList();

          emit(TodoLoaded(tasks: tasks));
        } else {
          emit(TodoLoaded(tasks: [])); // No tasks found
        }
      } else {
        emit(TodoLoaded(tasks: [])); // No document found
      }
    } catch (e) {
      print("Error fetching tasks: $e"); // Debugging
      emit(TodoFailure());
    }
  }

  // Future<void> _syncTasks(SyncTasksEvent event, Emitter<TodoState> emit) async {
  //   emit(TodoSyncInProgress());

  //   try {
  //     final Map<String, dynamic> tasksMap = {};
  //     for (int i = 0; i < event.tasks.length; i++) {
  //       tasksMap[i.toString()] = event.tasks[i]; // Convert list to map
  //     }

  //     await firestore.collection('tasks').doc(event.userId).set({
  //       'tasks': tasksMap,
  //     });

  //     emit(TodoSyncSuccess());
  //   } catch (e) {
  //     print("Error syncing tasks: $e"); // Debugging
  //     emit(TodoSyncFailure());
  //   }
  // }

  Future<void> _syncTasks(SyncTasksEvent event, Emitter<TodoState> emit) async {
    emit(TodoSyncInProgress());

    try {
      await firestore.collection('tasks').doc(event.userId).set({
        'tasks': event.tasks, // ✅ Store as a List, not a Map
      });

      // ✅ Fetch tasks immediately after syncing to update UI
      add(FetchTasksEvent(userId: event.userId));
    } catch (e) {
      print("Error syncing tasks: $e"); // Debugging
      emit(TodoSyncFailure());
    }
  }
}
