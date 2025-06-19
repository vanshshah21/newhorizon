import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController urlController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onNext;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.urlController,
    required this.usernameController,
    required this.passwordController,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onNext,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: urlController,
          decoration: const InputDecoration(hintText: "URL"),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(hintText: "Username"),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: "Password"),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(value: rememberMe, onChanged: onRememberMeChanged),
            const Text('Remember Me'),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isLoading ? null : onNext,
          child:
              isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text('Next'),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
// This widget is used to build the login form with fields for URL, username, and password.