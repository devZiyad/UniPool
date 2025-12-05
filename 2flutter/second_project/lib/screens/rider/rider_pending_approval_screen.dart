import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../models/booking.dart';

class RiderPendingApprovalScreen extends StatefulWidget {
  const RiderPendingApprovalScreen({super.key});

  @override
  State<RiderPendingApprovalScreen> createState() =>
      _RiderPendingApprovalScreenState();
}

class _RiderPendingApprovalScreenState
    extends State<RiderPendingApprovalScreen> {
  Booking? _booking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooking();
    _pollBookingStatus();
  }

  Future<void> _loadBooking() async {
    try {
      final bookings = await BookingService.getMyBookings();
      if (bookings.isNotEmpty) {
        setState(() {
          _booking = bookings.firstWhere(
            (b) => b.status == 'PENDING',
            orElse: () => bookings.first,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pollBookingStatus() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _loadBooking().then((_) {
          if (_booking?.status == 'CONFIRMED') {
            Navigator.pushReplacementNamed(context, '/rider/live-tracking');
          } else {
            _pollBookingStatus();
          }
        });
      }
    });
  }

  Future<void> _cancelRequest() async {
    if (_booking == null) return;

    try {
      await BookingService.cancelBooking(_booking!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Driver Approval')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text(
                'Pending Driver Approval',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _booking != null
                    ? 'Your request has been sent to ${_booking!.riderName}. You\'ll be notified once it\'s approved.'
                    : 'Waiting for driver approval...',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _cancelRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Cancel Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
