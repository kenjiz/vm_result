import 'package:flutter/material.dart';
import 'package:vm_result/vm_result.dart';

void main() {
  runApp(const ExampleApp());
}

/// A simple user model for the example.
class UserProfile {
  const UserProfile({required this.name, required this.bio});
  final String name;
  final String bio;
}

/// A custom UI effect for our example app.
sealed class ProfileUiEffect extends BaseUiEffect {
  const ProfileUiEffect();
}

class ShowSnackbar extends ProfileUiEffect {
  const ShowSnackbar(this.message);
  final String message;
}

/// A ViewModel that manages user profile state.
class ProfileViewModel extends VMResultEffect<UserProfile, ProfileUiEffect> {
  ProfileViewModel()
    : super(
        const Result.data(
          UserProfile(name: 'Enrique Chua', bio: 'Flutter & Dart Developer'),
        ),
      );

  /// Simulates updating the user profile.
  Future<void> updateBio(String newBio) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Standard run guard showing loading spinner while saving
    await run(() async {
      await Future<void>.delayed(
        const Duration(seconds: 1),
      ); // simulate network

      // Simulate occasional error for demonstration
      if (newBio.toLowerCase().contains('error')) {
        throw Exception('Failed to update bio: Invalid keyword');
      }

      emitEffect(const ShowSnackbar('Bio updated successfully!'));
      return UserProfile(name: currentState.name, bio: newBio);
    });
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'vm_result Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: EffectListener<ProfileViewModel, UserProfile, ProfileUiEffect>(
        vm: _viewModel,
        listener: (context, effect) {
          switch (effect) {
            case ShowSnackbar(:final message):
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResultBuilder<UserProfile>(
                listenable: _viewModel,
                builder: (context, state, child) {
                  return state.when(
                    initial: () =>
                        const Center(child: Text('No profile loaded')),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    data: (user) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user.bio,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (error) => Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              error.toString(),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  _viewModel.updateBio(_bioController.text),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'New Biography',
                  border: OutlineInputBorder(),
                  helperText: 'Type "error" to simulate a network failure.',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _viewModel.updateBio(_bioController.text);
                  _bioController.clear();
                },
                child: const Text('Update Bio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
