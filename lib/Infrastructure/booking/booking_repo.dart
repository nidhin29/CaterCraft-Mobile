import 'dart:developer';
import 'package:catering/Domain/bookings/booking_model/booking_model.dart';
import 'package:catering/Domain/bookings/booking_service.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:catering/Domain/Failure/failure.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BookingService)
class BookingRepo implements BookingService {
  final Dio _dio;
  BookingRepo(this._dio);

  @override
  Future<Either<MainFailure, List<BookingModel>>> getBookings() async {
    try {
      final response = await _dio.get('api/v1/booking/User/view-bookings');
      log(response.data.toString());
      if (response.statusCode == 200) {
        final rawData = response.data;
        List<dynamic> dataList = [];
        
        if (rawData is List) {
          dataList = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          dataList = rawData['data'];
        }

        final bookings = dataList
            .whereType<Map<String, dynamic>>()
            .map((json) => BookingModel.fromJson(json))
            .toList();
            
        return Right(bookings);
      } else {
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('❌ Get Bookings Error: $e');
      return const Left(MainFailure.serverFailure());
    }
  }

  @override
  Future<Either<MainFailure, Unit>> assignStaff(String bookingId, List<String> staffIds) async {
    try {
      final response = await _dio.patch('api/v1/booking/assign-staff', data: {
        'booking_id': bookingId,
        'staffIds': staffIds,
      });

      if (response.statusCode == 200) {
        return const Right(unit);
      } else {
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('❌ Assign Staff Error: $e');
      return const Left(MainFailure.serverFailure());
    }
  }

  @override
  Future<Either<MainFailure, List<BookingModel>>> getStaffTasks() async {
    try {
      final response = await _dio.get('api/v1/booking/staff-tasks');

      if (response.statusCode == 200) {
        final rawData = response.data;
        List<dynamic> dataList = [];
        
        if (rawData is List) {
          dataList = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          dataList = rawData['data'];
        }
        
        final tasks = dataList
            .whereType<Map<String, dynamic>>()
            .map((json) => BookingModel.fromJson(json))
            .toList();
            
        return Right(tasks);
      } else {
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('❌ Get Staff Tasks Error: $e');
      return const Left(MainFailure.serverFailure());
    }
  }

  @override
  Future<Either<MainFailure, Unit>> updateStatus(String bookingId, String newStatus) async {
    try {
      final response = await _dio.patch('api/v1/booking/update-status', data: {
        'booking_id': bookingId,
        'new_status': newStatus,
      });

      if (response.statusCode == 200) {
        return const Right(unit);
      } else {
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      return const Left(MainFailure.serverFailure());
    }
  }
}
