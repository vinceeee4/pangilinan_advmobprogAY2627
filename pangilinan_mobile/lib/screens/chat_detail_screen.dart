import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/constants.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';

// Lab Activity 6, Enhancement 3: Redesigned chat thread - rounded message
// bubbles, a sending/seen indicator on the current user's own messages, and
// a fade + slide-in animation for each bubble as it appears.
class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserEmail,
  });

  final String otherUserId;
  final String otherUserName;
  final String otherUserEmail;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;

  String get _currentUid => UserService().currentFirebaseUser!.uid;

  @override
  void initState() {
    super.initState();
    _chatService.markMessagesSeen(_currentUid, widget.otherUserId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _messageController.clear();
    try {
      await _chatService.sendMessage(widget.otherUserId, text);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _timeLabel(DateTime time) {
    final String hour = (time.hour % 12 == 0 ? 12 : time.hour % 12).toString();
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: kPrimaryColor,
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.otherUserName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  Text(
                    widget.otherUserEmail,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.sp, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatService.getMessages(
                _currentUid,
                widget.otherUserId,
              ),
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
              ) {
                if (snapshot.hasError)
                  return const Center(
                    child: Text('Could not load messages.'),
                  );
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return Center(
                    child: Text(
                      'Say hi to ${widget.otherUserName}!',
                      style: kProductSubtitleStyle,
                    ),
                  );
                // Firestore query is already newest-first; a reversed
                // ListView keeps the newest message pinned to the bottom.
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> data = docs[index].data();
                    final bool isMine = data['senderId'] == _currentUid;
                    return _AnimatedBubble(
                      key: ValueKey<String>(docs[index].id),
                      isMine: isMine,
                      message: data['message']?.toString() ?? '',
                      timestamp: data['timestamp'] is Timestamp
                          ? (data['timestamp'] as Timestamp).toDate()
                          : DateTime.now(),
                      seen: data['seen'] == true,
                      timeLabel: _timeLabel,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: kPrimaryColor,
                    child: IconButton(
                      icon: _sending
                          ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                      onPressed: _sending ? null : _send,
                    ),
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

// Fades and slides each bubble in from its own side the first time it is
// built, giving new messages (and the initial history load) a lightweight
// entrance animation.
class _AnimatedBubble extends StatefulWidget {
  const _AnimatedBubble({
    super.key,
    required this.isMine,
    required this.message,
    required this.timestamp,
    required this.seen,
    required this.timeLabel,
  });

  final bool isMine;
  final String message;
  final DateTime timestamp;
  final bool seen;
  final String Function(DateTime) timeLabel;

  @override
  State<_AnimatedBubble> createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<_AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: Offset(widget.isMine ? 0.15 : -0.15, 0.08),
    end: Offset.zero,
  ).animate(_fade);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Align(
          alignment: widget.isMine
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: 280.w),
            margin: EdgeInsets.symmetric(vertical: 4.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: widget.isMine ? kPrimaryColor : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(widget.isMine ? 16.r : 4.r),
                bottomRight: Radius.circular(widget.isMine ? 4.r : 16.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: widget.isMine ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.timeLabel(widget.timestamp),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: widget.isMine
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    if (widget.isMine) ...<Widget>[
                      SizedBox(width: 4.w),
                      Icon(
                        widget.seen ? Icons.done_all : Icons.done,
                        size: 14.sp,
                        color: widget.seen
                            ? Colors.lightBlueAccent
                            : Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
