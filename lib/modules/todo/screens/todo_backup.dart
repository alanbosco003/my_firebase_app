import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_firebase_app/modules/auth/blocs/auth_bloc.dart';
import 'package:my_firebase_app/modules/todoDetails/taskDetailsScreen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Map<String, String>> _tasks = [
    {"title": "Buy Groceries", "details": "Milk, Bread, Eggs, and Fruits"},
    {"title": "Meeting with Team", "details": "Discuss project progress"},
    {"title": "Workout", "details": "1-hour gym session at 6 PM"},
    {"title": "Read a Book", "details": "Read 30 pages of a novel"},
  ];

  void _navigateToDetails(BuildContext context, int index) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => TaskDetailsScreen(
          title: _tasks[index]["title"]!,
          details: _tasks[index]["details"]!,
          onUpdate: (updatedTitle, updatedDetails) {
            setState(() {
              _tasks[index] = {
                "title": updatedTitle,
                "details": updatedDetails
              }; // ✅ Update task
            });
          },
        ),
      ),
    );
  }

  void _addTask(String title, String details) {
    setState(() {
      _tasks.add({"title": title, "details": details});
    });
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
              Navigator.pop(context); // Close dialog
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
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: detailsController,
                placeholder: "Task Details",
                padding: const EdgeInsets.all(12),
              ),
            ],
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    detailsController.text.isNotEmpty) {
                  _addTask(titleController.text,
                      detailsController.text); // ✅ Call main state function
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showAddTaskPopup(context),
          child: const Icon(CupertinoIcons.add, size: 28),
        ),
        middle: const Text("To-do List"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _confirmLogout(context),
              child: const Text(
                "Logout",
                style: TextStyle(color: CupertinoColors.systemRed),
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CupertinoListSection.insetGrouped(
          children: _tasks.asMap().entries.map((entry) {
            final int index = entry.key; // ✅ Get index
            final Map<String, String> task = entry.value; // ✅ Get task data

            return CupertinoListTile(
              title: Text(task["title"]!),
              trailing: const CupertinoListTileChevron(),
              onTap: () =>
                  _navigateToDetails(context, index), // ✅ Now index is defined
            );
          }).toList(),
        ),
      ),
    );
  }
}
