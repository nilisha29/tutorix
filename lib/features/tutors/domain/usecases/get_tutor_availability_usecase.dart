import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/tutors/domain/repositories/tutors_repository.dart';

class GetTutorAvailabilityUseCaseParams extends Equatable {
  const GetTutorAvailabilityUseCaseParams({required this.tutorId});

  final String tutorId;

  @override
  List<Object?> get props => [tutorId];
}

class GetTutorAvailabilityUseCase
    implements
        UsecaseWithParams<List<Map<String, dynamic>>, GetTutorAvailabilityUseCaseParams> {
  GetTutorAvailabilityUseCase({required ITutorsRepository tutorsRepository})
      : _tutorsRepository = tutorsRepository;

  final ITutorsRepository _tutorsRepository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GetTutorAvailabilityUseCaseParams params,
  ) {
    return _tutorsRepository.getTutorAvailability(params.tutorId);
  }
}

final getTutorAvailabilityUseCaseProvider =
    Provider<GetTutorAvailabilityUseCase>((ref) {
  return GetTutorAvailabilityUseCase(
    tutorsRepository: ref.read(tutorsRepositoryProvider),
  );
});
