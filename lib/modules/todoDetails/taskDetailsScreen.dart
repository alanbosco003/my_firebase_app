import 'package:flutter/cupertino.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String title;
  final String details;
  final Function(String, String) onUpdate; // ✅ Callback for updating

  const TaskDetailsScreen({
    super.key,
    required this.title,
    required this.details,
    required this.onUpdate,
  });

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late String title;
  late String details;

  @override
  void initState() {
    super.initState();
    title = widget.title;
    details = widget.details;
  }

  void _showEditPopup(BuildContext context) {
    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController detailsController =
        TextEditingController(text: details);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // ✅ Local setState for popup
          return AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: CupertinoActionSheet(
              title: const Text("Edit Task"),
              message: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoTextField(
                    controller: titleController,
                    placeholder: "Task Title",
                    padding: const EdgeInsets.all(12),
                    onChanged: (value) {
                      setDialogState(() {}); // ✅ Update local UI instantly
                    },
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: detailsController,
                    placeholder: "Task Details",
                    padding: const EdgeInsets.all(12),
                    onChanged: (value) {
                      setDialogState(() {}); // ✅ Update local UI instantly
                    },
                  ),
                ],
              ),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        detailsController.text.isNotEmpty) {
                      setState(() {
                        // ✅ Update main screen UI
                        title = titleController.text;
                        details = detailsController.text;
                      });

                      widget.onUpdate(title,
                          details); // ✅ Update the task in the previous screen

                      Navigator.pop(context); // ✅ Close popup
                    }
                  },
                  child: const Text("Save Changes"),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        previousPageTitle: "Back",
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showEditPopup(context), // ✅ Open edit popup
          child: const Icon(CupertinoIcons.pencil),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // ✅ Start from the top
            children: [
              Text(
                details,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
