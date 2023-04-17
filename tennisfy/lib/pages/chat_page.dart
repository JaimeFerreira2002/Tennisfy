import 'package:flutter/material.dart';
import 'package:tennisfy/helpers/auth.dart';
import 'package:tennisfy/models/message_model.dart';
import 'package:tennisfy/pages/profile_page.dart';
import '../helpers/helper_methods.dart';
import '../helpers/media_query_helpers.dart';
import '../helpers/services/firebase_getters.dart';

class ChatPage extends StatefulWidget {
  String userUID; //uid of the user we are talking to
  String chatID;

  ChatPage({Key? key, required this.userUID, required this.chatID})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _newMessageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.primary,
            )),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
          child: GestureDetector(
            onTap: () {
              goToPage(context, ProfilePage(userUID: widget.userUID));
            },
            child: Row(
              children: [
                FutureBuilder(
                  future: getProfileImageURL(widget.userUID),
                  initialData: "Loading...",
                  builder: ((context, AsyncSnapshot<String> snapshot) {
                    return CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage: snapshot.data != null
                            ? Image.network(snapshot.data!).image
                            : Image.network(
                                    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png")
                                .image);
                  }),
                ),
                SizedBox(
                  width: displayWidth(context) * 0.04,
                ),
                FutureBuilder(
                  future: getUserFullName(widget.userUID),
                  initialData: "Loading...",
                  builder: ((context, AsyncSnapshot<String> snapshot) {
                    return Text(
                      snapshot.data!,
                      style: const TextStyle(fontSize: 24),

                      //here we need a costum text style, non of the establushed fits good
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          child: Container(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.2), // choose your desired color
            height: 1.5, // choose your desired height
          ),
          preferredSize: const Size.fromHeight(0.0),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          children: [
            Expanded(
                child: Container(
              child: StreamBuilder(
                  stream: getMessagesStream(widget.chatID),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Message>> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final messagesList = snapshot.data!;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messagesList.length,
                      itemBuilder: (context, index) {
                        final Message message = messagesList[index];
                        final bool hasNext =
                            messagesList[index] != messagesList.last;

                        final DateTime nextMessageTimeSent = hasNext
                            ? messagesList[index + 1].timeSent
                            : DateTime.now();
                        bool _isOwnMessage =
                            Auth().currentUser!.uid == message.senderUID;
                        if (hasNext &&
                            message.timeSent.day != nextMessageTimeSent.day) {
                          return Column(
                            crossAxisAlignment: _isOwnMessage
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              _dayDivider(message.timeSent),
                              _messageCard(context, message, _isOwnMessage),
                            ],
                          );
                        } else {
                          return _messageCard(context, message, _isOwnMessage);
                        }
                        // final Message message = messagesList[index];
                        // final Message6 nextMessage = messagesList[index + 1]??;
                        // bool _isOwnMessage = Auth().currentUser!.uid ==
                        //     message
                        //         .senderUID; //to disntiguihs between our messages and the other users
                        // return message.timeSent.day != nextMessage.timeSent.day
                        //     ? Column(
                        //         children: [
                        //           _dayDivider(messagesList[index + 1].timeSent),
                        //           _messageCard(context, message, _isOwnMessage),
                        //         ],
                        //       )
                        //     : _messageCard(context, message, _isOwnMessage);
                      },
                    );
                  }),
            )),
            Container(
              height: displayHeight(context) * 0.14,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 0),
                    blurRadius: 8.0,
                    spreadRadius: 0.5,
                    color:
                        const Color.fromARGB(255, 59, 59, 59).withOpacity(0.2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: displayHeight(context) * 0.06,
                    width: displayWidth(context) * 0.8,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.05),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: TextField(
                      controller: _newMessageController,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(20),
                        hintText: "Send a message !",
                        hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromARGB(255, 178, 178, 178)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    height: displayHeight(context) * 0.06,
                    width: displayWidth(context) * 0.14,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.secondary),
                    child: IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        sendMessage(Auth().currentUser!.uid, widget.userUID,
                            _newMessageController.text, widget.chatID);
                        _newMessageController.clear();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _messageCard(
      BuildContext context, Message message, bool isOwnMessage) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: isOwnMessage
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(6)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  message.message,
                  style: TextStyle(
                      color: isOwnMessage
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiary),
                ),
              ),
            ),
            SizedBox(height: displayWidth(context) * 0.01),
            Text(
              message.timeSent.hour.toString() +
                  " : " +
                  message.timeSent.minute.toString(),
              style: TextStyle(
                  fontSize: 10,
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.4)),
            )
          ],
        ));
  }

  Container _dayDivider(DateTime timeSent) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: displayWidth(context) * 0.4,
            height: displayHeight(context) * 0.002,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
          ),
          Text(
            timeSent.day.toString() + " / " + timeSent.month.toString(),
            style: const TextStyle(fontSize: 12),
          ),
          Container(
            height: displayHeight(context) * 0.002,
            width: displayWidth(context) * 0.4,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
          ),
        ],
      ),
    );
  }
}
