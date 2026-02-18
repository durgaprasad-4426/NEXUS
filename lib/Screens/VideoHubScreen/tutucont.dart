
import 'package:flutter/material.dart';
import 'package:nexus/Screens/VideoHubScreen/videoapi.dart';
import 'package:nexus/Screens/VideoHubScreen/videodata.dart';
import 'package:nexus/Screens/VideoHubScreen/videoscrn.dart';

class Tutucard extends StatelessWidget {
  final String videoId;
  final String level;
  const Tutucard({super.key, required this.videoId, required this.level});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<VideoData>(
      future: fetchVideoDetails(videoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
              height: screenHeight * 0.2,
              child: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return Center(child: Text("No data available"));
        }

        final video = snapshot.data!;

        return Container(
          width: (screenWidth < 600? screenWidth * 1 : screenWidth * 1),
          height: 220,
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
          decoration: BoxDecoration(
            color: const Color(0xff2f1e3c),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF9d4edd), width: 2),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              spacing: 12,
              children: [
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            video.thumbnailUrl,
                            width: (screenWidth<600 ? screenWidth * 0.35 : screenWidth *0.2),
                            height: (screenHeight<650 ? screenHeight * 0.15 : screenHeight*0.15),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VideoPlayerScreen(videoId: video.id),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54,
                                ),
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 28,
                                  color: Color(0xFF9d4edd),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: (screenWidth < 600 ? screenWidth * 0.15 : screenWidth * 0.05),
                      height: screenHeight * 0.04,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          formatDuration(video.duration),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xff2b1d37),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Color(0xFF00ff9d)),
                          ),
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00ff9d),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.visibility_outlined,
                                color: Colors.white70,
                                size: 24),
                            SizedBox(width: 4),
                            Text(
                              formatNumber(video.views),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.thumb_up_outlined,
                                color: Colors.white70,
                                size: 24),
                            SizedBox(width: 4),
                            Text(
                              formatNumber(video.likes),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
