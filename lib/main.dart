import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot POC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D6550),
          primary: const Color(0xFF1D6550),
          // ignore: deprecated_member_use
          background: const Color(0xFFF3F3F3),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F3F3),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'POC Chatbot'),
    );
  }
}

enum ChatMessageType { text, buttonOptions }

class ChatMessage {
  final String text;
  final bool isUser;
  final ChatMessageType type;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.type = ChatMessageType.text,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isChatOpen = false;

  void _openChat() {
    setState(() {
      _isChatOpen = true;
      _messages = [
        ChatMessage(text: "Olá! Eu sou seu assistente.", isUser: false),
        ChatMessage(
          text: "Escolha uma das opções abaixo:",
          isUser: false,
          type: ChatMessageType.buttonOptions,
        ),
      ];
    });
    _scrollToBottom();
  }

  void _closeChat() {
    setState(() {
      _isChatOpen = false;
    });
  }

  void _sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: trimmed, isUser: true));
      _controller.clear();
    });

    _processUserMessage(trimmed);
  }

  void _processUserMessage(String text) {
    Future.delayed(const Duration(milliseconds: 300), () {
      final lower = text.toLowerCase();

      String resposta;
      if (lower.contains('café') ||
          lower.contains('cafe') ||
          lower.contains('transporte')) {
        resposta = "Solicitação de transporte de café registrada!";
      } else if (lower.contains('visita') ||
          lower.contains('agrônomo') ||
          lower.contains('agronomo')) {
        resposta = "Visita técnica com agrônomo registrada!";
      } else {
        resposta =
            "Não entendi. Escolha uma das opções ou digite 'café' ou 'visita'.";
      }

      setState(() {
        _messages.add(ChatMessage(text: resposta, isUser: false));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(ChatMessage msg) {
    if (msg.type == ChatMessageType.buttonOptions && !msg.isUser) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 6),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: Colors.white, // Balão do bot
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Escolha uma das opções:"),
              const SizedBox(height: 8),

              // Botão expansível "Agendamentos"
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(left: 8, bottom: 8),
                  title: Row(
                    children: const [
                      Icon(Icons.event, color: Colors.black87),
                      SizedBox(width: 8),
                      Text("Agendamentos"),
                    ],
                  ),
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          _sendMessage("Solicitar transporte de café"),
                      icon: const Icon(Icons.local_shipping),
                      label: const Text("Solicitar transporte de café"),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _sendMessage("Solicitar visita técnica com agrônomo"),
                      icon: const Icon(Icons.agriculture),
                      label: const Text(
                        "Solicitar visita técnica com agrônomo",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? const Color(0xFF1D6550) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg.text,
          style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildChat() {
    return SafeArea(
      child: Column(
        children: [
          // Header do chat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF1D6550),
            child: Row(
              children: [
                const Icon(Icons.chat, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Assistente de Agendamento',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _closeChat,
                ),
              ],
            ),
          ),

          // Mensagens
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),

          // Campo de input
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isChatOpen
          ? _buildChat()
          : const Center(child: Text("Clique no botão para abrir o chat.")),
      floatingActionButton: _isChatOpen
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF1D6550),
              onPressed: _openChat,
              child: const Icon(Icons.chat, color: Colors.white),
            ),
    );
  }
}
