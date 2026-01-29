import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../blocs/chat/chat_bloc.dart';
import 'package:fortnite_squads/domain/entities/message.dart';

class SquadChatScreen extends StatefulWidget {
  final String squadId;
  final String squadName;

  const SquadChatScreen({
    super.key,
    required this.squadId,
    required this.squadName,
  });

  @override
  State<SquadChatScreen> createState() => _SquadChatScreenState();
}

class _SquadChatScreenState extends State<SquadChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadMessages(widget.squadId));
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    context.read<ChatBloc>().add(
          SendMessagePressed(
            squadId: widget.squadId,
            text: _textController.text,
          ),
        );
    _textController.clear();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      context.read<ChatBloc>().add(
            SendImagePressed(squadId: widget.squadId, image: File(image.path)),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.squadName)),
      body: Column(
        children: [
          // --- Message List ---
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatLoaded) {
                  return ListView.builder(
                    reverse: true, // Scroll from bottom
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      return _MessageBubble(message: state.messages[index]);
                    },
                  );
                }
                return const Center(child: Text("Start the conversation!"));
              },
            ),
          ),

          // --- Input Area ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            color: Theme.of(context).cardColor,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: "Message squad...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe =
        message.senderId == 'me'; // Replace with actual current user ID check

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[700] : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(message.senderName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white70)),
            if (message.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Image.network(message.imageUrl!,
                    height: 150, fit: BoxFit.cover),
              ),
            if (message.text != null)
              Text(message.text!, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
