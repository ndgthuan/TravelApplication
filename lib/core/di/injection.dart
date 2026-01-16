// Mục đích của file này là đăng ký tất cả Repository và ViewModel vào một nơi tập trung
// Dùng package get_it để inject
import 'package:get_it/get_it.dart';

// Import respositories
import 'package:travel_app/domain/repositories/i_auth_repository.dart';
import 'package:travel_app/data/repositories/auth_repository_impl.dart';
import 'package:travel_app/data/repositories/user_repository_impl.dart';
import 'package:travel_app/domain/repositories/i_user_repository.dart';

// Import viewmodels
import 'package:travel_app/features/Auth/viewmodels/login_view_model.dart';
import 'package:travel_app/features/Auth/viewmodels/register_view_model.dart';
import 'package:travel_app/features/account/viewmodels/account_view_model.dart';
import 'package:travel_app/features/account/viewmodels/change_password_view_model.dart';
import 'package:travel_app/features/account/viewmodels/information_view_model.dart';
import 'package:travel_app/features/Support/viewmodels/contact_support_view_model.dart';

// Tạo global instance của GetIt
final GetIt getIt = GetIt.instance;

// Khởi tạo tất cả dependencies
// Hàm sẽ được gọi trong main trước khi run app
void setupDependencies() {
  //==========================================================================//
  //           REPOSITORIES (Singleton - chỉ tạo 1 instance duy nhất)         //
  //==========================================================================//
  getIt.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<IUserRepository>(() => UserRepositoryImpl());

  //==========================================================================//
  //           VIEWMODELS (Factory - tạo instance mới mỗi lần gọi)            //
  //==========================================================================//
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(getIt<IAuthRepository>()),
  );

  getIt.registerFactory<RegisterViewModel>(
    () => RegisterViewModel(getIt<IAuthRepository>()),
  );

  getIt.registerFactory<AccountViewModel>(
    () => AccountViewModel(getIt<IUserRepository>(), getIt<IAuthRepository>()),
  );

  getIt.registerFactory<InformationViewModel>(
    () => InformationViewModel(getIt<IUserRepository>()),
  );

  getIt.registerFactory<ChangePasswordViewModel>(
    () => ChangePasswordViewModel(getIt<IAuthRepository>()),
  );

  getIt.registerFactory<ContactSupportViewModel>(
    () => ContactSupportViewModel(),
  );
}
