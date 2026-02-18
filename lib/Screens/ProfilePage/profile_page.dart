import 'package:flutter/material.dart';
import 'package:nexus/Models/concept_model.dart';
import 'package:nexus/Providers/user_provider.dart';
import 'package:nexus/Screens/ProfilePage/left_sidebar.dart';
import 'package:nexus/Screens/ProfilePage/middle_stats.dart';
import 'package:nexus/Screens/ProfilePage/streak_calendar.dart';
import 'package:nexus/Screens/ProfilePage/right_activity.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<List<TopicsData>> fetchAllConcepts() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('concepts').get();
      return snapshot.docs
          .map((doc) => TopicsData.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching concepts: $e");
      return [];
    }
  }

  Widget _shimmerPlaceholder(double height, {double width = double.infinity}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth >= 800;
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: _shimmerPlaceholder(50, width: 200),
        ),
      );
    }

    final user = userProvider.user!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<TopicsData>>(
            future: fetchAllConcepts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Loading Shimmer UI
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(
                    6,
                    (index) => _shimmerPlaceholder(80),
                  ),
                );
              }

              final allConcepts = snapshot.data ?? [];

              if (isWeb) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Sidebar
                    SizedBox(
                      width: screenWidth * 0.25,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SingleChildScrollView(
                            child: LeftSidebar(
                              user: user,
                              onUpdate: (updatedUser) async {
                                await userProvider.updateUser(updatedUser);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Middle Column
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MiddleStats(userId: user.uid),
                                const SizedBox(height: 16),
                                StreakCalendar(userId: user.uid),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right Activity
                    SizedBox(
                      width: screenWidth * 0.25,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SingleChildScrollView(
                            child: RightActivity(
                              user: user,
                              allConcepts: allConcepts,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LeftSidebar(
                            user: user,
                            onUpdate: (updatedUser) async {
                              await userProvider.updateUser(updatedUser);
                            },
                          ),
                          const SizedBox(height: 16),
                          MiddleStats(userId: user.uid),
                          const SizedBox(height: 16),
                          StreakCalendar(userId: user.uid),
                          const SizedBox(height: 16),
                          RightActivity(
                            user: user,
                            allConcepts: allConcepts,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
