import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetUserProfileUseCase
    implements UsecaseWithoutParams<Map<String, dynamic>> {
  GetUserProfileUseCase({required IDashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository;

  final IDashboardRepository _dashboardRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() {
    return _dashboardRepository.getUserProfile();
  }
}

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(
    dashboardRepository: ref.read(dashboardRepositoryProvider),
  );
});
