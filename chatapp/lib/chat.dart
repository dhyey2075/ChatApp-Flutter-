import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Chat extends StatefulWidget {
  late String username;
  Chat({super.key, required this.username});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String user = "Anonymous";
  final IO.Socket _socket = IO.io("https://chatappbackend-0thq.onrender.com/", IO.OptionBuilder().setTransports(['websocket']).build());

  _connectToSocket() {
    _socket.onConnect((_) {
      print("Connected to Socket Server");
    });
    _socket.onConnectError((data) {
      print("Connection Error: $data");
    });
    _socket.onDisconnect((_) {
      print("Disconnected from Socket Server");
    });
    _socket.on('message', (data) {
      print("Here");
      setState(() {
        messages.add({
          "text": data['message'],
          "sender": data['sender'],
          "time": data['time']
        });
        print(data);
      });
    });
    _socket.on('joined', (data) {
      print("Joined");
      print(data);
    });
  }

  @override
  void initState() {
    super.initState();
    _connectToSocket();
  }
  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  final TextEditingController messageController = TextEditingController();
  final List<Map<String, String>> messages = [
    {"text": "Hello", "sender": "Alice", "time": "10:00 AM"},
    {"text": "Hi there!", "sender": "Bob", "time": "10:01 AM"},
    {"text": "How are you?", "sender": "Alice", "time": "10:02 AM"},
    {"text": "I'm good, thanks!", "sender": "Bob", "time": "10:03 AM"},
    {"text": "What's up?", "sender": "Alice", "time": "10:04 AM"},
  ];

  void _sendMessage() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        // messages.add({
        //   "text": messageController.text,
        //   "sender": "You",
        //   "time": "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}"
        // });
        _socket.emit('message',{
          'message': messageController.text,
          'sender': widget.username,
          'time': "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}"
        }); 
        messageController.clear();
      });
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.chat_outlined),
        title: const Text("Chat App"),
        backgroundColor: Colors.blue[400],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isSentByMe = messages[index]['sender'] == widget.username;
                return _buildMessage(
                  messages[index]['text']!,
                  messages[index]['sender']!,
                  messages[index]['time']!,
                  isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                  isSentByMe ? Colors.blue[300]! : Colors.grey[600]!,
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20, right: 20, bottom: 20, left: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your Message here...',
                      focusColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.blue[400],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, String sender, String time, Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(minWidth: 100),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: alignment == Alignment.centerRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender == widget.username ? "You" : sender,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            // const SizedBox(height: 5),
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            // const SizedBox(height: 5),
            Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
