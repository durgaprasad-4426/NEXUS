
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:nexus/Screens/VideoHubScreen/topics.dart';
import 'package:nexus/Screens/VideoHubScreen/tutucont.dart';
import 'package:nexus/Screens/VideoHubScreen/videocont.dart';

class Videospage extends StatefulWidget {
  const Videospage({super.key});

  @override
  State<Videospage> createState() => _VideospageState();
}

class _VideospageState extends State<Videospage> {
  TextEditingController cntrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return youtubepage();
  }

  Scaffold youtubepage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              SizedBox(height: 12),
              Text(
                'YouTube Recommender',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00cfff),
                ),
              ),
              TextFormField(
                controller: cntrl,
                style: TextStyle(fontSize: 16, color: Colors.grey),
                decoration: InputDecoration(
                  border: GradientOutlineInputBorder(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.blue, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    width: 2,
                  ),
                  hintText: "Search for DSA tutorials, algorithms",
                  hintStyle: TextStyle(
                    color: Color(0xff8a8a8a),
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 24,
                    color: Color(0xff8a8a8a),
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Popular Topics",
                style: TextStyle(
                  color: Color(0xff9d4edd),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 12,
                  children: [
                    topicCont(Color(0xff01c2f0), Color(0xff10252a), "Array (12)", screenWidth, screenHeight),
                    topicCont(Color(0xff00f999), Color(0xff102a20), "Trees (8)", screenWidth, screenHeight),
                    topicCont(Color(0xff984bd5), Color(0xff201826), "Graphs (6)", screenWidth, screenHeight),
                    topicCont(Color(0xff02b8e2), Color(0xff10252a), "Sorting (10)", screenWidth, screenHeight),
                    topicCont(Color(0xff9d4edd), Color(0xff201826), "Dp (5)", screenWidth, screenHeight),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Recommended For You",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff01f89a),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 12,
                  children: [
                    VideoCard(videoId: "0OK-kbu9Cwo", level: 'Beginner',),
                    VideoCard(videoId: "AT14lCXuMKI", level: 'Medium',),
                    VideoCard(videoId: "3mpavnlrXQM", level: 'Hard',),
                  ]
                ),
              ),
              SizedBox(height: 8),
              Text(
                "All Tutorials",
                style: TextStyle(
                  color: Color(0xff9d4edd),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                spacing: 12,
                children: [
                  Tutucard(videoId: "OBpPmHzvn2g", level: 'Beginner'),
                  Tutucard(videoId: "0OK-kbu9Cwo", level: 'Beginner',),
                  Tutucard(videoId: "AT14lCXuMKI", level: 'Medium',),
                  Tutucard(videoId: "3mpavnlrXQM", level: 'Hard',),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
