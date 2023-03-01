import 'dart:developer';

import 'package:chat_gpt/constants/constants.dart';
import 'package:chat_gpt/providers/chats_provider.dart';
import 'package:chat_gpt/providers/models_provider.dart';
import 'package:chat_gpt/services/assets_manager.dart';
import 'package:chat_gpt/services/services.dart';
import 'package:chat_gpt/widgets/chat_widget.dart';
import 'package:chat_gpt/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  TextEditingController _textEditingController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatsProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.openaiLogo),
        ),
        title: const Text("ChatGPT"),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(context: context);
            },
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: chatsProvider.getChatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                      msg: chatsProvider.getChatList[index].msg,
                      chatIndex: chatsProvider.getChatList[index].chatIndex,
                    );
                  }),
            ),
            const SizedBox(
              height: 8,
            ),
            Material(
              color: cardColor,
              child: ListTile(
                title: TextField(
                  controller: _textEditingController,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                  onSubmitted: (value) async {
                    await sendMessageFCT(
                        modelsProvider: modelsProvider,
                        chatProvider: chatsProvider);
                  },
                  decoration: const InputDecoration.collapsed(
                    hintText: "How can I help you",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                trailing: _isTyping
                    ? const SizedBox(
                      height: 24.0,
                      width: 28.0,
                      child: SpinKitThreeBounce(
                          color: Colors.white,
                          size: 18,
                        ),
                    )
                    : IconButton(
                        onPressed: () async {
                          await sendMessageFCT(
                              modelsProvider: modelsProvider,
                              chatProvider: chatsProvider);
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please type a message",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isTyping = true;
      chatProvider.addUserMessage(
        msg: _textEditingController.text,
      );
      _textEditingController.clear();
      _focusNode.unfocus();
    });
    try {
      final msg = _textEditingController.text;
      await chatProvider.sendMessageAndGetAnswers(
        msg: msg,
        chosenModelId: modelsProvider.getCurrentModel,
      );

      setState(() {});
    } catch (err) {
      log(err.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            label: err.toString(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      scrollListToEND();
      setState(() {
        _isTyping = false;
      });
    }
  }

  void scrollListToEND() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.easeOut,
    );
  }
}
