import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';

// Key for detecting hot restart
const String _kHotRestartKey = 'coach_hot_restart_timestamp';

class CoachScreen extends StatefulWidget {
  CoachScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = false;
  final AIService _aiService = AIService();
  bool _showExample = true; // Track whether to show the example text

  // Key for SharedPreferences storage
  static const String CHAT_HISTORY_KEY = 'coach_chat_history';
  static const Duration MESSAGE_EXPIRY = Duration(hours: 12);

  // For streaming responses
  StreamSubscription? _streamSubscription;
  String _currentStreamedResponse = "";

  // For typing indicator animation
  late AnimationController _typingAnimationController;
  late Animation<int> _typingDotsAnimation;

  // For showing copy toast
  OverlayEntry? _overlayEntry;

  void _showCopyToast(String message) {
    // Remove any existing overlay first
    _dismissCopyToast();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.8),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-dismiss after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      _dismissCopyToast();
    });
  }

  void _dismissCopyToast() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    _showCopyToast('Copied to clipboard');
  }

  // Check if app is reloaded from terminal
  Future<bool> _isHotRestarted() async {
    // Always return false in release mode
    if (!kDebugMode) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      final lastTimestamp = prefs.getInt(_kHotRestartKey) ?? 0;

      // If it's been less than 5 seconds since last timestamp, it's likely a hot restart
      final isHotRestart = (now - lastTimestamp) < 5000;

      // Update the timestamp for next detection
      await prefs.setInt(_kHotRestartKey, now);

      if (isHotRestart) {
        print('Hot restart detected - resetting chat');
      }

      return isHotRestart;
    } catch (e) {
      print('Error detecting hot restart: $e');
      return false;
    }
  }

  // Load chat history from SharedPreferences
  Future<void> _loadChatHistory() async {
    try {
      // Check for hot restart first
      bool hotRestarted = await _isHotRestarted();

      // If hot restarted, reset chat and don't load history
      if (hotRestarted) {
        setState(() {
          _messages = [
            Message(text: 'Hey! How can I help you?', isFromUser: false),
          ];
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final String? chatHistoryJson = prefs.getString(CHAT_HISTORY_KEY);

      if (chatHistoryJson != null) {
        // Decode the JSON string to a list of messages
        final List<dynamic> decodedMessages = jsonDecode(chatHistoryJson);

        // Get current time to filter out expired messages
        final now = DateTime.now();

        // Convert each message and filter out expired ones
        List<Message> loadedMessages = decodedMessages
            .map((msgMap) => Message.fromJson(msgMap))
            .where((message) {
          // Keep messages that are less than 12 hours old
          final messageAge = now.difference(message.timestamp);
          return messageAge < MESSAGE_EXPIRY;
        }).toList();

        // If there are any valid messages, update the state
        if (loadedMessages.isNotEmpty) {
          setState(() {
            _messages = loadedMessages;
            // Hide example text since we're loading existing chat
            _showExample = false;
          });

          // Schedule a scroll to bottom after rendering
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());

          print('Loaded ${_messages.length} messages from chat history');
        } else {
          print('No recent messages found in history');
          // Initialize with just the coach message if no valid messages
          setState(() {
            _messages = [
              Message(text: 'Hey! How can I help you?', isFromUser: false),
            ];
          });
        }

        // Clean up expired messages in SharedPreferences
        _cleanupExpiredMessages(decodedMessages);
      } else {
        // If no chat history exists, start with default message
        setState(() {
          _messages = [
            Message(text: 'Hey! How can I help you?', isFromUser: false),
          ];
        });
      }
    } catch (e) {
      print('Error loading chat history: $e');
      // Fallback to default message if there's an error
      setState(() {
        _messages = [
          Message(text: 'Hey! How can I help you?', isFromUser: false),
        ];
      });
    }
  }

  // Save chat history to SharedPreferences
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert messages to JSON
      final List<Map<String, dynamic>> messagesJson =
          _messages.map((msg) => msg.toJson()).toList();

      // Save to SharedPreferences
      await prefs.setString(CHAT_HISTORY_KEY, jsonEncode(messagesJson));
      print('Saved ${_messages.length} messages to chat history');
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  // Clean up expired messages to avoid storage buildup
  Future<void> _cleanupExpiredMessages(List<dynamic> allMessages) async {
    try {
      final now = DateTime.now();
      final validMessages = allMessages.where((msgMap) {
        final timestamp = DateTime.parse(msgMap['timestamp']);
        return now.difference(timestamp) < MESSAGE_EXPIRY;
      }).toList();

      if (validMessages.length < allMessages.length) {
        // If we filtered out any messages, save the updated list
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(CHAT_HISTORY_KEY, jsonEncode(validMessages));
        print(
            'Cleaned up ${allMessages.length - validMessages.length} expired messages');
      }
    } catch (e) {
      print('Error cleaning up expired messages: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // Load chat history from storage
    _loadChatHistory();

    // Set up typing animation
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _typingDotsAnimation = IntTween(begin: 0, end: 3).animate(
      CurvedAnimation(
        parent: _typingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    // Save chat history when leaving the screen
    _saveChatHistory();

    _textController.dispose();
    _scrollController.dispose();
    _streamSubscription?.cancel();
    _typingAnimationController.dispose();
    _aiService.dispose();
    _dismissCopyToast();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Send a message and get AI response
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Hide example text after first message is sent
    if (_showExample) {
      setState(() {
        _showExample = false;
      });
    }

    // Create a message with current timestamp
    final userMessage = Message(text: text, isFromUser: true);

    // Add the user's message immediately
    setState(() {
      _messages.add(userMessage);
      _textController.clear();
      _isLoading = true; // Show loading indicator
    });

    // Scroll to bottom to show newest message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      // Create a completely new list with only the necessary data
      final List<Map<String, String>> safeMessages = [];

      // Add each message as a simple map with only role and content
      for (final msg in _messages) {
        safeMessages.add({
          'role': msg.isFromUser ? 'user' : 'assistant',
          'content': msg.text,
        });
      }

      print(
          'Sending message to AI service with ${safeMessages.length} messages');

      // Reset current streamed response
      _currentStreamedResponse = "";

      // Start streaming the response
      final messageStream = _aiService.streamAIResponse(safeMessages);

      // Cancel any previous subscription
      _streamSubscription?.cancel();

      // Listen to the stream of tokens
      _streamSubscription = messageStream.listen(
        (token) {
          // Add token to the current response
          _currentStreamedResponse += token;

          setState(() {
            // If we're still showing the typing indicator
            if (_isLoading) {
              // Remove typing indicator and add actual message
              _isLoading = false;
              _messages.add(Message(
                text: _currentStreamedResponse,
                isFromUser: false,
              ));
            } else {
              // Update existing message with new content
              if (_messages.isNotEmpty && !_messages.last.isFromUser) {
                // Create a new message with the updated text but preserve the timestamp
                final DateTime originalTimestamp = _messages.last.timestamp;
                final updatedMessage = Message(
                  text: _currentStreamedResponse,
                  isFromUser: false,
                );

                // Apply the original timestamp (this is a bit of a hack but works for streaming updates)
                _messages[_messages.length - 1] = updatedMessage;
              } else {
                // Fallback: add new message if somehow we don't have one
                _messages.add(Message(
                  text: _currentStreamedResponse,
                  isFromUser: false,
                ));
              }
            }
          });

          // Scroll to bottom as content grows
          _scrollToBottom();
        },
        onDone: () {
          // Streaming is complete
          setState(() {
            _isLoading = false;
          });
          _streamSubscription = null;

          // Save chat history after receiving a complete response
          _saveChatHistory();
        },
        onError: (error) {
          print('Error streaming AI response: $error');

          setState(() {
            _isLoading = false;
            _messages.add(Message(
              text: 'Sorry, there was an error. Please try again.',
              isFromUser: false,
            ));
          });
          _streamSubscription = null;

          // Also save chat history after error (to save the error message)
          _saveChatHistory();
        },
      );
    } catch (e) {
      print('Error starting AI response stream: $e');
      String errorMessage = 'Sorry, I couldn\'t process your request.';

      if (e.toString().contains('network')) {
        errorMessage += ' Please check your internet connection.';
      } else if (e.toString().contains('timeout')) {
        errorMessage += ' The request timed out. Please try again.';
      } else if (e.toString().contains('unauthorized')) {
        errorMessage += ' Authentication failed. Please contact support.';
      }

      setState(() {
        _messages.add(Message(
          text: errorMessage,
          isFromUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background4.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Fixed header section that doesn't scroll
                Column(
                  children: [
                    // Header with coach info and back button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 29)
                          .copyWith(top: 16, bottom: 8.5),
                      child: Stack(
                        children: [
                          // Back button
                          Positioned(
                            left: 0,
                            top: 22,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black, size: 24),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ),

                          // Coach info centered
                          Row(
                            children: [
                              // Space where back button would normally be
                              SizedBox(width: 24),

                              // Coach image
                              Image.asset(
                                'assets/images/coachpfp.png',
                                width: 68,
                                height: 68,
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Coach',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SF Pro Display',
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 1.6),
                                  Text(
                                    'Active now',
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontSize: 16,
                                      color: const Color(0x7f000000),
                                      fontFamily: 'SFProDisplay-Regular',
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Top divider - this is our clipping boundary
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 29),
                      height: 0.5,
                      color: Color(0xFFBDBDBD),
                    ),
                  ],
                ),

                // Chat section - scrollable with proper padding
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Fixed top padding to position first bubble properly
                      SliverToBoxAdapter(
                        child: SizedBox(height: 20),
                      ),

                      // Messages list
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // If we're at the last position and loading, show thinking bubble
                            if (_isLoading && index == _messages.length) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 20, left: 29, right: 29),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        minWidth: 0,
                                      ),
                                      child: Material(
                                        elevation: 0,
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: Offset(0, 5),
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            child: _buildTypingIndicator(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Regular message
                            final message = _messages[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 20, left: 29, right: 29),
                              child: Row(
                                mainAxisAlignment: message.isFromUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.7,
                                      minWidth: 0,
                                    ),
                                    child: GestureDetector(
                                      onTap: () =>
                                          _copyToClipboard(message.text),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: message.isFromUser
                                              ? Colors.black
                                              : Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: Offset(0, 5),
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          child: _buildRichText(
                                            message.text,
                                            message.isFromUser,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: _isLoading
                              ? _messages.length + 1
                              : _messages.length,
                        ),
                      ),

                      // Bottom padding
                      SliverToBoxAdapter(
                        child: SizedBox(height: 20),
                      ),
                    ],
                  ),
                ),

                // Input area below chat (fixed, non-scrolling)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Example text if needed
                    if (_showExample)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 11),
                        child: Center(
                          child: Text(
                            'Example: How many calories are in a banana?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ),
                      ),

                    // Bottom divider
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 29),
                      height: 0.5,
                      color: Color(0xFFBDBDBD),
                    ),

                    // Input field and send button
                    Padding(
                      padding: EdgeInsets.fromLTRB(29, 14, 29, 20),
                      child: Row(
                        children: [
                          // Text input field
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: TextField(
                                controller: _textController,
                                cursorColor: Colors.black,
                                cursorWidth: 1.2,
                                style: TextStyle(
                                  fontSize: 13.6,
                                  fontFamily: '.SF Pro Display',
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Aa',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600]!.withOpacity(0.7),
                                    fontSize: 13.6,
                                    fontFamily: '.SF Pro Display',
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 15),
                                ),
                                onSubmitted: (text) {
                                  _sendMessage();
                                },
                              ),
                            ),
                          ),

                          // Send button
                          GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              width: 26,
                              height: 26,
                              child: Image.asset(
                                'assets/images/send.png',
                                width: 26,
                                height: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRichText(String text, bool isFromUser) {
    // Pre-process the text to remove any unwanted quotation marks
    text = text.replaceAll('"', '');

    final List<TextSpan> spans = [];
    int lastIndex = 0;

    // Process all formatting patterns in one pass
    final RegExp combinedPattern = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*');
    final matches = combinedPattern.allMatches(text);

    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      final matchText = match.group(0)!;

      // Add text before the formatted part
      if (start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, start),
          style: TextStyle(
            fontSize: 16,
            color: isFromUser ? Colors.white : Colors.black,
          ),
        ));
      }

      // Check if it's a bold pattern (double asterisks) or medium pattern (single asterisk)
      if (matchText.startsWith('**') && matchText.endsWith('**')) {
        // Bold text (double asterisks)
        spans.add(TextSpan(
          text: match.group(1), // Extract the content between **
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isFromUser ? Colors.white : Colors.black,
          ),
        ));
      } else if (matchText.startsWith('*') && matchText.endsWith('*')) {
        // Medium text (single asterisk)
        // We need to get the content between the single asterisks
        final content = matchText.substring(1, matchText.length - 1);
        spans.add(TextSpan(
          text: content,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isFromUser ? Colors.white : Colors.black,
          ),
        ));
      }

      lastIndex = end;
    }

    // Add remaining text after the last match
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(
          fontSize: 16,
          color: isFromUser ? Colors.white : Colors.black,
        ),
      ));
    }

    // If no formatting was found at all, just return the plain text
    if (spans.isEmpty) {
      spans.add(TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 16,
          color: isFromUser ? Colors.white : Colors.black,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  // Build animated typing indicator
  Widget _buildTypingIndicator() {
    return AnimatedBuilder(
        animation: _typingDotsAnimation,
        builder: (context, child) {
          final dots = '.' * _typingDotsAnimation.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
              SizedBox(width: 8),
              Text(
                "Thinking$dots",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          );
        });
  }
}

// Message class to store message data
class Message {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;

  Message({required this.text, required this.isFromUser})
      : timestamp = DateTime.now();

  Message.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        isFromUser = json['isFromUser'],
        timestamp = DateTime.parse(json['timestamp']);

  Map<String, dynamic> toJson() => {
        'text': text,
        'isFromUser': isFromUser,
        'timestamp': timestamp.toIso8601String(),
      };
}
