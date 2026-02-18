
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nexus/Screens/VideoHubScreen/videodata.dart';

const String apiKey = "AIzaSyA-sAlxAPbgEKBmZ1iiBF0IbfLq7ABg_cM";

Future<VideoData> fetchVideoDetails(String videoId) async {
  final url = Uri.parse(
    "https://www.googleapis.com/youtube/v3/videos"
    "?part=snippet,contentDetails,statistics&id=$videoId&key=$apiKey",
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['items'].isNotEmpty) {
      return VideoData.fromJson(data['items'][0]);
    } else {
      throw Exception("Video not found");
    }
  } else {
    throw Exception("Failed to fetch details");
  }
}

String formatDuration(String isoDuration) {
  final regex = RegExp(r'PT(?:(\d+)M)?(?:(\d+)S)?');
  final match = regex.firstMatch(isoDuration);

  final minutes = int.tryParse(match?.group(1) ?? '0') ?? 0;
  final seconds = int.tryParse(match?.group(2) ?? '0') ?? 0;

  return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
}

String formatNumber(String number) {
  final value = int.tryParse(number) ?? 0;

  if (value >= 1000000000) {
    return "${(value / 1000000000).toStringAsFixed(1)}B";
  } else if (value >= 1000000) {
    return "${(value / 1000000).toStringAsFixed(1)}M";
  } else if (value >= 1000) {
    return "${(value / 1000).toStringAsFixed(1)}K";
  } else {
    return value.toString();
  }
}