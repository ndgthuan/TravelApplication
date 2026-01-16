import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/core/di/injection.dart';
import 'package:travel_app/firebase_options.dart';
import 'package:travel_app/screen/Account/viewmodels/account_view_model.dart';
import 'package:travel_app/screen/Account/viewmodels/change_password_view_model.dart';
import 'package:travel_app/screen/Account/viewmodels/information_view_model.dart';
import 'package:travel_app/screen/Auth/viewmodels/login_view_model.dart';
import 'package:travel_app/screen/Auth/viewmodels/register_view_model.dart';
import 'package:travel_app/shared/widgets/navigation_widget.dart';
import 'screen/Onboarding/screens/start_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Language init
  await EasyLocalization.ensureInitialized();
  setupDependencies();
  runApp(
    // For web
    // EasyLocalization(
    //   supportedLocales: [
    //     Locale('en'),
    //     Locale('vi'),
    //     Locale('zh'),
    //     Locale('ja'),
    //     Locale('ko'),
    //     Locale('fr'),
    //     Locale('de'),
    //     Locale('ru'),
    //   ],
    //   path: 'lib/assets/translations',
    //   fallbackLocale: Locale('en'),
    //   child: DevicePreview(
    //     enabled: !kReleaseMode,
    //     defaultDevice: Devices.ios.iPhone16ProMax,
    //     backgroundColor: Colors.black,
    //     builder: (context) => const MyApp(),
    //   ),
    // ),

    // For android
    EasyLocalization(
      supportedLocales: [
        Locale('en'),
        Locale('vi'),
        Locale('zh'),
        Locale('ja'),
        Locale('ko'),
        Locale('fr'),
        Locale('de'),
        Locale('ru'),
      ],
      path: 'lib/assets/translations',
      fallbackLocale: Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => getIt<LoginViewModel>(),
          ), // Gọi login parent state
          ChangeNotifierProvider(
            create: (_) => getIt<RegisterViewModel>(),
          ), // Gọi register parent state
          ChangeNotifierProvider(
            create: (_) => getIt<AccountViewModel>(),
          ), // Gọi account parent state
          ChangeNotifierProvider(
            create: (_) => getIt<InformationViewModel>(),
          ), // Gọi profile parent state,
          ChangeNotifierProvider(
            create: (_) => getIt<ChangePasswordViewModel>(),
          ), // Gọi changgePassword parent state
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // // For web
      // localizationsDelegates: context.localizationDelegates,
      // supportedLocales: context.supportedLocales,
      // debugShowCheckedModeBanner: false,
      // locale: context.locale,
      // builder: DevicePreview.appBuilder,
      // theme: ThemeData.light(),
      // darkTheme: ThemeData.dark(),
      // home: FirebaseAuth.instance.currentUser != null
      //     ? const BottomNavigation()
      //     : const StartScreen(),

      // For android
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: "TravelApplication",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser != null
          ? BottomNavigation()
          : StartScreen(),
    );
  }
}
