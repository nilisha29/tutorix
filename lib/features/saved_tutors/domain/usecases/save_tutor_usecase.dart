import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/saved_tutors/domain/repositories/saved_tutors_repository.dart';

class SaveTutorUseCaseParams extends Equatable {
  const SaveTutorUseCaseParams({required this.tutor});

  final Map<String, dynamic> tutor;

  @override
  List<Object?> get props => [tutor];
}

class SaveTutorUseCase
    implements UsecaseWithParams<bool, SaveTutorUseCaseParams> {
  SaveTutorUseCase({required ISavedTutorsRepository savedTutorsRepository})
      : _savedTutorsRepository = savedTutorsRepository;

  final ISavedTutorsRepository _savedTutorsRepository;

  @override
  Future<Either<Failure, bool>> call(SaveTutorUseCaseParams params) {
    return _savedTutorsRepository.saveTutor(params.tutor);
  }
}

final saveTutorUseCaseProvider = Provider<SaveTutorUseCase>((ref) {
  return SaveTutorUseCase(
    savedTutorsRepository: ref.read(savedTutorsRepositoryProvider),
  );
});
