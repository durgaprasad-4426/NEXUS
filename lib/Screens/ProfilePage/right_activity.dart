import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexus/Models/concept_model.dart';
import 'package:nexus/Models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RightActivity extends StatefulWidget {
  final UserModel user;
  final List<TopicsData> allConcepts;

  const RightActivity({
    super.key,
    required this.user,
    required this.allConcepts,
  });

  @override
  State<RightActivity> createState() => _RightActivityState();
}

class _RightActivityState extends State<RightActivity>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final String todayDate;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    todayDate = DateTime.now().toIso8601String().split('T')[0];

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildCard({
    required String title,
    double? progress,
    int index = 0,
    bool showProgress = true,
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    final animation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval((index * 0.1).clamp(0.0, 1.0), 1.0, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: animation,
      child: FadeTransition(
        opacity: _animController,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradientStart ?? Colors.grey.shade900,
                gradientEnd ?? Colors.grey.shade800,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (progress != null && showProgress)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      color: Colors.amber,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final dailyChallengeStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();

    final dailyChallengeWidget = StreamBuilder<DocumentSnapshot>(
      stream: dailyChallengeStream,
      builder: (context, snapshot) {
        bool completed = false;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final dailyChallenges = data['dailyChallenges'] as Map<String, dynamic>? ?? {};
          completed = dailyChallenges[todayDate] ?? false;
        }

        return _buildCard(
          title: completed
              ? " You completed today's daily challenge!"
              : " Complete today's daily challenge!",
          index: 0,
          showProgress: false,
          gradientStart: completed ? Colors.green : Colors.orange,
          gradientEnd: completed ? Colors.teal : Colors.deepOrange,
        );
      },
    );

    final recentActivityWidgets = <Widget>[];
    final lastActivity = widget.user.lastActivity;

    if (lastActivity.isNotEmpty) {
      try {
        final conceptId = lastActivity['conceptId'] as String? ?? '';
        final dateStr = lastActivity['date'] as String? ?? '';
        final progressValue = (lastActivity['progress'] ?? 0) as int;

        final concept = widget.allConcepts.firstWhere(
          (c) => c.id == conceptId,
          orElse: () => TopicsData(
            id: conceptId,
            topicName: conceptId,
            description: '',
            content: '',
            algorithm: '',
            problems: [],
            difficulty: '',
            estimatedtime: '',
            progress: progressValue,
            isCompleted: false,
          ),
        );

        double progressPercent = 0.0;
        if (concept.totalSteps > 0) {
          progressPercent = progressValue / concept.totalSteps;
        }

        DateTime date;
        try {
          date = DateTime.parse(dateStr);
        } catch (_) {
          date = DateTime.now();
        }

        recentActivityWidgets.add(_buildCard(
          title:
              "Worked on: ${concept.topicName} (${DateFormat('dd MMM').format(date)})",
          progress: progressPercent,
          index: 0,
        ));
      } catch (_) {}
    }

    final completedWidgets = <Widget>[];
    int idx = 0;
    for (final conceptId in widget.user.completedTopics) {
      try {
        final concept = widget.allConcepts.firstWhere(
          (c) => c.id == conceptId,
          orElse: () => TopicsData(
            id: conceptId,
            topicName: conceptId,
            description: '',
            content: '',
            algorithm: '',
            problems: [],
            difficulty: '',
            estimatedtime: '',
            progress: 0,
            isCompleted: true,
          ),
        );

        completedWidgets.add(_buildCard(
          title: "Completed: ${concept.topicName}",
          showProgress: false,
          index: idx,
          gradientStart: Colors.blueGrey,
          gradientEnd: Colors.cyan,
        ));
        idx++;
      } catch (_) {}
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily Challenge Section
            const Text(
              "Daily Challenge",
              style: TextStyle(
                  color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            dailyChallengeWidget,
            const SizedBox(height: 20),

            // Recent Activity Section
            const Text(
              "Recent Activity",
              style: TextStyle(
                  color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (recentActivityWidgets.isNotEmpty)
              ...recentActivityWidgets
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No recent activity",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Completed Topics Section
            const Text(
              "Completed Topics",
              style: TextStyle(
                  color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (completedWidgets.isNotEmpty)
              ...completedWidgets
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No completed topics",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
