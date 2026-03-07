import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/tutors/domain/repositories/tutors_repository.dart';

class GetCategoryTutorsUseCaseParams extends Equatable {
  const GetCategoryTutorsUseCaseParams({required this.category});

  final String category;

  @override
  List<Object?> get props => [category];
}

class GetCategoryTutorsUseCase
    implements
        UsecaseWithParams<List<Map<String, dynamic>>, GetCategoryTutorsUseCaseParams> {
  GetCategoryTutorsUseCase({required ITutorsRepository tutorsRepository})
      : _tutorsRepository = tutorsRepository;

  final ITutorsRepository _tutorsRepository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GetCategoryTutorsUseCaseParams params,
  ) {
    return _tutorsRepository.getCategoryTutors(params.category);
  }
}

final getCategoryTutorsUseCaseProvider = Provider<GetCategoryTutorsUseCase>((ref) {
  return GetCategoryTutorsUseCase(
    tutorsRepository: ref.read(tutorsRepositoryProvider),
  );
});
