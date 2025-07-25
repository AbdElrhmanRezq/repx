import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repx/data/models/user_model.dart';
import 'package:repx/data/providers/auth_providers.dart';
import 'package:repx/presentation/widgets/custom_text_form_field.dart';
import 'package:repx/presentation/widgets/custom_wide_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDataScreen extends ConsumerStatefulWidget {
  static const String id = 'user_data_screen';
  const UserDataScreen({super.key});

  @override
  ConsumerState<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends ConsumerState<UserDataScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController nameController = TextEditingController();
  String gender = "male";

  Future<void> processData() async {
    final auth = ref.read(authRepositoryProvider);
    final name = nameController.text.trim();

    ref.read(loginLoadingProvider.notifier).state = true;

    try {
      await auth.createUser(
        UserModel(
          email: auth.currentUser?.email ?? '',
          username: name,
          gender: gender,
          id: auth.currentUser?.id ?? '',
        ),
      );
      Navigator.of(context).pushReplacementNamed('nav_menu');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: ${e is AuthException ? e.message : e}'),
        ),
      );
    } finally {
      ref.read(loginLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authRepositoryProvider);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final isLoading = ref.watch(loginLoadingProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.015,
              ),
              child: Text(
                'Enter your data',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.02,
                vertical: height * 0.005,
              ),
              child: CustomTextFormField(
                labelText: "Name",
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: width * 0.39,
                    height: height * 0.2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gender == "male"
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          gender = "male";
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: height * 0.08),
                          Text('Male'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: width * 0.39,
                    height: height * 0.2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gender == "Else"
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          gender = "Else";
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: height * 0.08),
                          Text('Else'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.02,
                ),
                child: isLoading
                    ? CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      )
                    : CustomWideButton(
                        backgroundColor: Theme.of(context).primaryColor,
                        text: "Sign Up",
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            processData();
                          }
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
