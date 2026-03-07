import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/saved_tutors/domain/repositories/saved_tutors_repository.dart';

class RemoveSavedTutorUseCaseParams extends Equatable {
  const RemoveSavedTutorUseCaseParams({required this.tutorId});

  final String tutorId;

  @override
  List<Object?> get props => [tutorId];
}

class RemoveSavedTutorUseCase
    implements UsecaseWithParams<bool, RemoveSavedTutorUseCaseParams> {
  RemoveSavedTutorUseCase({required ISavedTutorsRepository savedTutorsRepository})
      : _savedTutorsRepository = savedTutorsRepository;

  final ISavedTutorsRepository _savedTutorsRepository;

  @override
  Future<Either<Failure, bool>> call(RemoveSavedTutorUseCaseParams params) {
    return _savedTutorsRepository.removeSavedTutor(params.tutorId);
  }
}

final removeSavedTutorUseCaseProvider = Provider<RemoveSavedTutorUseCase>((ref) {
  return RemoveSavedTutorUseCase(
    savedTutorsRepository: ref.read(savedTutorsRepositoryProvider),
  );
});
