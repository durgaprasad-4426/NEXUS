import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nexus/Models/concept_model.dart';
import 'package:nexus/Models/concept_progress_model.dart';
import 'package:nexus/Providers/chart_provider.dart';
import 'package:nexus/Providers/user_provider.dart';
import 'package:nexus/Screens/ChatBotPage/Daily_screen.dart';
import 'package:nexus/Screens/HomePage/category_tabs.dart';
import 'package:nexus/Screens/HomePage/concept_card.dart';
import 'package:nexus/Screens/HomePage/header.dart';
import 'package:nexus/Screens/HomePage/topics_card.dart';
import 'package:nexus/widgets/ShimmerEffects/loading_grid_cards.dart';
import 'package:provider/provider.dart';

class UserConceptView {
  final TopicsData concept;
  final ConceptProgress progress;
  UserConceptView({required this.concept, required this.progress});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategoryIndex = 0;
   Future<List<String>>? _recommendationsFuture;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  List<TopicsData> allConcepts = [];

  Future<void> fetchAllConcepts() async {
    try {
      final ref = FirebaseFirestore.instance.collection('concepts');
      final snap = await ref.get();
      for (var doc in snap.docs) {
        allConcepts.add(TopicsData.fromMap(doc.data(), doc.id));
      }
      debugPrint("Fteched Concepts");
    } catch (e) {
      debugPrint("Error $e");
    }
  }

  final List<Category> categories = [
    Category(name: 'All', icon: Icons.home_outlined),
    Category(name: 'Arrays', icon: Icons.list),
    Category(name: 'Linked List', icon: Icons.link),
    Category(name: 'Stack', icon: Icons.stacked_bar_chart_outlined),
    Category(name: 'Queues', icon: Icons.queue),
    Category(name: 'Trees', icon: Iconsax.tree),
    Category(name: "Graphs", icon: Iconsax.graph),
  ];

  Future<void> _loadData() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    allConcepts.clear();

    await fetchAllConcepts();
    if (userProvider.user != null &&
        userProvider.user!.conceptProgress.isNotEmpty) {
      final future = chatProvider.generateRecommendations(
        userProvider.user!,
        allConcepts,
        userProvider.user!.conceptProgress,
      );

      setState(() {
        _recommendationsFuture = future;
      });
    } else {
      debugPrint("User data not ready yet — skipping recommendations");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeaderBar(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    searchQuery = val;
                  });
                },
              ),
              dailyChallengeContainer(),
              categoryTabsMethod(),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 220,
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection("concepts")
                            .snapshots(),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingGridCards();
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No Data",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      List<UserConceptView> concepts =
                          snapshot.data!.docs.map((doc) {
                            final concept = TopicsData.fromMap(
                              doc.data() as Map<String, dynamic>,
                              doc.id,
                            );

                            final progress =
                                provider.conceptProgress[doc.id] ??
                                ConceptProgress(
                                  progress: 0,
                                  isCompleted: false,
                                );

                            return UserConceptView(
                              concept: concept,
                              progress: progress,
                            );
                          }).toList();

                      String selectedTopic =
                          categories[selectedCategoryIndex].name;
                      if (selectedTopic != "All") {
                        concepts =
                            concepts
                                .where(
                                  (p) => p.concept.topicName.contains(
                                    selectedTopic,
                                  ),
                                )
                                .toList();
                      }

                      if (searchQuery.isNotEmpty) {
                        concepts =
                            concepts.where((p) {
                              final name = p.concept.topicName.toLowerCase();
                              final desc = p.concept.description.toLowerCase();
                              final query = searchQuery.toLowerCase();
                              return name.contains(query) ||
                                  desc.contains(query);
                            }).toList();
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: concepts.length,
                        itemBuilder: (_, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => TopicsCard(
                                        topic: concepts[index].concept,
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Consumer<UserProvider>(
                                builder: (_, provider, __) {
                                  final progress =
                                      provider.conceptProgress[concepts[index]
                                          .concept
                                          .id] ??
                                      ConceptProgress(
                                        progress: 0,
                                        isCompleted: false,
                                      );

                                  return SizedBox(
                                    width: 260,
                                    height: 300,
                                    child: ConceptCard(
                                      project: concepts[index].concept,
                                      progress: progress,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Recommended For you",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  height: 270,
                  child: FutureBuilder<List<String>>(
                    future: _recommendationsFuture,
                    builder: (_, snapShot) {
                      if (snapShot.connectionState == ConnectionState.waiting) {
                        return LoadingGridCards();
                      }
                      if (snapShot.hasError) {
                        return Center(child: Text(snapShot.error.toString()));
                      }
                      if (!snapShot.hasData || snapShot.data == null) {
                        return Center(child: Text("No Recommendations"));
                      }
                      final recommendedIds = snapShot.data;

                      List<TopicsData> recommendedConcepts =
                          allConcepts
                              .where(
                                (concept) =>
                                    recommendedIds!.contains(concept.id),
                              )
                              .toList();
                      return ListView.builder(
                        padding: EdgeInsets.all(16),
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: recommendedConcepts.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => TopicsCard(
                                        topic: recommendedConcepts[index],
                                      ),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 260,
                              height: 300,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Consumer<UserProvider>(
                                  builder: (_, provider, _) {
                                    final progress =
                                        provider
                                            .conceptProgress[recommendedConcepts[index]
                                            .id] ??
                                        ConceptProgress(
                                          progress: 0,
                                          isCompleted: false,
                                        );
                                    return ConceptCard(
                                      project: recommendedConcepts[index],
                                      progress: progress,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CategoryTabs categoryTabsMethod() {
    return CategoryTabs(
      categories: categories,
      selectedIndex: selectedCategoryIndex,
      onTabSelected: (idx) {
        setState(() {
          selectedCategoryIndex = idx;
        });
      },
      activeColor: Colors.blueAccent,
      inactiveColor: Colors.grey.shade500,
      backgroundColor: const Color(0xFF1A1A1A),
    );
  }

  Widget dailyChallengeContainer() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade700.withOpacity(0.9),
            Colors.deepPurple.shade300.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.star, size: 40, color: Colors.yellowAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Today's Challenge",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DailyScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellowAccent,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Start",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
