import 'package:catering/Application/Staff/staff_cubit.dart';
import 'package:catering/Presentation/Home/notifications_screen.dart';
import 'package:catering/Presentation/Home/profile.dart';
import 'package:catering/Presentation/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering/Domain/bookings/booking_model/booking_model.dart';
import 'dart:developer';

class MissionsTab extends StatelessWidget {
  const MissionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<StaffCubit>().fetchAssignedBookings(),
      color: AppTheme.staffAccent,
      backgroundColor: AppTheme.darkBackground,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_rounded,
                        color: AppTheme.staffAccent.withOpacity(0.7),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "TODAY'S MISSIONS",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white60,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildTasksList(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed:
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
        icon: const Icon(
          Icons.account_circle_outlined,
          color: Colors.white70,
          size: 28,
        ),
      ),
      title: Text(
        "OPERATIONS",
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      actions: [
        IconButton(
          onPressed:
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              ),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white70,
            size: 28,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Field Operations",
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.staffAccent.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Ready for Service?",
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    return BlocBuilder<StaffCubit, StaffState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.staffAccent),
            ),
          );
        }
        if (state.bookings.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    size: 64,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "All clear! No tasks today.",
                    style: TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _eventTaskCard(context, state.bookings[index]),
              childCount: state.bookings.length,
            ),
          ),
        );
      },
    );
  }

  Widget _eventTaskCard(BuildContext context, BookingModel booking) {
    // Parse the real date and time
    DateTime? dt;
    String formattedDate = "Unknown Date";
    String formattedTime = "Unknown Time";
    
    try {
      dt = DateTime.parse(booking.dateTime).toLocal();
      formattedDate = "${dt.day}/${dt.month}/${dt.year}";
      formattedTime = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      log("Error parsing date: $e");
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.luxuryGlass(opacity: 0.08),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(side: BorderSide.none),
            tilePadding: const EdgeInsets.all(20),
            title: Text(
              booking.service.name,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _cardInfoRow(Icons.calendar_today_rounded, formattedDate),
                const SizedBox(height: 8),
                _cardInfoRow(Icons.access_time_filled_rounded, formattedTime),
                const SizedBox(height: 8),
                _cardInfoRow(Icons.person_outline_rounded, booking.customerEmail),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.staffAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: AppTheme.staffAccent,
                size: 20,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Colors.white.withOpacity(0.05)),
                    const SizedBox(height: 12),
                    Text(
                      "ASSIGNMENT DETAILS",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.staffAccent.withOpacity(0.7),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "This is a confirmed mission for the ${booking.service.name} service. Please ensure you are on-site at $formattedTime on $formattedDate.",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white60,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.staffAccent.withOpacity(0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
