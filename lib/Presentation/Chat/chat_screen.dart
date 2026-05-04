import 'package:catering/Domain/Chat/message_model.dart';
import 'package:catering/Presentation/Chat/widgets/encrypted_image_widget.dart';
import 'package:catering/Application/Chat/chat_cubit.dart';
import 'package:catering/Application/Chat/chat_state.dart';
import 'package:catering/Application/Owner/owner_cubit.dart';
import 'package:catering/Presentation/common/theme.dart';
import 'package:catering/core/injectable/injectable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String otherUserName;
  final String otherUserId;
  final String otherUserType;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.otherUserName,
    required this.otherUserId,
    required this.otherUserType,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatCubit _chatCubit;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _myId = '';
  String _myType = '';
  Timer? _typingTimer;
  bool _isMeTyping = false;
  bool _showEmoji = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _chatCubit = getIt<ChatCubit>();
    _initializeChat();

    _scrollController.addListener(_onScroll);
    _msgController.addListener(_onTextChanged);

    final ownerState = context.read<OwnerCubit>().state;
    final user = ownerState.ownerDetails.fold(() => null, (u) => u);
    if (user != null) {
      _myId = user.id ?? '';
      _myType = (user.role == 1) ? 'Owner' : 'Staff';
    }
  }

  void _initializeChat() async {
    // Notify OwnerCubit that we are in this room
    context.read<OwnerCubit>().setActiveRoom(widget.roomId);
    
    _chatCubit.joinRoom(widget.roomId, widget.otherUserId);
    _chatCubit.fetchHistory(widget.roomId, otherUserId: widget.otherUserId);
  }

  void _onTextChanged() {
    if (_msgController.text.isNotEmpty && !_isMeTyping) {
      _isMeTyping = true;
      _chatCubit.setTypingStatus(_myId, widget.roomId, true);
    }
    
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isMeTyping && mounted) {
        _isMeTyping = false;
        _chatCubit.setTypingStatus(_myId, widget.roomId, false);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _chatCubit.fetchMoreHistory();
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _msgController.removeListener(_onTextChanged);
    _msgController.dispose();
    _scrollController.dispose();
    
    // Notify OwnerCubit that we left the room
    getIt<OwnerCubit>().setActiveRoom(null);
    
    _chatCubit.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null && _myId.isNotEmpty && mounted) {
      // Confirmation Dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.darkBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Send Image?", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(image.path), height: 200, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Text("Do you want to send this image?", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _myType == 'Owner' ? AppTheme.ownerAccent : AppTheme.staffAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final user = context.read<OwnerCubit>().state.ownerDetails.fold(() => null, (u) => u);
                if (user == null) {
                  Navigator.pop(context);
                  return;
                }
                final myId = user.id ?? '';
                final myType = (user.role == 1) ? 'Owner' : 'Staff';

                Navigator.pop(context);
                _chatCubit.sendImageMessage(
                  senderId: myId,
                  senderType: myType,
                  receiverId: widget.otherUserId,
                  receiverType: widget.otherUserType,
                  room: widget.roomId,
                  imageFile: File(image.path),
                );
              },
              child: Text("Send", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  void _showDeleteOptions(MessageModel msg) {
    final bool isMe = msg.senderId == _myId;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: AppTheme.luxuryGlass(opacity: 0.1),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.white70),
                title: Text("Delete for me", style: GoogleFonts.outfit(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _chatCubit.deleteMessage(msg.id!, widget.roomId, type: "me");
                },
              ),
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: Text("Delete for everyone", style: GoogleFonts.outfit(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    _chatCubit.deleteMessage(msg.id!, widget.roomId, type: "everyone");
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final user = context.read<OwnerCubit>().state.ownerDetails.fold(() => null, (u) => u);
    if (user == null) return;

    final myId = user.id ?? '';
    final myType = (user.role == 1) ? 'Owner' : 'Staff';

    if (myId.isEmpty) return;

    _chatCubit.sendMessage(
      senderId: myId,
      senderType: myType,
      receiverId: widget.otherUserId,
      receiverType: widget.otherUserType,
      message: text,
      room: widget.roomId,
    );
    _msgController.clear();
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatCubit,
      child: PopScope(
        canPop: !_showEmoji,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _showEmoji) {
            setState(() => _showEmoji = false);
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.darkBackground,
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(),
          body: Container(
            decoration: BoxDecoration(gradient: AppTheme.premiumGradient),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: BlocBuilder<ChatCubit, ChatState>(
                      builder: (context, state) {
                        if (state.isLoading && state.messages.isEmpty) {
                          return const Center(child: CircularProgressIndicator(color: AppTheme.ownerAccent));
                        }
                        
                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(16, 120, 16, 20),
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.messages.length + (state.isLoadMoreLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.messages.length) {
                               return const Center(
                                 child: Padding(
                                   padding: EdgeInsets.symmetric(vertical: 20),
                                   child: CircularProgressIndicator(color: AppTheme.ownerAccent),
                                 ),
                               );
                            }
                            final msg = state.messages[index];
                            final isMe = msg.senderId == _myId;
                            return _buildMessageBubble(msg, isMe);
                          },
                        );
                      },
                    ),
                  ),
                  _buildMessageInput(),
                  if (_showEmoji)
                    SizedBox(
                      height: 250,
                      child: emoji.EmojiPicker(
                        onEmojiSelected: (category, emojidata) {
                          _msgController.text += emojidata.emoji;
                        },
                        config: emoji.Config(
                          height: 250,
                          checkPlatformCompatibility: true,
                          emojiViewConfig: emoji.EmojiViewConfig(
                            backgroundColor: AppTheme.darkBackground,
                            columns: 7,
                            emojiSizeMax: 28 * (Platform.isIOS ? 1.2 : 1.0),
                            recentsLimit: 28,
                            noRecents: const Text(
                              'No Recents',
                              style: TextStyle(fontSize: 20, color: Colors.white24),
                              textAlign: TextAlign.center,
                            ),
                            loadingIndicator: const SizedBox.shrink(),
                            buttonMode: emoji.ButtonMode.MATERIAL,
                          ),
                          categoryViewConfig: emoji.CategoryViewConfig(
                            backgroundColor: AppTheme.darkBackground,
                            indicatorColor: AppTheme.ownerAccent,
                            iconColor: Colors.white38,
                            iconColorSelected: AppTheme.ownerAccent,
                            backspaceColor: AppTheme.ownerAccent,
                            categoryIcons: const emoji.CategoryIcons(),
                          ),
                          skinToneConfig: const emoji.SkinToneConfig(),
                          bottomActionBarConfig: const emoji.BottomActionBarConfig(enabled: false),
                          searchViewConfig: const emoji.SearchViewConfig(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.darkBackground.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
        onPressed: () => Navigator.pop(context),
      ),
      title: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUserName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.isOtherUserTyping)
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.amberAccent, 
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amberAccent.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "typing...",
                            style: GoogleFonts.outfit(
                              color: Colors.amberAccent, 
                              fontSize: 10, 
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else if (state.recipientPublicKey != null)
                      Row(
                        children: [
                          const Icon(Icons.lock, color: Colors.white38, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            "End-to-End Encrypted",
                            style: GoogleFonts.outfit(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    final color = widget.otherUserType == 'Owner' ? AppTheme.ownerAccent : AppTheme.staffAccent;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : "?",
          style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    if (msg.isEveryoneDeleted) {
      return _buildDeletedBubble(isMe);
    }

    final accentColor = isMe 
        ? (_myType == 'Owner' ? AppTheme.ownerAccent : AppTheme.staffAccent)
        : (widget.otherUserType == 'Owner' ? AppTheme.ownerAccent : AppTheme.staffAccent);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        onLongPress: () => _showDeleteOptions(msg),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.all(msg.imageUrl != null ? 4 : 16),
              decoration: BoxDecoration(
                color: isMe ? accentColor.withOpacity(0.8) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(20),
                ),
                border: Border.all(
                  color: isMe ? Colors.white24 : accentColor.withOpacity(0.2),
                ),
                boxShadow: isMe ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ] : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.imageUrl != null)
                    msg.isEncrypted && msg.encryptionNonce != null && context.read<ChatCubit>().state.recipientPublicKey != null
                      ? EncryptedImageWidget(
                          imageUrl: msg.imageUrl!,
                          nonce: msg.encryptionNonce!,
                          senderPublicKey: context.read<ChatCubit>().state.recipientPublicKey!,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: msg.imageUrl!,
                            placeholder: (context, url) => Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.white10,
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                  if (msg.imageUrl != null && msg.message != "[Image]")
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        msg.message,
                        style: GoogleFonts.outfit(
                          color: isMe ? Colors.black : Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  if (msg.imageUrl == null)
                    Text(
                      msg.message,
                      style: GoogleFonts.outfit(
                        color: isMe ? Colors.black : Colors.white,
                        fontSize: 15,
                        fontWeight: isMe ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
              child: Text(
                _formatTime(msg.createdAt ?? ''),
                style: GoogleFonts.outfit(color: Colors.white24, fontSize: 9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedBubble(bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, color: Colors.white24, size: 14),
            const SizedBox(width: 8),
            Text(
              "This message was deleted",
              style: GoogleFonts.outfit(color: Colors.white24, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return '';
    }
  }

  Widget _buildMessageInput() {
    final accentColor = _myType == 'Owner' ? AppTheme.ownerAccent : AppTheme.staffAccent;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withOpacity(0.5),
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.emoji_emotions_outlined, color: _showEmoji ? accentColor : Colors.white38),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() => _showEmoji = !_showEmoji);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white38),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: _msgController,
                      onTap: () {
                        if (_showEmoji) setState(() => _showEmoji = false);
                      },
                      style: GoogleFonts.outfit(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: GoogleFonts.outfit(color: Colors.white30),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.black, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
