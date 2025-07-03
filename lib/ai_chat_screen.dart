import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lottie/lottie.dart';
import 'utils.dart';

class AIChatScreen extends StatefulWidget {
  final String cropName;
  final String diseaseName;
  final String severity;

  const AIChatScreen({
    Key? key,
    required this.cropName,
    required this.diseaseName,
    required this.severity,
  }) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  // Replace with your actual Gemini API key
  final String apiKey = "AIzaSyDu9y58GS5Wy8iGGFonZPRC8-SuwHL3YIs";
  late GenerativeModel model;
  late ChatSession chatSession;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _askInitialQuestion();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeGemini() {
    try {
      model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
      );

      chatSession = model.startChat();
    } catch (e) {
      debugPrint('Error initializing Gemini: $e');
    }
  }

  Future<void> _askInitialQuestion() async {
    // Use capitalized names for better AI response
    String cropFormatted = widget.cropName[0].toUpperCase() + widget.cropName.substring(1).toLowerCase();
    String diseaseFormatted = widget.diseaseName[0].toUpperCase() + widget.diseaseName.substring(1).toLowerCase();

    String initialQuestion = "How can I treat $cropFormatted plants affected by $diseaseFormatted with a disease severity of ${widget.severity}? Please provide detailed steps for treatment, necessary precautions, and prevention tips for future. Format your response with bullet points and use **bold text** (with double asterisks without backslashes) for important terms and headings.";

    setState(() {
      _messages.add(ChatMessage(
        text: initialQuestion,
        isUser: true,
      ));
      _isTyping = true;
    });

    await _sendMessage(initialQuestion);
  }

  Future<void> _sendMessage(String text) async {
    try {
      if (text.trim().isEmpty) return;

      if (_messages.length == 1) {
        // Skip adding the message again if it's the initial question
      } else {
        setState(() {
          _messages.add(ChatMessage(
            text: text,
            isUser: true,
          ));
        });
      }

      _messageController.clear();

      setState(() {
        _isTyping = true;
      });

      // Scroll to the bottom
      _scrollToBottom();

      final response = await chatSession.sendMessage(Content.text(text));
      String responseText = response.text ?? "Sorry, I couldn't generate a response. Please try again.";

      // Clean up escaped asterisks in the response if needed
      responseText = responseText.replaceAll(r'\*\*', '**');

      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: responseText,
          isUser: false,
        ));
      });

      // Scroll to the bottom again after receiving response
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: "Error: $e",
          isUser: false,
        ));
      });
      debugPrint('Error sending message: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = const Color(0xffe9edf1);
    Color accentColor = const Color(0xff2d5765);

    // Format the display name for cleaner UI
    String displayName = widget.diseaseName;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: accentColor,
        title: const Text(
          'AI Treatment Assistant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Neumorphic(
              style: NeumorphicStyle(
                depth: -2,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disease: ${widget.diseaseName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Plant: ${widget.cropName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Severity: ${widget.severity}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.severity.startsWith("7") || widget.severity.startsWith("8") || widget.severity.startsWith("9")
                            ? Colors.red.shade800
                            : widget.severity.startsWith("5") || widget.severity.startsWith("6")
                                ? Colors.orange.shade800
                                : Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _messages.isEmpty && _isTyping
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/plant.json',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Analyzing your ${widget.cropName}...",
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(
                        message: _messages[index],
                        backgroundColor: backgroundColor,
                        accentColor: accentColor,
                      );
                    },
                  ),
          ),
          if (_isTyping && _messages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  Text(
                    "AI is typing",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      depth: -2,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ask a follow-up question...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: _isTyping ? null : _sendMessage,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                NeumorphicButton(
                  style: NeumorphicStyle(
                    color: accentColor,
                    boxShape: const NeumorphicBoxShape.circle(),
                  ),
                  onPressed: _isTyping ? null : () => _sendMessage(_messageController.text),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Color backgroundColor;
  final Color accentColor;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.backgroundColor,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundColor: accentColor,
                radius: 16,
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          Flexible(
            child: Neumorphic(
              style: NeumorphicStyle(
                depth: message.isUser ? 2 : -2,
                intensity: 0.8,
                color: message.isUser ? accentColor : Colors.white,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: message.isUser
                    ? Text(
                        message.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )
                    : SelectableText.rich(
                        formatMessageText(
                          message.text,
                          isUser: message.isUser,
                        ),
                        // Make text selectable for copying
                        toolbarOptions: const ToolbarOptions(
                          copy: true,
                          selectAll: true,
                          cut: false,
                          paste: false,
                        ),
                      ),
              ),
            ),
          ),
          if (message.isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade700,
                  size: 20,
                ),
                radius: 16,
              ),
            ),
        ],
      ),
    );
  }
}
