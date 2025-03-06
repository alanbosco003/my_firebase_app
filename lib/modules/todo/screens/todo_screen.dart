import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_firebase_app/core/theme/theme_provider.dart';
import 'package:my_firebase_app/modules/auth/blocs/auth_bloc.dart';
import 'package:my_firebase_app/modules/todo/bloc/todo_bloc.dart';
import 'package:my_firebase_app/modules/todoDetails/taskDetailsScreen.dart';
import 'package:provider/provider.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    super.initState();
    final userId = (context.read<AuthBloc>().state as AuthSuccess).user.uid;
    context.read<TodoBloc>().add(FetchTasksEvent(userId: userId));
  }

  void _syncTasks(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      final userId = authState.user.uid;
      final todoBloc = context.read<TodoBloc>();
      if (todoBloc.state is TodoLoaded) {
        final tasks = (todoBloc.state as TodoLoaded).tasks;
        todoBloc.add(SyncTasksEvent(userId: userId, tasks: tasks));
      }
    }
  }

  void _showErrorPopup(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Upload Failed"),
        content: const Text("An error occurred while syncing tasks."),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(
      BuildContext context, int index, Map<String, String> task) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => TaskDetailsScreen(
          title: task["title"]!,
          details: task["details"]!,
          onUpdate: (updatedTitle, updatedDetails) {
            final updatedTask = {
              "title": updatedTitle,
              "details": updatedDetails
            };
            final todoBloc = context.read<TodoBloc>();
            if (todoBloc.state is TodoLoaded) {
              final updatedTasks = List<Map<String, String>>.from(
                  (todoBloc.state as TodoLoaded).tasks);
              updatedTasks[index] = updatedTask;
              todoBloc.add(SyncTasksEvent(
                userId:
                    (context.read<AuthBloc>().state as AuthSuccess).user.uid,
                tasks: updatedTasks,
              ));
            }
          },
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Logout"),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
    );
  }

  void _showAddTaskPopup(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController detailsController = TextEditingController();

    showCupertinoModalPopup(
      context: context,
      builder: (context) => AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: CupertinoActionSheet(
          title: const Text("Add New Task"),
          message: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoTextField(
                  controller: titleController,
                  placeholder: "Task Title",
                  padding: const EdgeInsets.all(12)),
              const SizedBox(height: 10),
              CupertinoTextField(
                  controller: detailsController,
                  placeholder: "Task Details",
                  padding: const EdgeInsets.all(12)),
            ],
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    detailsController.text.isNotEmpty) {
                  final newTask = {
                    "title": titleController.text,
                    "details": detailsController.text
                  };
                  final todoBloc = context.read<TodoBloc>();
                  if (todoBloc.state is TodoLoaded) {
                    final updatedTasks = List<Map<String, String>>.from(
                        (todoBloc.state as TodoLoaded).tasks);
                    updatedTasks.add(newTask);
                    todoBloc.add(SyncTasksEvent(
                      userId: (context.read<AuthBloc>().state as AuthSuccess)
                          .user
                          .uid,
                      tasks: updatedTasks,
                    ));
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text("Add Task"),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("To-do List"),
        leading: SizedBox(
          width: 90,
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showAddTaskPopup(context),
                child: const Icon(CupertinoIcons.add, size: 28),
              ),
              BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) => CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _syncTasks(context),
                  child: state is TodoSyncInProgress
                      ? const CupertinoActivityIndicator()
                      : const Icon(CupertinoIcons.cloud_upload),
                ),
              ),
            ],
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _confirmLogout(context),
          child: const Text("Logout",
              style: TextStyle(color: CupertinoColors.systemRed)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(CupertinoIcons.sun_max,
                      size: 24, color: CupertinoColors.systemYellow),
                  const SizedBox(width: 8),
                  CupertinoSwitch(
                    value: themeProvider.isDarkMode,
                    onChanged: (bool value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                  const SizedBox(width: 8),
                  Icon(CupertinoIcons.moon,
                      size: 24, color: CupertinoColors.systemGrey),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  if (state is TodoLoading)
                    return const Center(child: CupertinoActivityIndicator());
                  if (state is TodoLoaded) {
                    return state.tasks.isNotEmpty
                        ? CupertinoListSection.insetGrouped(
                            children: state.tasks
                                .asMap()
                                .entries
                                .map((entry) => CupertinoListTile(
                                      title: Text(entry.value["title"]!),
                                      trailing:
                                          const CupertinoListTileChevron(),
                                      onTap: () => _navigateToDetails(
                                          context, entry.key, entry.value),
                                    ))
                                .toList(),
                          )
                        : const Center(
                            child: Text("No tasks found",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: CupertinoColors.systemGrey)));
                  }
                  return const Center(child: Text(""));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
