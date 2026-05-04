import 'package:catering/Application/Owner/owner_cubit.dart';
import 'package:catering/Domain/bookings/booking_model/booking_model.dart';
import 'package:catering/Domain/SignIn/sign_in_model/user_model.dart';
import 'package:catering/Presentation/Home/widgets/staff_selection_sheet.dart';
import 'package:catering/Presentation/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;
  final bool isOwner;

  const BookingDetailScreen({
    super.key,
    required this.booking,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerCubit, OwnerState>(
      builder: (context, state) {
        // Use the updated booking from state if available
        final currentBooking = state.bookings.firstWhere(
          (b) => b.id == booking.id,
          orElse: () => booking,
        );

        return BlocListener<OwnerCubit, OwnerState>(
          listenWhen: (p, c) => p.isLoading != c.isLoading && !c.isLoading,
          listener: (context, state) {
            state.bookingFailureOrSuccess.fold(
              () => null,
              (either) => either.fold(
                (f) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to update status"), backgroundColor: Colors.redAccent),
                ),
                (_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Booking status updated successfully"), backgroundColor: Colors.green),
                ),
              ),
            );
          },
          child: Scaffold(
            bottomNavigationBar: _buildActionBar(context, currentBooking, state.isLoading),
            body: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, currentBooking),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(currentBooking),
                        const SizedBox(height: 32),
                        _buildDetailSection("Customer Details", [
                          _detailRow(Icons.email_outlined, currentBooking.customerEmail),
                          _detailRow(Icons.calendar_today_outlined, _formatDate(currentBooking.dateTime)),
                        ]),
                        const SizedBox(height: 32),
                        _buildDetailSection("Service Details", [
                          _detailRow(Icons.restaurant_menu_outlined, currentBooking.service.name),
                          _detailRow(Icons.description_outlined, currentBooking.service.description ?? "No description provided"),
                          _detailRow(Icons.timer_outlined, currentBooking.service.duration ?? "Flexible duration"),
                          _detailRow(Icons.currency_rupee, "${currentBooking.service.rate} / person"),
                        ]),
                        const SizedBox(height: 32),
                        _buildStaffAssignment(context, currentBooking),
                        const SizedBox(height: 32),
                        if (isOwner) _buildPaymentStatus(currentBooking),
                        if (!isOwner) _buildStaffTasks(currentBooking),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, BookingModel booking) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: booking.id ?? "",
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (booking.service.image != null)
                Image.network(
                  booking.service.image!,
                  fit: BoxFit.cover,
                )
              else
                Container(color: AppTheme.cardColor),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BookingModel booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                booking.service.name,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            _statusBadge(booking.status),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Booking ID: #${booking.id?.substring(0, 8).toUpperCase() ?? "N/A"}",
          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStaffAssignment(BuildContext context, BookingModel booking) {
    final assignedStaff = booking.assignedStaff ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Assigned Team",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            if (isOwner)
              TextButton.icon(
                onPressed: () => _openStaffSelection(context, booking),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text("Manage"),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.ownerAccent,
                  textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (assignedStaff.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Text(
              "No staff assigned yet",
              style: TextStyle(color: Colors.white24, fontSize: 14),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: assignedStaff.map((staff) => _staffAvatar(staff)).toList(),
          ),
      ],
    );
  }

  Widget _staffAvatar(UserModel staff) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white10,
            backgroundImage: staff.profileImageThumbnail != null ? NetworkImage(staff.profileImageThumbnail!) : null,
            child: staff.profileImageThumbnail == null ? const Icon(Icons.person, size: 12, color: Colors.white38) : null,
          ),
          const SizedBox(width: 8),
          Text(
            staff.fullName ?? "Staff",
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _openStaffSelection(BuildContext context, BookingModel booking) {
    context.read<OwnerCubit>().fetchStaff();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StaffSelectionSheet(
        initialSelectedIds: booking.assignedStaff?.map((s) => s.id!).toList() ?? [],
        onSelected: (selectedIds) {
          context.read<OwnerCubit>().assignStaffToBooking(booking.id!, selectedIds);
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = status == "Confirmed" ? Colors.greenAccent : Colors.orangeAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: isOwner ? AppTheme.ownerAccent : AppTheme.staffAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus(BookingModel booking) {
    final hasPaid = booking.paymentStatus == "Paid" || booking.razorpayOrderId != null;
    return _buildDetailSection("Financial Summary", [
      Row(
        children: [
          Icon(
            hasPaid ? Icons.check_circle : Icons.pending_actions,
            color: hasPaid ? Colors.greenAccent : Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            hasPaid ? "Payment Received" : "Payment Pending",
            style: TextStyle(color: hasPaid ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      if (hasPaid && booking.ownerPayout != null) ...[
        const SizedBox(height: 16),
        const Divider(color: Colors.white10),
        const SizedBox(height: 16),
        _financialRow("Booking Rate", "₹${booking.totalAmount}"),
        _financialRow("Admin Commission", "- ₹${booking.adminCommission}"),
        const SizedBox(height: 8),
        _financialRow("Your Net Earnings", "₹${booking.ownerPayout}", isHighlight: true),
      ]
    ]);
  }

  Widget _financialRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isHighlight ? Colors.white : Colors.white54, fontSize: 13)),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: isHighlight ? AppTheme.ownerAccent : Colors.white,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlight ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTasks(BookingModel booking) {
    return _buildDetailSection("Service Checklist", [
      _taskItem("Setup Service Area", true),
      _taskItem("Confirm Menu Requirements", true),
      _taskItem("Serve Food", false),
      _taskItem("Cleanup", false),
    ]);
  }

  Widget _taskItem(String task, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_box : Icons.check_box_outline_blank,
            color: isDone ? AppTheme.staffAccent : Colors.white24,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            task,
            style: TextStyle(
              color: isDone ? Colors.white54 : Colors.white,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEE, d MMM yyyy - hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget? _buildActionBar(BuildContext context, BookingModel booking, bool isLoading) {
    if (booking.status == "Finished" || booking.status == "Completed" || booking.status == "Cancelled") {
      return null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Opacity(
          opacity: isLoading ? 0.5 : 1.0,
          child: IgnorePointer(
            ignoring: isLoading,
            child: Row(
              children: _getActionButtons(context, booking),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getActionButtons(BuildContext context, BookingModel booking) {
    List<Widget> buttons = [];

    if (booking.status == "Pending" && isOwner) {
      buttons.add(
        Expanded(
          child: _actionButton(
            context,
            "Reject",
            Colors.redAccent,
            () => _confirmStatusChange(context, booking, "Cancelled", "Are you sure you want to reject this booking?"),
            isOutline: true,
          ),
        ),
      );
      buttons.add(const SizedBox(width: 16));
      buttons.add(
        Expanded(
          child: _actionButton(
            context,
            "Approve",
            Colors.greenAccent,
            () => _confirmStatusChange(context, booking, "Approved", "Do you want to accept and approve this booking?"),
          ),
        ),
      );
    } else if (booking.status == "Approved" || booking.status == "Accepted" || booking.status == "Confirmed") {
      final bool isPaid = booking.paymentStatus == "Paid" || booking.razorpayOrderId != null;

      if (!isPaid && isOwner) {
        buttons.add(
          const Expanded(
            child: Center(
              child: Text(
                "Waiting for Customer Payment...",
                style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic, fontSize: 13),
              ),
            ),
          ),
        );
      } else {
        buttons.add(
          Expanded(
            child: _actionButton(
              context,
              "Move to Kitchen",
              AppTheme.ownerAccent,
              () => _confirmStatusChange(context, booking, "In Kitchen", "Move this booking to the kitchen?"),
            ),
          ),
        );
      }
    } else if (booking.status == "In Kitchen") {
      buttons.add(
        Expanded(
          child: _actionButton(
            context,
            "Mark as Dispatched",
            Colors.blueAccent,
            () => _confirmStatusChange(context, booking, "Dispatched", "Mark this order as Dispatched?"),
          ),
        ),
      );
    } else if (booking.status == "Dispatched") {
      buttons.add(
        Expanded(
          child: _actionButton(
            context,
            "Finish Order",
            Colors.greenAccent,
            () => _confirmStatusChange(context, booking, "Finished", "Mark this order as Finished?"),
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      buttons.add(
        const Expanded(
          child: Center(
            child: Text(
              "Waiting for next stage...",
              style: TextStyle(color: Colors.white24, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  Widget _actionButton(BuildContext context, String label, Color color, VoidCallback onPressed, {bool isOutline = false}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(16),
        border: isOutline ? Border.all(color: color.withOpacity(0.5)) : null,
        boxShadow: isOutline ? [] : [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isOutline ? color : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmStatusChange(BuildContext context, BookingModel booking, String newStatus, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Update Status", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OwnerCubit>().updateBookingStatus(booking.id!, newStatus);
            },
            child: Text("Update", style: TextStyle(color: newStatus == "Cancelled" ? Colors.redAccent : Colors.greenAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
