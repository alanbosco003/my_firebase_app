import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_firebase_app/modules/auth/blocs/auth_bloc.dart';
import 'package:my_firebase_app/modules/todo/screens/todo_screen.dart';
import 'package:my_firebase_app/widgets/custom_button.dart';
import 'package:my_firebase_app/widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Sign Up"),
      ),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            showCupertinoDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                title: const Text("Error"),
                content: Text(state.error),
                actions: [
                  CupertinoDialogAction(
                    child: const Text("OK"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          }
          if (state is AuthSuccess) {
            // Navigate to To-Do List after successful signup
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (_) => const TodoScreen()),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextField(
                  controller: _emailController,
                  placeholder: "Email",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  placeholder: "Password",
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  placeholder: "Confirm Password",
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: "Sign Up",
                  isLoading: state is AuthLoading,
                  onPressed: () {
                    if (_passwordController.text.trim() !=
                        _confirmPasswordController.text.trim()) {
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: const Text("Error"),
                          content: const Text("Passwords do not match"),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text("OK"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    context.read<AuthBloc>().add(
                          SignUpRequested(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          ),
                        );
                  },
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  child: const Text("Already have an account? Login"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
