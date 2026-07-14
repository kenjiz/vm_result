---
sidebar_position: 1
---

# Beginner's Tutorial: Build a Task Manager

In this step-by-step tutorial, we will build a complete **Task Manager** application in Flutter using `vm_result`. 

We will cover:
1. Fetching a list of tasks (Standard Async Fetching).
2. Adding a task immediately with a rollback fallback (Optimistic UI updates).
3. Displaying notification messages when tasks are added or fail (One-Shot UI Effects).

---

## The Setup

### 1. The Task Model
Create a file `task.model.dart`:

```dart
class Task {
  const Task({required this.id, required this.title, required this.isCompleted});

  final String id;
  final String title;
  final bool isCompleted;

  Task copyWith({String? id, String? title, bool? isCompleted}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
```

---

## The Business Logic

### 2. Defining UI Side Effects
We want to notify the user via a snackbar when a task is successfully saved or fails. Let's declare our UI effects:

```dart
import 'package:vm_result/vm_result.dart';

sealed class TaskUiEffect extends BaseUiEffect {
  const TaskUiEffect();
}

class ShowInfoSnackbar extends TaskUiEffect {
  const ShowInfoSnackbar(this.message);
  final String message;
}

class ShowErrorSnackbar extends TaskUiEffect {
  const ShowErrorSnackbar(this.error);
  final String error;
}
```

### 3. Creating the `TaskViewModel`
Our ViewModel will extend `VMResultEffect` to manage a list of tasks (`List<Task>`) and emit `TaskUiEffect` side effects.

Create a file `task_view_model.dart`:

```dart
import 'package:uuid/uuid.dart';
import 'package:vm_result/vm_result.dart';
import 'task.model.dart';
import 'task_effects.dart';

class TaskViewModel extends VMResultEffect<List<Task>, TaskUiEffect> {
  // Initialize with an empty list
  TaskViewModel() : super(const Result.initial());

  // Standard fetch showing loading spinner
  Future<void> fetchTasks() {
    return run(() async {
      await Future<void>.delayed(const Duration(seconds: 1.5)); // simulate delay
      return [
        const Task(id: '1', title: 'Buy groceries', isCompleted: false),
        const Task(id: '2', title: 'Write documentation', isCompleted: true),
      ];
    });
  }

  // Optimistic add task: adds locally immediately, rolls back on error
  Future<void> addTask(String title) {
    final currentTasks = state.value ?? [];
    
    // 1. Generate local optimistic task
    final newTask = Task(
      id: const Uuid().v4(), 
      title: title, 
      isCompleted: false,
    );
    final optimisticList = [...currentTasks, newTask];

    // 2. Wrap server request in runOptimistic
    return runOptimistic(
      optimisticState: optimisticList,
      action: () async {
        await Future<void>.delayed(const Duration(seconds: 1)); // simulate server latency

        // Simulate occasional API failure for titles containing "fail"
        if (title.toLowerCase().contains('fail')) {
          throw Exception('Server rejected task "$title".');
        }

        emitEffect(ShowInfoSnackbar('Task "$title" added successfully!'));
        return optimisticList; // Confirming the change
      },
    );
  }
}
```

---

## The View Layer

### 4. Creating the User Interface
Now, we bind the ViewModel to our widget tree. We will use:
- `ResultBuilder<List<Task>>` to rebuild the tasks list widget based on state changes.
- `EffectListener` to capture snackbars without interrupting the list state.

Create a file `task_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:vm_result/vm_result.dart';
import 'task.model.dart';
import 'task_view_model.dart';
import 'task_effects.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final TaskViewModel _viewModel;
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _viewModel = TaskViewModel();
    _inputController = TextEditingController();
    
    _viewModel.fetchTasks(); // Fetch tasks on startup
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reactive Task Manager')),
      body: EffectListener<TaskViewModel, List<Task>, TaskUiEffect>(
        vm: _viewModel,
        listener: (context, effect) {
          switch (effect) {
            case ShowInfoSnackbar(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.green,
                ),
              );
            case ShowErrorSnackbar(:final error):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 1. Task List Widget Area
              Expanded(
                child: ResultBuilder<List<Task>>(
                  listenable: _viewModel,
                  builder: (context, state, child) {
                    return state.when(
                      initial: () => const Center(child: Text('Press refresh')),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      data: (tasks) {
                        if (tasks.isEmpty) {
                          return const Center(child: Text('All caught up!'));
                        }
                        return ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return ListTile(
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (_) {},
                              ),
                              title: Text(task.title),
                            );
                          },
                        );
                      },
                      error: (exception) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: $exception', style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _viewModel.fetchTasks,
                            child: const Text('Retry Fetch'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              // 2. Input Box Area
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: 'Enter new task (type "fail" to trigger rollback)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final title = _inputController.text.trim();
                      if (title.isNotEmpty) {
                        _viewModel.addTask(title);
                        _inputController.clear();
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 5. Try it Out!

1. Compile and run the app.
2. The list will show a loading spinner for `1.5 seconds`, then render the two initial tasks.
3. Type a new task name (e.g. "Buy milk") and tap the send icon. Notice the task **instantly** appends to the list (thanks to `runOptimistic`) before the API delay completes.
4. Now type "fail task" and tap send. The task will instantly append. After 1 second, the API will fail, the task will **automatically disappear** from the list, and a red error snackbar will display.

This is the power of combining optimistic UI updates with automated rollback guards!
