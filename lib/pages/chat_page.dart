import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prueba_chat/components/chat_bubble.dart';
import 'package:prueba_chat/components/my_textfield.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String recieverEmail;
  final String receiverId;

  const ChatPage({
    super.key, 
    required this.recieverEmail, 
    required this.receiverId
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final TextEditingController messageController = TextEditingController();
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  FocusNode myFocusNode = FocusNode();

  @override
  void initState(){
    super.initState();

    myFocusNode.addListener(() {
      if(myFocusNode.hasFocus){
        Future.delayed(const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    if(messageController.text.isNotEmpty) {
      await chatService.sendMessage(widget.receiverId, messageController.text);
      messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 1,
        title: Text("Chateando con: ${widget.recieverEmail}"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10,),
          Expanded(
            child: buildMessageList(),
          ),
          buildUserInput(),
        ],
      ),
    );
  }
  
  Widget buildMessageList() {
    String senderId = authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: chatService.getMessages(widget.receiverId, senderId), 
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error", style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading..", style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ));
        }
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((doc) => 
            buildMessageItem(doc)).toList(),
        );
      }
    );
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // alignment according to user side
    bool isCurrentUser = data['senderId'] == authService.getCurrentUser()!.uid;
    var alignment =
      isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data['message'], 
            isCurrentUser: isCurrentUser,
            messageId: doc.id,
            userId: data['senderId'],
          ),
          const SizedBox(height: 3,)
        ],
      ),
    );
  }

  Widget buildUserInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: MyTextfield(
              focusNode: myFocusNode,
              controller: messageController,
              hintText: "Escribe un mensaje",
              obscureText: false,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiary,
                )
            ),
            child: IconButton(
              iconSize: 30,
              focusColor: Colors.blue,
              color: Colors.black,
              onPressed: sendMessage, 
              icon: Icon(
                Icons.arrow_upward,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 25,),
        ],
      ),
    );
  }
}