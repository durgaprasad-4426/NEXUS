import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:nexus/Models/concept_model.dart';
import 'package:nexus/Models/concept_progress_model.dart';
import 'package:nexus/Models/user_model.dart';
import 'dart:convert';
import 'package:nexus/Screens/services.dart';


 const String _kQueryCountBox = 'queryCountsBox';
  const String _kDailyQueryCountKey = 'daily_query_count';
  const String _kLastQueryResetDateKey = "last_query_reset_date";
  const int _kDailyQueryLimit = 20;

  enum ChatStatus{idle, sending, generating, cancelled, limitExceeded, error}


class ChatProvider with ChangeNotifier {
 List<Map<String, String>> messages = [];
  bool _isTyping = false;
  bool _isTopicLoading = false;
  String _topicContent = "";
  List<String>? _recommendedIds;

  late Box _queryBox;
  http.Client? _httpClient;

  ChatStatus _chatStatus = ChatStatus.idle;
  String? _statusMsg;

  bool get isTyping => _isTyping;
  bool get isTopicLoading => _isTopicLoading;
  String get topicContent => _topicContent;
  List<String>? get recommendedIds => _recommendedIds;
  ChatStatus get chatStatus => _chatStatus;
  String? get statusMsg => _statusMsg;

  ChatProvider() {
    _initializeChatProvider();
  }

  Future<void> _initializeChatProvider() async {
    if (!Hive.isBoxOpen(_kQueryCountBox)) {
      _queryBox = await Hive.openBox(_kQueryCountBox);
    } else {
      _queryBox = Hive.box(_kQueryCountBox);
    }

    _httpClient = http.Client();
    await _checkAndResetDailyCountIfNewDay();
    notifyListeners();
  }

  int _getDailyQueryCount() {
    return _queryBox.get(_kDailyQueryCountKey, defaultValue: 0);
  }

  Future<void> _incrementDailyQueryCount() async {
    int currentCount = _getDailyQueryCount();
    await _queryBox.put(_kDailyQueryCountKey, currentCount + 1);
  }

  Future<void> _checkAndResetDailyCountIfNewDay() async {
    final lastResetDayString = _queryBox.get(_kLastQueryResetDateKey);
    final now = DateTime.now();

    if (lastResetDayString == null) {
      await _queryBox.put(_kLastQueryResetDateKey, now.toIso8601String());
      await _queryBox.put(_kDailyQueryCountKey, 0);
    } else {
      final lastResetDay = DateTime.parse(lastResetDayString);
      if (lastResetDay.year != now.year ||
          lastResetDay.month != now.month ||
          lastResetDay.day != now.day) {
        await _queryBox.put(_kDailyQueryCountKey, 0);
        await _queryBox.put(_kLastQueryResetDateKey, now.toIso8601String());
      }
    }
  }

  void addBotMessage(String message) {
    messages.add({"role": "nexus", "content": message});
    notifyListeners();
  }

  void addUserMessage(String message) {
    messages.add({"role": "user", "content": message});
    notifyListeners();
    generateBotResponse(message);
  }

  Future<void> generateBotResponse(String message) async {
    if (!_queryBox.isOpen) {
      _statusMsg = "Initialization error: Hive box not open.";
      _chatStatus = ChatStatus.error;
      notifyListeners();
      return;
    }
    if (_httpClient == null) {
      _statusMsg = "Initialization error: HTTP Client not ready.";
      _chatStatus = ChatStatus.error;
      notifyListeners();
      return;
    }

    await _checkAndResetDailyCountIfNewDay();
    int currentCount = _getDailyQueryCount();

    if (currentCount >= _kDailyQueryLimit) {
      _statusMsg =
          "You've reached your daily query limit. Subscribe now to get full access!";
      _chatStatus = ChatStatus.limitExceeded;
      addBotMessage(_statusMsg!);
      return;
    }

    await _incrementDailyQueryCount();

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${Secrets.apiKey}",
    );

    String prompt = """
You are Nexus, a friendly and smart AI learning assistant. 
Keep tone clear, concise, and helpful. 
Here is the conversation history:
${messages.map((msg) => "- ${msg['role']}: ${msg['content']}").join("\n")}
User message: "$message"
""";

    try {
      _isTyping = true;
      _chatStatus = ChatStatus.generating;
      _statusMsg = "Nexus is typing...";
      notifyListeners();

      final response = await _httpClient!.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String botMessage =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
                "No response";

        addBotMessage(botMessage);
        _chatStatus = ChatStatus.idle;
        _statusMsg = "";
      } else {
        final errorBody = jsonDecode(response.body);
        String errorMessage =
            errorBody['error']?['message'] ?? "Unknown API error";
        addBotMessage("Error: $errorMessage");
        _chatStatus = ChatStatus.error;
        _statusMsg = "API Error: $errorMessage (Code: ${response.statusCode})";
      }
    } on SocketException {
      _statusMsg = "No internet connection.";
      _chatStatus = ChatStatus.error;
      addBotMessage(_statusMsg!);
    } on http.ClientException catch (e) {
      if (e.message.contains('Connection closed') ||
          e.message.contains('Failed to connect')) {
        _statusMsg = "LLM response cancelled.";
        _chatStatus = ChatStatus.cancelled;
        addBotMessage(_statusMsg!);
      }
    } catch (e) {
      _statusMsg = "Unexpected error occurred.";
      _chatStatus = ChatStatus.error;
      addBotMessage(_statusMsg!);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void cancelCurrentLLMResponse() {
    if (_httpClient != null && _chatStatus == ChatStatus.generating) {
      _httpClient!.close();
      _httpClient = http.Client(); // reopen client
      _statusMsg = "Response cancelled.";
      _chatStatus = ChatStatus.cancelled;
      addBotMessage(_statusMsg!);
    }
  }

  @override
  void dispose() {
    _httpClient?.close();
    _queryBox.close();
    super.dispose();
  }

  void setTopicContent(String content) {
    _topicContent = content;
    _isTopicLoading = false;
    notifyListeners();
  }


  Future<List<String>> generateRecommendations(
    UserModel user,
    List<TopicsData> concepts,
    Map<String, ConceptProgress> progress,
  ) async {
    if (_recommendedIds != null && _recommendedIds!.isNotEmpty) {
    return _recommendedIds!;
  }

    final box = Hive.box('userBox');
    final cached = box.get('recommendedTopics');
    if (cached != null && cached is List<String>) {
      _recommendedIds = List<String>.from(cached.map((item)=>item.toString()));
      return _recommendedIds!;
    }
    String prompt = """
You are Nexus, an AI learning assistant designed to help users master programming concepts step-by-step.

The user has completed the following concepts:
${user.completedTopics.isEmpty ? "None yet" : user.completedTopics.join(', ')}.

Here is the list of all available concepts with their details:
IDs: ${concepts.map((c) => c.id).toList()}
Names: ${concepts.map((c) => c.topicName).toList()}

User’s current learning progress:
${progress.entries.map((entry) {
      final id = entry.key;
      final prog = entry.value.progress;
      final lastAccess = entry.value.lastAccessed;
      final isCompleted = entry.value.isCompleted;
      return "• Concept ID: $id | Progress: ${prog.toStringAsFixed(2)}% | Last Accessed: $lastAccess | Completed: $isCompleted";
    }).join('\n')}

Objective:
Based on the user’s progress, learning pattern, and completed concepts, recommend the next 3 most relevant concepts that the user should study next.

Rules:
1. Do NOT recommend any concept that is already completed.
2. Focus on gradual skill-building — recommend the next logical concepts that help the user progress smoothly.
3. If the user is a beginner, start with simpler concepts. If the user has completed several intermediate topics, recommend more advanced ones.
4. Return ONLY the list of concept IDs in this **exact format**:
[C0004, C0005, C0006]

No explanations or additional text — just the list.
""";
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${Secrets.apiKey}",
    );
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            "No content";
        final ids =
            text
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll(' ', '')
                .split(',')
                .map((id) => id.trim())
                .where((id) => id.isNotEmpty)
                .toList();
        debugPrint(ids.toString());
        box.put("recommendedTopics", ids);
        await Future.delayed(Duration(seconds: 1));
        return ids;
      } else {
        throw Exception("No Recommendations");
      }
    }on http.Client {
      throw Exception("Check Your Connection");
    }on SocketException{
      throw Exception("Socket Exception");
    }catch(e){
      throw Exception("Unknown Exception");
    }
  }

  Future<void> generateTopicContent(String prompt) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${Secrets.apiKey}",
    );

    try {
      _isTopicLoading = true;
      _topicContent = "Generating content...";
      notifyListeners();

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _topicContent =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            "No content";
      } else {
        final errorBody = jsonDecode(response.body);
        String errorMessage =
            errorBody['error']?['message'] ?? "Unknown API error";
        _topicContent = "Error fetching content: $errorMessage";
      }
    }on http.Client {
      throw Exception("Check Your Connection");
    }on SocketException{
      throw Exception("Socket Exception");
    }
     catch (e) {
      _topicContent = "Network Error: $e";
    } finally {
      _isTopicLoading = false;
      notifyListeners();
    }
  }
}
