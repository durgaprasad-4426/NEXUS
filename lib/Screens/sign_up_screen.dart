import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus/Screens/login_screen.dart';
import 'package:nexus/widgets/LoginAndSignUp/custom_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool termsAccepted = false;

  void showMessage(Color bgColor, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: bgColor,
        content: Text(msg),
      ),
    );
  }

  Future<void> signupUser() async {
    if (!_formKey.currentState!.validate() || !termsAccepted) return;

    setState(() => isLoading = true);

    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    try {
      
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user!.uid;

     
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "name": name,
        "email": email,
        "photoUrl": "",
        "level": 0,
        "points": 0,
        "streak": 0,
        "lastLogin": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
        "badges": [],
        "stats": {},
        "lastActivity": {},
        "streakMap": {}, 
        "completedTopics": [],
        "dailyChallenges": {},
        "conceptProgress": {}, 
      });

      showMessage(Colors.greenAccent, "Account created successfully!");

      
      nameController.clear();
      emailController.clear();
      passwordController.clear();

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      showMessage(Colors.redAccent, e.message ?? "Authentication error");
    } on FirebaseException catch (e) {
      showMessage(Colors.redAccent, e.message ?? "Firestore error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 750) {
          return _websiteView(context, screenHeight, screenWidth, theme, textTheme);
        }
        return _mobileView(context, screenWidth, screenHeight, theme, textTheme);
      },
    );
  }

  Widget _mobileView(BuildContext context, double screenWidth, double screenHeight,
      ThemeData theme, TextTheme textTheme) {
    return Scaffold(
      backgroundColor: const Color(0xFF131228),
      body: Center(
        child: _signupCard(context, screenWidth, screenWidth * 0.7, screenHeight,
            screenWidth, theme, textTheme),
      ),
    );
  }

  Widget _websiteView(BuildContext context, double screenHeight, double screenWidth,
      ThemeData theme, TextTheme textTheme) {
    return Scaffold(
      backgroundColor: const Color(0xFF131228),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            width: screenWidth * 0.4,
            height: screenHeight,
            child: Center(
              child: Image.asset("assets/LoginSignUpAssets/signUp_gif.gif"),
            ),
          ),
          _signupCard(context, screenWidth * 0.5, screenWidth * 0.3, screenHeight,
              screenWidth, theme, textTheme),
        ],
      ),
    );
  }

  Widget _signupCard(
      BuildContext context,
      double width,
      double inputWidth,
      double screenHeight,
      double screenWidth,
      ThemeData theme,
      TextTheme textTheme) {
    return SizedBox(
      width: width,
      height: screenHeight,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF070915),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Nexus",
                      style: textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 12),
                  Text("Join Nexus Today",
                      style: textTheme.displayMedium
                          ?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomInput(
                          ctrl: nameController,
                          hintText: "Username",
                          width: inputWidth,
                          validator: (v) =>
                              v!.isEmpty ? "Enter your name" : null,
                        ),
                        const SizedBox(height: 12),
                        CustomInput(
                          ctrl: emailController,
                          hintText: "Email",
                          width: inputWidth,
                          validator: (v) {
                            if (v!.isEmpty) return "Enter email";
                            if (!v.contains("@")) return "Enter valid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomInput(
                          ctrl: passwordController,
                          hintText: "Password",
                          isPassField: true,
                          width: inputWidth,
                          validator: (v) {
                            if (v!.isEmpty) return "Enter password";
                            if (v.length < 6) return "Password too short";
                            if (!RegExp(r'[@#&%^*]').hasMatch(v)) {
                              return "Include 1 special char (@, #, &, %, ^, *)";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          value: termsAccepted,
                          onChanged: (val) =>
                              setState(() => termsAccepted = val!),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.lightBlueAccent,
                          title: Text(
                            "I agree to the terms of service and Privacy Policy.",
                            style: textTheme.labelMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: screenWidth * 0.1 < 70 ? 100 : screenWidth * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Colors.lightBlueAccent, Colors.pinkAccent],
                            ),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: signupUser,
                            child: isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text("Sign Up"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ",
                          style: textTheme.labelMedium
                              ?.copyWith(color: Colors.white70)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        ),
                        child: Text(
                          "Sign In",
                          style: textTheme.labelMedium
                              ?.copyWith(color: Colors.lightBlueAccent),
                        ),
                      ),
                    ],
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
