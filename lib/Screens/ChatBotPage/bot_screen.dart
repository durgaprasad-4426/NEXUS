import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nexus/Providers/chart_provider.dart';
import 'package:nexus/Screens/ChatBotPage/isTypeing.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String greetingMessage = "";
  bool _greetingVisible = true;

  @override
  void initState() {
    super.initState();
    _setGreeting();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greetingMessage =
          "Rise and shine! Which DSA challenge are we solving today?";
    } else if (hour < 18) {
      greetingMessage =
          "Good afternoon, coder! Ready to conquer some DSA topic today?";
    } else {
      greetingMessage = "Good evening! Ready to level up your DSA skills?";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleSend(ChatProvider chatProvider) {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() => _greetingVisible = false);
      chatProvider.addUserMessage(text);
      _controller.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_greetingVisible || chatProvider.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    final bool isInputReadOnly =
        chatProvider.isTyping ||
        chatProvider.chatStatus == ChatStatus.generating ||
        chatProvider.chatStatus == ChatStatus.limitExceeded ||
        chatProvider.chatStatus == ChatStatus.error;
    final bool isSendButtonDisabled =
        isInputReadOnly && chatProvider.chatStatus != ChatStatus.cancelled;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [Colors.purple, Colors.cyan, Colors.greenAccent],
              ).createShader(bounds),
          child: const Text(
            "Nexus",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                //subscription page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Chatbot',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_greetingVisible && chatProvider.messages.isEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.purpleAccent,
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  greetingMessage,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 6,
              radius: const Radius.circular(10),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: chatProvider.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatProvider.messages[index];
                  final isUser = msg['role'] == 'user';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth:
                              isUser
                                  ? MediaQuery.of(context).size.width * 0.7
                                  : MediaQuery.of(context).size.width * 0.9,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient:
                              isUser
                                  ? const LinearGradient(
                                    colors: [
                                      Color(0xFF6a11cb),
                                      Color(0xFF2575fc),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                  : const LinearGradient(
                                    colors: [
                                      Color(0xFF1a1a1a),
                                      Color(0xFF333333),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isUser
                                      ? Colors.purpleAccent.withOpacity(0.5)
                                      : Colors.black26,
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: SelectableRegion(
                          focusNode: FocusNode(),
                          selectionControls: materialTextSelectionControls,
                          child: MarkdownBody(
                            data: msg['content'] ?? "",
                            styleSheet: MarkdownStyleSheet(
                              h1: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.tealAccent,
                              ),
                              h2: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent,
                              ),
                              h3: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.cyanAccent,
                              ),
                              p: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              listBullet: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            onTapLink: (text, href, title) async {
                              if (href != null) {
                                final uri = Uri.parse(href);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.inAppWebView,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (chatProvider.statusMsg != null &&
              chatProvider.statusMsg!.isNotEmpty &&
              chatProvider.chatStatus != ChatStatus.generating)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Text(
                chatProvider.statusMsg!,
                style: TextStyle(
                  color:
                      chatProvider.chatStatus == ChatStatus.error ||
                              chatProvider.chatStatus ==
                                  ChatStatus.limitExceeded
                          ? Colors.redAccent
                          : Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (chatProvider.chatStatus == ChatStatus.generating)
            const TypingIndicator(),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.6)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: isInputReadOnly,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText:
                          chatProvider.chatStatus == ChatStatus.limitExceeded
                              ? "Daily limit reached."
                              : "Ask Anything About DSA",
                      hintStyle: TextStyle(
                        color:
                            chatProvider.chatStatus == ChatStatus.limitExceeded
                                ? Colors.redAccent.withOpacity(0.5)
                                : Colors.white38,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: isSendButtonDisabled ? null : (_)=>  _handleSend(chatProvider),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                IconButton(
                  icon: chatProvider.chatStatus == ChatStatus.generating 
                  ? const Icon(Iconsax.stop, color: Colors.redAccent)
                  : Icon(Iconsax.send_2, color: Colors.cyanAccent),
                  onPressed:isSendButtonDisabled
                  ? null
                  :(){
                    if(chatProvider.chatStatus == ChatStatus.generating){
                      chatProvider.cancelCurrentLLMResponse();
                    }else{
                      _handleSend(chatProvider);
                    }
                   }
                    
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
