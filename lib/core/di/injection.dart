// Mục đích của file này là đăng ký tất cả Repository và ViewModel vào một nơi tập trung
// Dùng package get_it để inject
import 'package:get_it/get_it.dart';
import 'package:travel_app/screen/Auth/viewmodels/register_view_model.dart';

// Import respositories
import '../../domain/repositories/i_auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Import viewmodels
import '../../screen/Auth/viewmodels/login_view_model.dart';

// Tạo global instance của GetIt
final GetIt getIt = GetIt.instance;

// Khởi tạo tất cả dependencies
// Hàm sẽ được gọi trong main trước khi run app
void setupDependencies() {
  //==========================================================================//
  //           REPOSITORIES (Singleton - chỉ tạo 1 instance duy nhất)         //
  //==========================================================================//
  getIt.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl());

  //==========================================================================//
  //           VIEWMODELS (Factory - tạo instance mới mỗi lần gọi)            //
  //==========================================================================//
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(getIt<IAuthRepository>()),
  );

  getIt.registerFactory<RegisterViewModel>(
    () => RegisterViewModel(getIt<IAuthRepository>()),
  );
}
