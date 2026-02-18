// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nexus/Models/projects_model.dart';
import 'package:nexus/Screens/ProjectHub/projectcard.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = "All";
  late List<ProjectsModel> filteredProjects;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  List<ProjectsModel> sampleProjects = [];

  late Future<void> _loadingFuture;

  Future<void> fetchProjects() async{
    try{
      final ref = FirebaseFirestore.instance.collection('projects');
      final snapShot = await ref.get();
      sampleProjects = snapShot.docs.map((doc)=>ProjectsModel.fromMap(doc.data())).toList();
    }catch(e){
      debugPrint("Error $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadingFuture = _initializeProjects();
    _searchController.addListener(filterProjects);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  Future<void> _initializeProjects() async {
    await fetchProjects();
   
    setState(() {
      filteredProjects = List.from(sampleProjects); 
      filterProjects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void filterProjects() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      filteredProjects = sampleProjects.where((p) {
        final matchesSearch = p.projectName.toLowerCase().contains(query) ||
            p.onTopic.toLowerCase().contains(query) ||
            p.difficulty.toLowerCase().contains(query);
        final matchesCategory = selectedCategory == "All" ||
            p.onTopic.toLowerCase().contains(selectedCategory.toLowerCase());
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      filterProjects();
    });
  }

  Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.greenAccent;
      case 'intermediate':
        return Colors.orangeAccent;
      case 'advanced':
      case 'hard':
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // ignore: unused_local_variable
    int crossAxisCount = 1;
    if (screenWidth >= 1200) {
      crossAxisCount = 4;
    } else if (screenWidth >= 900) {
      crossAxisCount = 3;
    } else if (screenWidth >= 600) {
      crossAxisCount = 2;
    }

    double cardHeight = screenWidth >= 1200 ? 300 : 280;

    final categories = [
      ["All", Colors.blue],
      ["Arrays", Colors.tealAccent],
      ["Linked List", Colors.amber],
      ["Trees", Colors.deepPurpleAccent],
      ["Graphs", Colors.orangeAccent],
      ["Stacks", Colors.pinkAccent],
      ["Queues", Colors.lightGreenAccent],
      ["Dynamic Programming", Colors.purpleAccent],
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.purple, Colors.cyan, Colors.greenAccent],
          ).createShader(bounds),
          child: const Text(
            "Nexus Project Hub",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.cyanAccent),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading projects: ${snapshot.error}",
              style: TextStyle(color: Colors.red),
            ),
          );
        }
          
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.015),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Search Bar with Animation
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.3),
                                Colors.cyan.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Search projects, topics, difficulty...",
                              hintStyle: TextStyle(color: Colors.white60),
                              prefixIcon: Icon(Icons.search, color: Colors.cyanAccent),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.transparent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyanAccent, width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02,
                                vertical: screenWidth * 0.015,
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        
                  SizedBox(height: screenWidth * 0.025),
        
                  // Category Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: screenWidth * 0.02),
                        for (var cat in categories)
                          GestureDetector(
                            onTap: () => onCategorySelected(cat[0] as String),
                            child: chipWidget(
                              cat[0] as String,
                              cat[1] as Color,
                              isSelected: selectedCategory == cat[0],
                            ),
                          ),
                        SizedBox(width: screenWidth * 0.02),
                      ],
                    ),
                  ),
        
                  SizedBox(height: screenWidth * 0.025),
        
                  // Project Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(12),
                    itemCount: filteredProjects.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      mainAxisSpacing: screenWidth * 0.02,
                      crossAxisSpacing: screenWidth * 0.02,
                      mainAxisExtent: cardHeight,
                    ),
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      return TweenAnimationBuilder(
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: projectCard(
                                context,
                                project,
                                screenWidth,
                                getDifficultyColor(project.difficulty),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
        
                  if (filteredProjects.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 80, color: Colors.white24),
                          SizedBox(height: 20),
                          Text(
                            "No projects found",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Try adjusting your filters",
                            style: TextStyle(color: Colors.white38, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );}
      ),
    );
  }

  Widget chipWidget(String label, Color color, {bool isSelected = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(colors: [color, color.withOpacity(0.7)])
            : null,
        color: isSelected ? null : color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? Colors.white : color,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
