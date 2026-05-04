import 'package:catering/Application/Owner/owner_cubit.dart';
import 'package:catering/Presentation/Home/notifications_screen.dart';
import 'package:catering/Presentation/Home/profile.dart';
import 'package:catering/Presentation/common/theme.dart';
import 'package:catering/Presentation/Chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatListTab extends StatefulWidget {
  const ChatListTab({super.key});

  @override
  State<ChatListTab> createState() => _ChatListTabState();
}

class _ChatListTabState extends State<ChatListTab> {
  @override
  void initState() {
    super.initState();
    // Refresh chats on entry
    context.read<OwnerCubit>().fetchRecentConversations();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<OwnerCubit>().fetchRecentConversations(),
      color: AppTheme.ownerAccent,
      backgroundColor: AppTheme.darkBackground,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ),
              icon: const Icon(
                Icons.account_circle_outlined,
                color: Colors.white70,
                size: 28,
              ),
            ),
            title: Text(
              "COMMHUB",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                ),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white70,
                  size: 28,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Communications Hub",
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Coordinate with your team in real-time",
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<OwnerCubit, OwnerState>(
            builder: (context, state) {
              if (state.isLoading && state.conversations.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.ownerAccent)),
                );
              }
  
              // final user = state.ownerDetails.fold(() => null, (u) => u);
              // final myId = user?.id ?? '';
              final recentConversations = state.conversations;
  
              return SliverList(
                delegate: SliverChildListDelegate([
                  if (recentConversations.isNotEmpty) ...[
                    _sectionHeader("RECENT CHATS"),
                    ...recentConversations.map((conv) {
                      final isTyping = state.typingRooms[conv.roomId] ?? false;
                      return _chatItem(
                        context,
                        name: conv.otherUserName,
                        imageUrl: conv.otherUserImage,
                        lastMessage: conv.lastMessage,
                        time: _formatTime(conv.lastMessageTime),
                        isOnline: conv.isOnline,
                        unreadCount: conv.unreadCount,
                        isTyping: isTyping,
                        onTap: () {
                          context.read<OwnerCubit>().markAsRead(conv.roomId);
                          _navigateToChat(
                            context,
                            roomId: conv.roomId,
                            name: conv.otherUserName,
                            id: conv.otherUserId,
                            type: conv.otherUserType,
                          );
                        },
                      );
                    }),
                  ],
                  if (recentConversations.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.white10),
                            const SizedBox(height: 16),
                            Text("No active conversations", style: GoogleFonts.outfit(color: Colors.white38)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 100), // Bottom padding for navbar
                ]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white24,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context,
      {required String roomId, required String name, required String id, required String type}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          roomId: roomId,
          otherUserName: name,
          otherUserId: id,
          otherUserType: type,
        ),
      ),
    );
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }
      return "${dt.day}/${dt.month}";
    } catch (_) {
      return '';
    }
  }

  Widget _chatItem(
    BuildContext context, {
    required String name,
    String? imageUrl,
    String lastMessage = "Stable connection established",
    String time = "10:12 PM",
    bool isOnline = false,
    int unreadCount = 0,
    bool isTyping = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
      decoration: AppTheme.luxuryGlass(opacity: 0.05),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: imageUrl != null && imageUrl.startsWith('http')
                    ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => _placeholderAvatar())
                    : _placeholderAvatar(),
              ),
            ),
            if (isOnline)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0D0D0D), width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              time,
              style: GoogleFonts.outfit(
                color: unreadCount > 0 ? AppTheme.ownerAccent : Colors.white24,
                fontSize: 11,
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isTyping ? "typing..." : lastMessage,
                  style: GoogleFonts.outfit(
                    color: isTyping ? Colors.amberAccent : (unreadCount > 0 ? Colors.white70 : Colors.white38),
                    fontSize: 13,
                    fontWeight: (unreadCount > 0 || isTyping) ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderAvatar() {
    return const Icon(
      Icons.person_rounded,
      color: Colors.white70,
      size: 30,
    );
  }
}
