import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/dashboard/domain/repositories/dashboard_repository.dart';

class BookTutorUseCaseParams extends Equatable {
  const BookTutorUseCaseParams({
    required this.tutorId,
    required this.date,
    required this.startTime,
    required this.durationMinutes,
    required this.paymentMethod,
    this.notes,
  });

  final String tutorId;
  final String date;
  final String startTime;
  final int durationMinutes;
  final String paymentMethod;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'tutorId': tutorId,
      'date': date,
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props {
    return [tutorId, date, startTime, durationMinutes, paymentMethod, notes];
  }
}

class BookTutorUseCase
    implements UsecaseWithParams<Map<String, dynamic>, BookTutorUseCaseParams> {
  BookTutorUseCase({required IDashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository;

  final IDashboardRepository _dashboardRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    BookTutorUseCaseParams params,
  ) {
    return _dashboardRepository.bookTutor(params.toJson());
  }
}

final bookTutorUseCaseProvider = Provider<BookTutorUseCase>((ref) {
  return BookTutorUseCase(
    dashboardRepository: ref.read(dashboardRepositoryProvider),
  );
});
