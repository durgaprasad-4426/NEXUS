
import 'package:flutter/material.dart';
import 'package:nexus/Screens/VideoHubScreen/videoapi.dart';
import 'package:nexus/Screens/VideoHubScreen/videodata.dart';
import 'package:nexus/Screens/VideoHubScreen/videoscrn.dart';

class VideoCard extends StatelessWidget {
  final String videoId;
  final String level;
  const VideoCard({super.key, required this.videoId, required this.level});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<VideoData>(
      future: fetchVideoDetails(videoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
              height: screenHeight * 0.25,
              child: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return Center(child: Text("No data available"));
        }

        final video = snapshot.data!;

        return Container(
          width: (screenWidth < 600?screenWidth * 0.75: screenWidth*0.25),
          height: (screenHeight < 600? screenHeight * 0.4 : screenHeight*0.4),
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
          decoration: BoxDecoration(
            color: const Color(0xff0e3e49),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00cfff), width: 2),
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        video.thumbnailUrl,
                        width: (screenWidth<600? screenWidth * 0.75: screenWidth*0.35),
                        height: (screenHeight<600? screenHeight * 0.5:screenHeight*0.2),
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
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.play_arrow,
                              size: 28,
                              color: Colors.cyan,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          formatDuration(video.duration),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF00cfff),
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
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          color: Colors.white70,
                          size: 24,
                        ),
                        SizedBox(width: 6),
                        Text(
                          formatNumber(video.views),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.thumb_up_outlined,
                          color: Colors.white70,
                          size: 24,
                        ),
                        SizedBox(width: 6),
                        Text(
                          formatNumber(video.likes),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
