import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/tutors/domain/repositories/tutors_repository.dart';

class GetTutorDetailUseCaseParams extends Equatable {
  const GetTutorDetailUseCaseParams({required this.tutorId});

  final String tutorId;

  @override
  List<Object?> get props => [tutorId];
}

class GetTutorDetailUseCase
    implements UsecaseWithParams<Map<String, dynamic>, GetTutorDetailUseCaseParams> {
  GetTutorDetailUseCase({required ITutorsRepository tutorsRepository})
      : _tutorsRepository = tutorsRepository;

  final ITutorsRepository _tutorsRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    GetTutorDetailUseCaseParams params,
  ) {
    return _tutorsRepository.getTutorDetail(params.tutorId);
  }
}

final getTutorDetailUseCaseProvider = Provider<GetTutorDetailUseCase>((ref) {
  return GetTutorDetailUseCase(
    tutorsRepository: ref.read(tutorsRepositoryProvider),
  );
});
