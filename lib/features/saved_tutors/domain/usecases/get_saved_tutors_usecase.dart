import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/saved_tutors/domain/repositories/saved_tutors_repository.dart';

class GetSavedTutorsUseCase
    implements UsecaseWithoutParams<List<Map<String, dynamic>>> {
  GetSavedTutorsUseCase({required ISavedTutorsRepository savedTutorsRepository})
      : _savedTutorsRepository = savedTutorsRepository;

  final ISavedTutorsRepository _savedTutorsRepository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _savedTutorsRepository.getSavedTutors();
  }
}

final getSavedTutorsUseCaseProvider = Provider<GetSavedTutorsUseCase>((ref) {
  return GetSavedTutorsUseCase(
    savedTutorsRepository: ref.read(savedTutorsRepositoryProvider),
  );
});
