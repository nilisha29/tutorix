import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/core/services/connectivity/network_info.dart';
import 'package:tutorix/core/services/hive/hive_service.dart';
import 'package:tutorix/features/auth/data/models/auth_hive_model.dart';
import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
import 'package:tutorix/features/auth/presentation/state/auth_state.dart';

import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';

/// --------------------
/// MOCKS
/// --------------------
class MockApiClient extends Mock implements ApiClient {}

class MockNetworkInfo extends Mock implements INetworkInfo {}

class MockHiveService extends Mock implements HiveService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  late ProviderContainer container;
  late MockApiClient mockApiClient;
  late MockNetworkInfo mockNetworkInfo;
  late MockHiveService mockHiveService;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      return null;
    });

    registerFallbackValue(
      AuthHiveModel(
        authId: '1',
        fullName: 'John Doe',
        email: 'john@gmail.com',
        password: 'password123',
      ),
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  setUp(() {
    mockApiClient = MockApiClient();
    mockNetworkInfo = MockNetworkInfo();
    mockHiveService = MockHiveService();

    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    when(() => mockHiveService.registerUser(any()))
        .thenAnswer((invocation) async => invocation.positionalArguments.first as AuthHiveModel);
    when(() => mockHiveService.setCurrentAuthId(any()))
        .thenAnswer((_) async {});
    when(() => mockHiveService.logoutUser()).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(mockApiClient),
        networkInfoProvider.overrideWithValue(mockNetworkInfo),
        hiveServiceProvider.overrideWithValue(mockHiveService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthViewModel Test', () {
    test('✅ initial state should be AuthState()', () {
      final state = container.read(authViewModelProvider);
      expect(state, const AuthState());
    });

    test('✅ login success updates state to authenticated', () async {
      // arrange
      when(() => mockApiClient.post(
            ApiEndpoints.userLogin,
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          data: {
            'token': 'token_123',
            'data': {
              '_id': '1',
              'fullName': 'John Doe',
              'username': 'johndoe',
              'email': 'john@gmail.com',
              'phoneNumber': '9800000000',
              'address': 'Kathmandu',
              'profileImage': null,
            }
          },
          requestOptions: RequestOptions(path: ApiEndpoints.userLogin),
        ),
      );

      // act
      await container
          .read(authViewModelProvider.notifier)
          .login(email: 'john@gmail.com', password: 'password123');

      final state = container.read(authViewModelProvider);

      // assert
      expect(state.status, AuthStatus.authenticated);
      expect(state.authEntity, isA<AuthEntity>());
      expect(state.authEntity?.email, 'john@gmail.com');
    });

    test('❌ login failure updates state to error', () async {
      // arrange
      when(() => mockApiClient.post(
            ApiEndpoints.userLogin,
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.userLogin),
          response: Response(
            statusCode: 401,
            data: {'message': 'Invalid credentials'},
            requestOptions: RequestOptions(path: ApiEndpoints.userLogin),
          ),
        ),
      );

      // act
      await container
          .read(authViewModelProvider.notifier)
          .login(email: 'wrong@gmail.com', password: 'wrong');

      final state = container.read(authViewModelProvider);

      // assert
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Invalid credentials');
    });

    test('✅ logout resets state', () {
      // act
      container.read(authViewModelProvider.notifier).logout();

      final state = container.read(authViewModelProvider);

      // assert
      expect(state, const AuthState());
    });

    test('✅ setProfilePicture updates local state', () {
      // act
      container
          .read(authViewModelProvider.notifier)
          .setProfilePicture('/local/path/image.png');

      final state = container.read(authViewModelProvider);

      // assert
      expect(state.profilePicture, '/local/path/image.png');
    });
  });
}
