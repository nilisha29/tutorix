import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetCategoriesUseCase
    implements UsecaseWithoutParams<List<Map<String, dynamic>>> {
  GetCategoriesUseCase({required IDashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository;

  final IDashboardRepository _dashboardRepository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _dashboardRepository.getCategories();
  }
}

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(
    dashboardRepository: ref.read(dashboardRepositoryProvider),
  );
});
