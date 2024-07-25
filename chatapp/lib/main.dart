import 'package:flutter/material.dart';
import 'package:chatapp/chat.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? username = "Anonymous";
  IO.Socket? _socket;
  final TextEditingController nameController = TextEditingController();

  void _connectToSocket(String u) {
    _socket = IO.io(
        "https://chatappbackend-0thq.onrender.com/",
        IO.OptionBuilder()
            .setQuery({'username': u}).setTransports(['websocket']).build());
    _socket!.onConnect((_) {
      print("Connected to Socket Server");
    });
    _socket!.onConnectError((data) {
      print("Connection Error: $data");
    });
    _socket!.onDisconnect((_) {
      print("Disconnected from Socket Server");
    });
  }

  @override
  void initState() {
    super.initState();
  }
  void _showSnackBar() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text('Added to favorite'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            scaffoldMessenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: const Icon(Icons.chat_outlined),
            title: const Text("Chat App"),
            backgroundColor: Colors.blue[400],
          ),
          body: Container(
            margin: const EdgeInsets.all(30),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Enter your Name: ",
                      style: TextStyle(fontSize: 25)),
                  const SizedBox(height: 30),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                      focusColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      username = nameController.text;
                      print(username);
                      _connectToSocket(username!);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Chat(username: username!)),
                      );
                    },
                    child: const Text("Start Chat"),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue[300])),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      // home: Chat(),
    );
  }
}
