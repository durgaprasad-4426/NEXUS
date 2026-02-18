
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nexus/Models/concept_model.dart';
import 'package:nexus/Models/visualization_maps.dart';
import 'package:nexus/Providers/badges_provider.dart';
import 'package:nexus/Providers/progress_update_provider.dart';
import 'package:nexus/Providers/user_provider.dart';
import 'package:nexus/widgets/level_up_animation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TopicsCard extends StatefulWidget {
  final TopicsData topic;
  const TopicsCard({super.key, required this.topic});

  @override
  State<TopicsCard> createState() => _TopicsCardState();
}

class _TopicsCardState extends State<TopicsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slide;
  final ScrollController _scrollCtrl = ScrollController();
  bool _reachedEnd = false;


  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(()async {
       if (!mounted) return; 
      // debugPrint("Scroll position: ${_scrollCtrl.position.pixels}, Max: ${_scrollCtrl.position.maxScrollExtent}");
      if(_scrollCtrl.position.atEdge){
        final scrollUpdatedProgress = context.read<ProgressUpdateProvider>().scrollUpdateProgress;
        bool isBottom = _scrollCtrl.position.pixels == _scrollCtrl.position.maxScrollExtent;
        if(isBottom && !scrollUpdatedProgress){
          if(mounted){
            setState(() {
            _reachedEnd = true;
          });
          }
            await _updateProgress();
             if (!mounted) return; 
           if(mounted){
            
               context.read<ProgressUpdateProvider>().toggleScrollProgress();
          }
        }else{
          if(_reachedEnd){
            if(mounted){
                setState(() {
              _reachedEnd = false;
            });
            }
          }
            
        }
      }
    });
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateProgress() async {
    debugPrint("Updating progress for topic: ${widget.topic.topicName}");
    final box = Hive.box('userBox');
    final provider = Provider.of<UserProvider>(context, listen: false);
    final uid = provider.uid;
    if (uid == null) return;

    final userRef = FirebaseFirestore.instance.collection("users").doc(uid);
    final conceptRef = userRef.collection("conceptProgress").doc(widget.topic.id);

    try {
      final conceptSnap = await conceptRef.get();
      int newProgress = 1;
      if (conceptSnap.exists) {
        final data = conceptSnap.data() as Map<String, dynamic>;
        final currentProgress = data["progress"] ?? 0;
        newProgress = currentProgress + 1;
      }

      final totalSteps = widget.topic.totalSteps;
      if (newProgress > totalSteps) newProgress = totalSteps;
      final isCompleted = newProgress >= totalSteps;

      await conceptRef.set({
        "conceptId": widget.topic.id,
        "progress": newProgress,
        "isCompleted": isCompleted,
        "lastAccessed": Timestamp.now(),
        "completedAt": isCompleted ? Timestamp.now() : null,
      }, SetOptions(merge: true));
      if(isCompleted){
        if(box.get('recommendedTopics')!=null){
          box.delete('recommendedTopics');
        }
      }
       if (!mounted) return; 

      final userSnap = await userRef.get();
       if (!mounted) return; 
      if (userSnap.exists) {
        final userData = userSnap.data() as Map<String, dynamic>;

        int oldPoints = userData["points"] ?? 0;
        int newPoints = oldPoints + 25;
    int currentLevel = widget.topic.calculateLevel(oldPoints);
    int newLevel = widget.topic.calculateLevel(newPoints);

    if(newLevel > currentLevel){
      showDialog(
      context: context, 
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_)=>LevelUpCelebration(level: newLevel));
    }
        

        Map<String, dynamic> streakMap = {};
        if (userData["streakMap"] != null && userData["streakMap"] is Map<String, dynamic>) {
          streakMap = Map<String, dynamic>.from(userData["streakMap"]);
        }

        final todayKey = DateTime.now().toIso8601String().split("T")[0];
        streakMap[todayKey] = true;

        final allDates = streakMap.keys.toList()..sort();
        int streakCount = 0;
        if (allDates.isNotEmpty) {
          DateTime? prev;
          for (var dateStr in allDates) {
            DateTime date = DateTime.parse(dateStr);
            if (prev == null) {
              streakCount = 1;
            } else if (date.difference(prev).inDays == 1) {
              streakCount++;
            }
            prev = date;
          }
        }

        List<String> completedTopics = List<String>.from(userData["completedTopics"] ?? []);
        if (isCompleted && !completedTopics.contains(widget.topic.id)) {
          completedTopics.add(widget.topic.id);
        }

        Map<String, dynamic> stats = {};
        if (userData["stats"] != null) {
          stats = Map<String, dynamic>.from(userData["stats"]);
        }
        stats[widget.topic.topicName] = newProgress;

        final badgesProvider = Provider.of<BadgesProvider>(context, listen: false);
        await badgesProvider.checkAndAwardTopicBadges(
          completedTopics,
          userData["badges"] != null ? List<String>.from(userData["badges"]) : [],
          uid,
        );

        await userRef.set({
          "points": newPoints,
          "streak": streakCount,
          "level":newLevel,
          "streakMap": streakMap,
          "completedTopics": completedTopics,
          "stats": stats,
          "lastActivity": {
            "conceptId": widget.topic.id,
            "date": DateTime.now().toIso8601String(),
            "progress": newProgress,
          },
        }, SetOptions(merge: true));
      }
       if (!mounted) return; 

      debugPrint("Progress & Streak updated successfully!");
    } catch (e, st) {
      debugPrint("Error updating progress: $e");
      debugPrint(st.toString());
    }
  }



 Future<void> _launchUrl(String urlString) async {
  final Uri url = Uri.parse(urlString);
  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, 
      );
      await _updateProgress();
      if(!mounted) return;
    } else {
      await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      await _updateProgress();
       if(!mounted) return;
    }
  } catch (e) {
    _showError("Failed to launch URL: $e");
  }
}


  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  String extractProblemName(String url) {
    final uri = Uri.parse(url);
    if (uri.pathSegments.length >= 2) {
      return uri.pathSegments[uri.pathSegments.length - 2];
    }
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final project = widget.topic;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Iconsax.arrow_circle_left, color: Colors.white),
        ),
        title: const Text(
          "Topic Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.cyanAccent, Colors.blueAccent],
                    ).createShader(bounds),
                    child: Text(
                      project.topicName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(Iconsax.document, "Description", project.description),
              const SizedBox(height: 16),
              _buildSection(Iconsax.book, "Content", project.content),
              const SizedBox(height: 16),
              _buildSection(Iconsax.code, "Algorithm", project.algorithm, boxed: true),
              const SizedBox(height: 20),
              const Text(
                "🚀 Problems",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (project.problems.isEmpty)
                const Text(
                  "No problems available",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                )
              else
                ...project.problems.map((problemUrl) {
                  return GestureDetector(
                    onTap: () => _launchUrl(problemUrl),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.link, color: Colors.lightBlueAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              extractProblemName(problemUrl),
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
              _buildVisualizationButton(project.id),
              const SizedBox(height: 24),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(provider.uid)
                    .collection("conceptProgress")
                    .doc(widget.topic.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  int progress = 0;
                  bool isCompleted = false;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                    progress = data["progress"] ?? 0;
                    isCompleted = data["isCompleted"] ?? false;
                  }
                  return _buildProgressIndicator(
                      progress: progress, total: widget.topic.totalSteps, isCompleted: isCompleted);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({
    required int progress,
    required int total,
    required bool isCompleted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : progress / total,
            minHeight: 12,
            backgroundColor: Colors.grey[900],
            valueColor: AlwaysStoppedAnimation(isCompleted ? Colors.greenAccent : Colors.cyan),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            isCompleted ? "🎉 Completed!" : "Progress: $progress / $total",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(IconData icon, String title, String content, {bool boxed = false}) {
    final titleStyle = const TextStyle(
      color: Colors.cyanAccent,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );
    final contentStyle = const TextStyle(
      color: Colors.white70,
      fontSize: 16,
      height: 1.4,
    );

    Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 20),
            const SizedBox(width: 8),
            Text(title, style: titleStyle),
          ],
        ),
        const SizedBox(height: 6),
        Text(content, style: contentStyle),
      ],
    );

    if (boxed) {
      child = Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.black54, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: child,
      );
    }

    return child;
  }

  Widget _buildVisualizationButton(String topicId) {
    return Center(
      child: InkWell(
        onTap: () {
          VisualizationMaps visuals = VisualizationMaps();
          Navigator.push(context, MaterialPageRoute(builder:visuals.buildVisualization(context, topicId) ));

          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text("Visualization coming soon!")),
          // );
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.cyanAccent],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.activity, color: Colors.black),
              SizedBox(width: 10),
              Text(
                "View Visualization",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
