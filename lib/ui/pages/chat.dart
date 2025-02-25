import 'dart:async';

import 'package:flutter/material.dart';
import 'package:insee_builder/locator.dart';
import 'package:insee_builder/service/service.dart';

import '../../localizations.dart';
import '../ui.dart';

class ChatView extends StatefulWidget {
  final int? id;
  final String? name;
  final String? email;

  const ChatView({super.key, this.id, this.name, this.email});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late Timer timer;
  late Future<List<MessageDto>?> chatDataFuture;
  late ScrollController listScrollController;

  @override
  initState() {
    listScrollController = ScrollController();
    chatDataFuture = fetchChatData();
    markAllUnreadAsRead();

    /// Refresh each 10 seconds.
    timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => refreshChat(),
    );

    super.initState();
  }

  Future<List<MessageDto>?> fetchChatData() async {
    if (widget.id == null) return null;
    return locate<RestService>().getChatMessages(widget.id!);
  }

  Future<bool> markAllUnreadAsRead() async {
    if (widget.id == null) return false;
    return locate<RestService>().markAllAsRead(widget.id!);
  }

  refreshChat() async {
    setState(() {
      chatDataFuture = fetchChatData();
    });
    markAllUnreadAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: [
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Visibility(
                    visible: widget.name != null,
                    child: Text(
                      widget.name!,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: widget.email != null && widget.id != null,
            child: StandaloneJobAcceptanceBanner(email: widget.email!, id: widget.id!),
          ),
          Expanded(
            child: FutureBuilder(
              future: chatDataFuture,
              builder: (context, chatDataFutureSnapshot) {
                if (chatDataFutureSnapshot.hasError) return Center(child: Text(chatDataFutureSnapshot.error.toString()));

                final items = (chatDataFutureSnapshot.data ?? []).reversed.toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                      return;
                    },
                    triggerMode: RefreshIndicatorTriggerMode.anywhere,
                    child: ListView.separated(
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: items.length,
                      controller: listScrollController,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      separatorBuilder: (context, i) => const SizedBox(height: 15),
                      itemBuilder: (context, i) {
                        var item = items[i];
                        if (item.isFromACustomer) {
                          return ClientChatItem(
                            text: item.message ?? "",
                            time: item.relativeTime,
                            imageUrl: item.interlocutor?.profileImageUrl,
                          );
                        }

                        return MyChatItem(
                          text: item.message ?? "",
                          time: item.relativeTime,
                          imageUrl: locate<BuilderService>().value?.profileImageUrl,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: widget.id != null,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: MessageBox(
                    receiverId: widget.id!,
                    onSend: refreshChat,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    chatDataFuture.ignore();
    super.dispose();
  }
}

class MessageBox extends StatefulWidget {
  final int receiverId;
  final Function() onSend;

  const MessageBox({super.key, required this.receiverId, required this.onSend});

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  TextEditingController textEditingController = TextEditingController();
  Future<bool>? future;
  String message = "";

  sendMessage(BuildContext context, String message) {
    setState(() {
      future = locate<RestService>().sendMessage(widget.receiverId, message)
        ..then((value) {
          widget.onSend();
          textEditingController.clear();
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox.square(
          dimension: 20,
          child: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 1));
              }

              if (snapshot.hasError) {
                return const Icon(
                  Icons.error_outline_outlined,
                  color: Colors.red,
                );
              }

              return const Icon(
                Icons.messenger_outline_rounded,
                color: Colors.red,
              );
            },
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: TextField(
            controller: textEditingController,
            onChanged: (text) => setState(() => message = text),
            decoration: InputDecoration(
              // hintText: "Write a message...",
              hintText: AppLocalizations.of(context)!.nN_1009,
              border: InputBorder.none,
              isCollapsed: true,
            ),
          ),
        ),
        const SizedBox(width: 15),
        ValueListenableBuilder(
          valueListenable: textEditingController,
          builder: (context, value, _) {
            return IconButton(
              onPressed: isValid ? () => sendMessage(context, message) : null,
              icon: Icon(
                Icons.send_rounded,
                color: isValid ? AppColors.red : Colors.grey,
              ),
            );
          },
        ),
      ],
    );
  }

  bool get isValid => textEditingController.text != "";
}

class ChatCircleAvatar extends StatefulWidget {
  final String? imageUrl;

  const ChatCircleAvatar({super.key, this.imageUrl});

  @override
  State<ChatCircleAvatar> createState() => _ChatCircleAvatarState();
}

class _ChatCircleAvatarState extends State<ChatCircleAvatar> {
  @override
  Widget build(BuildContext context) {
    // print(widget.imageUrl);
    return CircleAvatar(
      foregroundImage: widget.imageUrl != null ? NetworkImage(widget.imageUrl!) : null,
      backgroundColor: Colors.black12,
      radius: 30,
    );
  }
}

class ClientChatItem extends StatelessWidget {
  const ClientChatItem({
    super.key,
    required this.text,
    required this.time,
    this.imageUrl,
  });

  final String text;
  final String time;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChatCircleAvatar(imageUrl: imageUrl),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 50,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xF0F0F0F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MyChatItem extends StatelessWidget {
  const MyChatItem({
    super.key,
    required this.text,
    required this.time,
    this.imageUrl,
  });

  final String text;
  final String time;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 30),
            constraints: const BoxConstraints(
              minHeight: 50,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        CircleAvatar(
          foregroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          backgroundColor: Colors.black12,
          radius: 30,
        ),
      ],
    );
  }
}

class JobAcceptanceBanner extends StatelessWidget {
  const JobAcceptanceBanner({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  final Function() onAccept;
  final Function() onDecline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 1, color: Color(0xFFF0F0F0)),
          bottom: BorderSide(width: 1, color: Color(0xFFF0F0F0)),
        ),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              style: ButtonStyle(
                backgroundColor: const MaterialStatePropertyAll(Colors.green),
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
              ),
              onPressed: onAccept,
              // "Confirm Job"
              child: Text(AppLocalizations.of(context)!.nN_1010),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: FilledButton(
              style: ButtonStyle(
                backgroundColor: const MaterialStatePropertyAll(Color(0xFFEE1C25)),
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
              ),
              onPressed: onDecline,
              // "Decline Job"
              child: Text(AppLocalizations.of(context)!.nN_1011),
            ),
          ),
        ],
      ),
    );
  }
}

class StandaloneJobAcceptanceBanner extends StatefulWidget {
  final String email;
  final int id;

  const StandaloneJobAcceptanceBanner({super.key, required this.email, required this.id});

  @override
  State<StandaloneJobAcceptanceBanner> createState() => _StandaloneJobAcceptanceBannerState();
}

class _StandaloneJobAcceptanceBannerState extends State<StandaloneJobAcceptanceBanner> {
  late Timer timer;
  late Future<JobDto?> future;

  @override
  void initState() {
    future = checkForJobRequest();

    /// Refresh each 10 seconds.
    timer = Timer.periodic(
      const Duration(seconds: 10),
      (t) => refresh(),
    );

    super.initState();
  }

  refresh() => setState(() {
        future = checkForJobRequest();
      });

  Future<JobDto?> checkForJobRequest() async {
    var builder = locate<BuilderService>().value;
    var customer = await locate<RestService>().getUserById(widget.id);
    return locate<RestService>().getLastJobRequestFromCustomer(builder!.id!, customer!.email!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return JobAcceptanceBanner(
            onAccept: () => locate<RestService>().acceptJob(snapshot.data!.id!),
            onDecline: () => locate<RestService>().rejectJob(snapshot.data!.id!),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
