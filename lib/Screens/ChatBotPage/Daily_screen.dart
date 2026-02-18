import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nexus/Providers/chart_provider.dart';
import 'package:nexus/Providers/daily_task_provider.dart';
import 'package:nexus/Providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  final List<String> dsaTopics = const [
    "Arrays",
    "Linked List",
    "Stacks",
    "Queues",
    "Trees",
    "Graphs",
    "Hashing",
    "Dynamic Programming",
    "Recursion",
    "Sorting Algorithms",
    "Searching Algorithms",
  ];

  String getTodayTopic() {
    int dayIndex = (DateTime.now().day - 1) % dsaTopics.length;
    return dsaTopics[dayIndex];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final todayTopic = getTodayTopic();
      final todayDate = DateTime.now().toIso8601String().split('T')[0];

      final box = Hive.box('userBox');
      final cachedData = box.get('dailyTask_$todayDate');

      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      if(cachedData != null){
        chatProvider.setTopicContent(cachedData);
      }else{
       await chatProvider.generateTopicContent(
        "Generate a detailed, comprehensive daily task and explanation for the DSA topic: $todayTopic. Include a short description, an example problem, and key concepts. Format the output using clear Markdown.",
      );
      box.put('dailyTask_$todayDate', chatProvider.topicContent);

      final keys = box.keys.where((key)=>key.toString().startsWith('dailyTask_')).toList();
      for(final key in keys){
        if(key != 'dailyTask_$todayDate'){
          box.delete(key);
        }
      }

      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    String todayTopic = getTodayTopic();
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios_new)),
        title: GradientText(
          "Nexus",
          gradient: const LinearGradient(
            colors: [Colors.purple, Color.fromARGB(255, 33, 212, 243), Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth > 600 ? 32 : 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 200 : 120),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.tealAccent, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Daily Task',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth > 600 ? 18 : 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GradientText(
                "Today's Topic: $todayTopic",
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.blue, Colors.green, Colors.yellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 36 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DailyContentContainer(todayTopic: todayTopic),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                bool isWideScreen = constraints.maxWidth > 600;

                if (isWideScreen) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(child: DailyLeetCodeProblem()),
                        SizedBox(width: 16),
                        Expanded(child: DailyTaskButton()),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 350),
                          child: const DailyLeetCodeProblem(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 350),
                          child: const DailyTaskButton(),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}




class DailyTaskButton extends StatelessWidget {
  const DailyTaskButton({super.key});

 

  @override
  Widget build(BuildContext context) {
     Future<void> markCompletedInFirebase(String todayDate) async {
    final user = FirebaseAuth.instance.currentUser;
    final provider = Provider.of<UserProvider>(context, listen: false);
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    int points = provider.user?.points ?? 0;
    int newPoints = points+50;
    await userRef.set({
      'points':newPoints,
      'dailyChallenges': {todayDate: true}
    }, SetOptions(merge: true));
  }
    final taskProvider = Provider.of<DailyTaskProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;

    final todayDate = DateTime.now().toIso8601String().split('T')[0]; 

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: taskProvider.isCompletedToday
            ? null
            : () async {
                // Mark locally
                taskProvider.markCompleted();

                // Mark in Firebase
                await markCompletedInFirebase(todayDate);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task marked as completed!')),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: taskProvider.isCompletedToday
                ? const LinearGradient(
                    colors: [Colors.grey, Colors.black54],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Colors.purple, Colors.blue, Colors.tealAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  taskProvider.isCompletedToday
                      ? Iconsax.tick_square
                      : Iconsax.activity,
                  color: taskProvider.isCompletedToday ? Colors.white70 : Colors.black,
                  size: screenWidth > 600 ? 28 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  taskProvider.isCompletedToday
                      ? "Completed"
                      : "Mark as Completed",
                  style: TextStyle(
                    color: taskProvider.isCompletedToday ? Colors.white70 : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth > 600 ? 18 : 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class DailyLeetCodeProblem extends StatelessWidget {
  const DailyLeetCodeProblem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 6, 84, 220),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 50, 243, 6).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Text(
        "Complete a LeetCode Problem on today's topic. After solving that problem, click the button 'Mark as Completed'.",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Gradient Text Widget
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    super.key,
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Daily Content Container with Markdown
class DailyContentContainer extends StatelessWidget {
  final String todayTopic;

  const DailyContentContainer({super.key, required this.todayTopic});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        double screenHeight = MediaQuery.of(context).size.height;
        return Container(
          width: double.infinity,
          height: screenHeight * 0.6,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.tealAccent.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: chatProvider.isTopicLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.tealAccent),
                      SizedBox(height: 16),
                      Text(
                        "Generating today's task...",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : Scrollbar(
                  child: Markdown(
                    data: chatProvider.topicContent.isEmpty
                        ? "Waiting for content on: $todayTopic"
                        : chatProvider.topicContent,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent,
                      ),
                      h2: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                      ),
                      p: const TextStyle(fontSize: 15, color: Colors.white),
                      code: const TextStyle(
                        backgroundColor: Color.fromARGB(255, 20, 20, 20),
                        color: Color.fromARGB(255, 107, 233, 111),
                        fontSize: 14,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Color.fromARGB(255, 20, 20, 20),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      blockSpacing: 10.0,
                    ),
                    onTapLink: (text, href, title) async {
                      if (href != null) {
                        final uri = Uri.parse(href);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      }
                    },
                  ),
                ),
        );
      },
    );
  }
}
