import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:nexus/Models/projects_model.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectsModel project;

  const ProjectDetailPage({Key? key, required this.project}) : super(key: key);

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _codeCopied = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.project.codes));
    setState(() {
      _codeCopied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _codeCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final difficultyColor = getDifficultyColor(widget.project.difficulty);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0A0E27),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.project.projectName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: difficultyColor.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      difficultyColor.withOpacity(0.3),
                      const Color(0xFF0A0E27),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.code,
                    size: 80,
                    color: difficultyColor.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Info Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey[900]!,
                              Colors.grey[850]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: difficultyColor.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: difficultyColor.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        difficultyColor,
                                        difficultyColor.withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: difficultyColor.withOpacity(0.5),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.bar_chart,
                                          size: 16, color: Colors.black),
                                      SizedBox(width: 6),
                                      Text(
                                        widget.project.difficulty,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.cyan.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.code,
                                          size: 16, color: Colors.cyanAccent),
                                      SizedBox(width: 6),
                                      Text(
                                        widget.project.codeLang,
                                        style: TextStyle(
                                          color: Colors.cyanAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.project.projectId,
                                    style: TextStyle(
                                      color: Colors.purpleAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Project Description",
                              style: TextStyle(
                                color: difficultyColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              widget.project.decription,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),

                      // Steps Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.withOpacity(0.2),
                              Colors.purple.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.purpleAccent.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purpleAccent,
                                        Colors.purple,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.list_alt,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Implementation Steps",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            ...widget.project.steps
                                .split('\n')
                                .where((step) => step.trim().isNotEmpty)
                                .map((step) {
                              final index = widget.project.steps
                                  .split('\n')
                                  .where((s) => s.trim().isNotEmpty)
                                  .toList()
                                  .indexOf(step);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TweenAnimationBuilder(
                                  duration: Duration(
                                      milliseconds: 300 + (index * 100)),
                                  tween: Tween<double>(begin: 0, end: 1),
                                  builder: (context, double value, child) {
                                    return Transform.translate(
                                      offset: Offset(50 * (1 - value), 0),
                                      child: Opacity(
                                        opacity: value,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.purpleAccent,
                                                    Colors.purple,
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.purpleAccent
                                                        .withOpacity(0.5),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                "${index + 1}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.purpleAccent
                                                        .withOpacity(0.2),
                                                  ),
                                                ),
                                                child: Text(
                                                  step
                                                      .trim()
                                                      .replaceAll(
                                                          RegExp(r'^\d+\.\s*'),
                                                          ''),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),

                      // Code Section
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.withOpacity(0.2),
                              Colors.blue.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.cyanAccent.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.cyanAccent,
                                          Colors.cyan,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.terminal,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Source Code",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: _copyCode,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _codeCopied
                                          ? Colors.greenAccent
                                          : Colors.cyanAccent,
                                      foregroundColor: Colors.black,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: Icon(
                                      _codeCopied ? Icons.check : Icons.copy,
                                      size: 18,
                                    ),
                                    label: Text(
                                      _codeCopied ? "Copied!" : "Copy Code",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: HighlightView(
                                  widget.project.codes.trim(),
                                  language: widget.project.codeLang
                                      .toLowerCase(),
                                  theme: monokaiSublimeTheme,
                                  padding: EdgeInsets.all(16),
                                  textStyle: TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Start coding action
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Opening coding environment...",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: Colors.greenAccent,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: difficultyColor,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                              ),
                              icon: Icon(Icons.play_circle_filled, size: 24),
                              label: Text(
                                "Start Coding",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              // Mark as complete action
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Project marked as complete!",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.purpleAccent,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                            ),
                            child: Icon(Icons.check_circle, size: 28),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}