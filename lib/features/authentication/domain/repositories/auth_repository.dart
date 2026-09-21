import '../../../../core/utils/result.dart';
import '../../data/models/auth_model.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<Result<String>> registerBroker(BrokerRegisterRequest request);

  Future<Result<void>> logout();

  Future<Result<UserEntity?>> getStoredUser();

  Future<Result<bool>> isAuthenticated();
}
