// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:nexus/Models/projects_model.dart';
import 'package:nexus/Screens/ProjectHub/project_deatil_page.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

Widget projectCard(
  BuildContext context,
  ProjectsModel project,
  double screenWidth,
  Color difficultyColor,
) {
  double titleFont = screenWidth < 600 ? 16 : 18;
  double descFont = screenWidth < 600 ? 12 : 14;
  double buttonFont = screenWidth < 600 ? 12 : 14;
  double pieSize = screenWidth < 600 ? 25 : 30;

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!,
            Colors.grey[850]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: difficultyColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: difficultyColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailPage(project: project),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(screenWidth < 600 ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.code,
                        color: difficultyColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        project.projectName,
                        style: TextStyle(
                          fontSize: titleFont,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Difficulty Badge
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [difficultyColor, difficultyColor.withOpacity(0.6)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: difficultyColor.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 12,
                            color: Colors.black,
                          ),
                          SizedBox(width: 4),
                          Text(
                            project.difficulty,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                      ),
                      child: Text(
                        project.codeLang,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.cyanAccent,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Description
                Expanded(
                  child: Text(
                    project.decription,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: descFont,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // Footer
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDetailPage(project: project),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: difficultyColor,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        icon: Icon(Icons.play_arrow, size: 18),
                        label: Text(
                          "Start Project",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: buttonFont,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    CircularPercentIndicator(
                      radius: pieSize / 2,
                      lineWidth: 4.0,
                      percent: 0.0,
                      backgroundColor: Colors.grey[800]!,
                      progressColor: difficultyColor,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      animationDuration: 1200,
                      center: Text(
                        "0%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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