import 'package:catering/Presentation/Home/notifications_screen.dart';
import 'package:catering/Presentation/Home/profile.dart';
import 'package:catering/Presentation/Home/booking_detail.dart';
import 'package:catering/Application/Owner/owner_cubit.dart';
import 'package:catering/Presentation/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<OwnerCubit>().fetchBookings(),
      color: AppTheme.ownerAccent,
      backgroundColor: AppTheme.darkBackground,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: BlocBuilder<OwnerCubit, OwnerState>(
              builder: (context, state) {
                final owner = state.ownerDetails.fold(() => null, (u) => u);
                final isVerified = owner?.verificationStatus?.toLowerCase() == "verified";
  
                // Calculate active events and requests awaiting approval
                final activeStatuses = ["Accepted", "Approved", "In Kitchen", "Dispatched", "Confirmed"];
                final activeCount = state.bookings.where((b) => activeStatuses.contains(b.status)).length;
                final pendingCount = state.bookings.where((b) => b.status == "Pending").length;
  
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isVerified) ...[
                        _buildVerificationBanner(),
                        const SizedBox(height: 24),
                      ],
                      _buildWelcomeHeader(owner?.companyName ?? "CaterCraft"),
                      const SizedBox(height: 32),
                      _buildStatSection(activeCount, pendingCount),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Bookings",
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text("See All", style: TextStyle(color: AppTheme.ownerAccent.withOpacity(0.8))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildBookingsList(),
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
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen())),
        icon: const Icon(Icons.account_circle_outlined, color: Colors.white70, size: 28),
      ),
      title: Text(
        "CATERCRAFT",
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationsScreen())),
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70, size: 28),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeHeader(String companyName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          companyName.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.ownerAccent.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Command Center",
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

  Widget _buildVerificationBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amberAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amberAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.amberAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Account Under Review",
                  style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  "Your business license is being verified. You can explore the dashboard, but adding services is restricted until verified.",
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatSection(int activeCount, int pendingCount) {
    return Row(
      children: [
        _statBlock("Active Ev.", activeCount.toString().padLeft(2, '0'), Icons.dashboard_customize_rounded, AppTheme.statusConfirmed),
        const SizedBox(width: 20),
        _statBlock("Req. Appr.", pendingCount.toString().padLeft(2, '0'), Icons.pending_actions_rounded, AppTheme.statusPending),
      ],
    );
  }

  Widget _statBlock(String label, String value, IconData icon, Color accentColor) {
    return Expanded(
      child: Container(
        height: 160,
        decoration: AppTheme.luxuryGlass(opacity: 0.08),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                bottom: -20,
                right: -20,
                child: Icon(icon, size: 100, color: Colors.white.withOpacity(0.03)),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accentColor, size: 24),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          label,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.white54,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
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

  Widget _buildBookingsList() {
    return BlocBuilder<OwnerCubit, OwnerState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.ownerAccent)));
        }
        if (state.bookings.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  const Text("No active bookings", style: TextStyle(color: Colors.white38)),
                ],
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _bookingCard(context, state.bookings[index]),
              childCount: state.bookings.length > 5 ? 5 : state.bookings.length,
            ),
          ),
        );
      },
    );
  }

  Widget _bookingCard(BuildContext context, dynamic booking) {
    final bool isConfirmed = booking.status == "Confirmed";
    final Color statusColor = isConfirmed ? AppTheme.statusConfirmed : AppTheme.statusPending;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppTheme.luxuryGlass(opacity: 0.05),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BookingDetailScreen(booking: booking, isOwner: true),
            ),
          ),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildServiceIcon(isConfirmed),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.service.name,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.customerEmail,
                        style: const TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(booking.status, statusColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceIcon(bool active) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: active ? AppTheme.ownerAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.local_dining_rounded,
        color: active ? AppTheme.ownerAccent : Colors.white30,
        size: 26,
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
