import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetTutorsUseCase
    implements UsecaseWithoutParams<List<Map<String, dynamic>>> {
  GetTutorsUseCase({required IDashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository;

  final IDashboardRepository _dashboardRepository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _dashboardRepository.getTutors();
  }
}

final getTutorsUseCaseProvider = Provider<GetTutorsUseCase>((ref) {
  return GetTutorsUseCase(
    dashboardRepository: ref.read(dashboardRepositoryProvider),
  );
});
