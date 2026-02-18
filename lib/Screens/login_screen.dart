import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nexus/Providers/user_provider.dart';
import 'package:nexus/Screens/sign_up_screen.dart';
import 'package:nexus/navigation_bar.dart';
import 'package:nexus/widgets/LoginAndSignUp/custom_input.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  String? errMsg;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ✅ Helper to safely convert Firestore Timestamps
  dynamic convertTimestamps(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    } else if (value is Map) {
      return value.map((key, val) => MapEntry(key, convertTimestamps(val)));
    } else if (value is List) {
      return value.map(convertTimestamps).toList();
    } else {
      return value;
    }
  }

  void showMessage(Color bgColor, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        dismissDirection: DismissDirection.down,
        backgroundColor: bgColor,
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 750) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: const Color.fromARGB(255, 19, 18, 40),
            body: Center(
              child: loginCard(
                context,
                screenWidth,
                screenWidth,
                errMsg,
                screenHeight,
                screenWidth,
                theme,
                textTheme,
              ),
            ),
          );
        }
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color.fromARGB(255, 19, 18, 40),
          body: Row(
            children: [
              SizedBox(
                width: screenWidth * 0.4,
                height: screenHeight,
                child: Center(
                  child: Image.asset("assets/LoginSignUpAssets/Logging_In.gif"),
                ),
              ),
              loginCard(
                context,
                screenWidth * 0.5,
                screenWidth * 0.3,
                errMsg,
                screenHeight,
                screenWidth,
                theme,
                textTheme,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget loginCard(
    BuildContext context,
    double width,
    double inputWidth,
    String? errorMsg,
    double screenHeight,
    double screenWidth,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return SizedBox(
      width: width,
      height: screenHeight,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 7, 9, 21),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Welcome Back", style: textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text("Sign in to your account", style: textTheme.labelMedium),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomInput(
                          ctrl: _emailController,
                          hintText: "Email",
                          width: inputWidth,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            }
                            if (!value.contains("@")) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomInput(
                          ctrl: _passwordController,
                          isPassField: true,
                          hintText: "Password",
                          width: inputWidth,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            child: Text(
                              "Forgot password?",
                              style: textTheme.labelSmall,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width:
                              screenWidth * 0.1 < 80 ? 100 : screenWidth * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                Colors.lightBlueAccent,
                                Colors.pinkAccent,
                              ],
                            ),
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  const WidgetStatePropertyAll(Colors.white),
                              backgroundColor:
                                  const WidgetStatePropertyAll(Colors.transparent),
                              shadowColor:
                                  const WidgetStatePropertyAll(Colors.transparent),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  final usr = await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  );

                                  final uid = usr.user!.uid;

                                  final userDocRef = FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(uid);

                                  await userDocRef.set({
                                    "lastLogin": FieldValue.serverTimestamp(),
                                    "email": _emailController.text.trim(),
                                  }, SetOptions(merge: true));

                                  final box = Hive.box("userBox");
                                  await box.put('uid', uid);
                                  await box.put(
                                    'email',
                                    _emailController.text.trim(),
                                  );
                                  await box.put('isLoggedIn', true);

                                  final userProvider =
                                      Provider.of<UserProvider>(
                                    context,
                                    listen: false,
                                  );
                                  await userProvider.setUserId(uid);

                                 
                                  if (!kIsWeb) {
                                    final userData = await userDocRef.get();
                                    final data = userData.data();

                                    if (data != null) {
                                      final cleanedData =
                                          convertTimestamps(data);
                                      await box.put('userProfile', cleanedData);
                                    }
                                  }

                                  if (!mounted) return;
                                  showMessage(
                                    Colors.lightGreen,
                                    "Welcome back!",
                                  );
                                  await Future.delayed(
                                    const Duration(seconds: 1),
                                  );
                                  if (!mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NavigationsBar(uid: uid),
                                    ),
                                  );
                                } on FirebaseAuthException catch (e) {
                                  debugPrint(e.message);
                                  setState(() {
                                    errMsg = e.message;
                                  });
                                  showMessage(
                                    Colors.red,
                                    e.message ?? "Login failed",
                                  );
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Login"),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          errorMsg ?? "",
                          style: const TextStyle(color: Colors.red),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have account? ",
                              style: textTheme.labelMedium,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              ),
                              child: Text(
                                "SignUp",
                                style: textTheme.labelMedium!.copyWith(
                                  color: Colors.lightBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
