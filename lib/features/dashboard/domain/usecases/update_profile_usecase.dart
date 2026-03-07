import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/dashboard/domain/repositories/dashboard_repository.dart';

class UpdateProfileUseCaseParams extends Equatable {
  const UpdateProfileUseCaseParams({
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    this.profilePicture,
  });

  final String fullName;
  final String phoneNumber;
  final String address;
  final String? profilePicture;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'profilePicture': profilePicture,
    };
  }

  @override
  List<Object?> get props => [fullName, phoneNumber, address, profilePicture];
}

class UpdateProfileUseCase
    implements UsecaseWithParams<Map<String, dynamic>, UpdateProfileUseCaseParams> {
  UpdateProfileUseCase({required IDashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository;

  final IDashboardRepository _dashboardRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    UpdateProfileUseCaseParams params,
  ) {
    return _dashboardRepository.updateProfile(params.toJson());
  }
}

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(
    dashboardRepository: ref.read(dashboardRepositoryProvider),
  );
});
