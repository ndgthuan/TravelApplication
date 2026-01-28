// Mục đích của file này là đăng ký tất cả Repository và ViewModel vào một nơi tập trung
// Dùng package get_it để inject
import 'package:get_it/get_it.dart';

// Import services
import 'package:travel_app/features/utilities/text_translation/services/speech_tts_service.dart';
import 'package:travel_app/features/utilities/weather_forecast/service/weather_config_service.dart';
import 'package:travel_app/features/utilities/weather_forecast/service/weather_service.dart';
import 'package:travel_app/domain/services/i_support_email_service.dart';
import 'package:travel_app/features/support/services/support_email_service.dart';
import 'package:travel_app/shared/services/geocoding_service.dart';
import 'package:travel_app/features/utilities/world_clock/services/timezone_storage_service.dart';
import 'package:travel_app/features/utilities/world_clock/services/timezone_util_service.dart';
import 'package:travel_app/features/utilities/text_translation/services/image_translation_service.dart';

// Import respositories
import 'package:travel_app/domain/repositories/i_auth_repository.dart';
import 'package:travel_app/domain/repositories/i_currency_repository.dart';
import 'package:travel_app/data/repositories/currency_repository_impl.dart';
import 'package:travel_app/data/repositories/auth_repository_impl.dart';
import 'package:travel_app/data/repositories/user_repository_impl.dart';
import 'package:travel_app/domain/repositories/i_user_repository.dart';
import 'package:travel_app/domain/repositories/i_home_repository.dart';
import 'package:travel_app/domain/repositories/i_explore_repository.dart';
import 'package:travel_app/data/repositories/explore_repository_impl.dart';
import 'package:travel_app/data/repositories/home_repository_impl.dart';
import 'package:travel_app/domain/repositories/i_language_repository.dart';
import 'package:travel_app/data/repositories/language_repository_impl.dart';

// Import viewmodels
import 'package:travel_app/features/auth/viewmodels/login_view_model.dart';
import 'package:travel_app/features/auth/viewmodels/register_view_model.dart';
import 'package:travel_app/features/account/viewmodels/account_view_model.dart';
import 'package:travel_app/features/account/viewmodels/change_password_view_model.dart';
import 'package:travel_app/features/account/viewmodels/information_view_model.dart';
import 'package:travel_app/features/support/viewmodels/contact_support_view_model.dart';
import 'package:travel_app/features/utilities/currency_exchange/viewmodels/currency_exchange_view_model.dart';
import 'package:travel_app/features/utilities/text_translation/viewmodels/text_translation_view_model.dart';
import 'package:travel_app/features/utilities/world_clock/viewmodels/world_clock_view_model.dart';
import 'package:travel_app/features/utilities/weather_forecast/viewmodels/weather_forecast_view_model.dart';
import 'package:travel_app/features/home/viewmodels/home_view_model.dart';
import 'package:travel_app/features/explore/viewmodels/explore_view_model.dart';

// Tạo global instance của GetIt
final GetIt getIt = GetIt.instance;

// Khởi tạo tất cả dependencies
// Hàm sẽ được gọi trong main trước khi run app
void setupDependencies() {
  //==========================================================================//
  //           SERVICES (Singleton - dùng chung cho nhiều nơi)                //
  //==========================================================================//
  getIt.registerLazySingleton<SpeechTtsService>(() => SpeechTtsService());
  getIt.registerLazySingleton<GeocodingService>(() => GeocodingService());
  getIt.registerLazySingleton<TimezoneStorageService>(
    () => TimezoneStorageService(),
  );
  getIt.registerLazySingleton<TimezoneUtilService>(() => TimezoneUtilService());
  getIt.registerLazySingleton<WeatherService>(() => WeatherService());
  getIt.registerLazySingleton<ImageTranslationService>(
    () => ImageTranslationService(),
  );
  getIt.registerLazySingleton<WeatherConfigService>(
    () => WeatherConfigService(),
  );
  getIt.registerLazySingleton<ILanguageRepository>(
    () => LanguageRepositoryImpl(),
  );
  getIt.registerLazySingleton<ISupportEmailService>(
    () => SupportEmailService(),
  );

  //==========================================================================//
  //           REPOSITORIES (Singleton - chỉ tạo 1 instance duy nhất)         //
  //==========================================================================//
  getIt.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<IUserRepository>(() => UserRepositoryImpl());
  getIt.registerLazySingleton<IHomeRepository>(() => HomeRepositoryImpl());
  getIt.registerLazySingleton<IExploreRepository>(
    () => ExploreRepositoryImpl(),
  );
  getIt.registerLazySingleton<ICurrencyRepository>(
    () => CurrencyRepositoryImpl(),
  );

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
    () => ContactSupportViewModel(
      getIt<ISupportEmailService>(),
      getIt<IUserRepository>(),
    ),
  );

  getIt.registerFactory<WorldClockViewModel>(
    () => WorldClockViewModel(
      getIt<GeocodingService>(),
      getIt<TimezoneStorageService>(),
      getIt<TimezoneUtilService>(),
    ),
  );

  getIt.registerFactory<CurrencyExchangeViewModel>(
    () => CurrencyExchangeViewModel(getIt<ICurrencyRepository>()),
  );

  getIt.registerFactory<TextTranslationViewModel>(
    () => TextTranslationViewModel(
      getIt<SpeechTtsService>(),
      getIt<ImageTranslationService>(),
      getIt<IUserRepository>(),
      getIt<ILanguageRepository>(),
    ),
  );

  getIt.registerFactory<WeatherForecastViewModel>(
    () => WeatherForecastViewModel(
      getIt<GeocodingService>(),
      getIt<WeatherService>(),
      getIt<WeatherConfigService>(),
    ),
  );

  getIt.registerFactory<HomeViewModel>(
    () => HomeViewModel(getIt<IHomeRepository>()),
  );

  getIt.registerFactory<ExploreViewModel>(
    () =>
        ExploreViewModel(getIt<IExploreRepository>(), getIt<IUserRepository>()),
  );
}
