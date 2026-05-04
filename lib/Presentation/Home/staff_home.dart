import 'dart:ui';
import 'package:catering/Application/Owner/owner_cubit.dart';
import 'package:catering/Application/Staff/staff_cubit.dart';
import 'package:catering/Domain/TokenManager/token_service.dart';
import 'package:catering/Presentation/Home/tabs/chat_list_tab.dart';
import 'package:catering/Presentation/Home/tabs/missions_tab.dart';
import 'package:catering/Presentation/common/theme.dart';
import 'package:catering/core/injectable/injectable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [const MissionsTab(), const ChatListTab()];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    final tokenService = getIt<TokenService>();
    final email = await tokenService.getEmail();
    if (email != null && mounted) {
      final ownerCubit = context.read<OwnerCubit>();
      final staffCubit = context.read<StaffCubit>();

      // Fetch shared context data
      staffCubit.fetchAssignedBookings();
      
      // Sync device ID (FCM token) and fetch details
      await staffCubit.syncFCMToken();
      await staffCubit.fetchDetails();
      
      // Get the correct User ID from the StaffCubit instead of OwnerCubit
      final staffUser = staffCubit.state.userDetails.fold(() => null, (u) => u);
      
      // Setup socket with the staff's email and ID
      ownerCubit.setupSocket(email, staffUser?.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: AppTheme.premiumGradient),
          ),

          // Subtle Aura Glows
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.staffAccent.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(),
              ),
            ),
          ),

          IndexedStack(index: _currentIndex, children: _tabs),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      decoration: AppTheme.luxuryGlass(opacity: 0.1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.staffAccent,
            unselectedItemColor: Colors.white24,
            selectedLabelStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_ind_rounded),
                label: "MISSIONS",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_rounded),
                label: "INBOX",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
