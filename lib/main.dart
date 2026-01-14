import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travel_app/firebase_options.dart';
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
      child: MyApp(),
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
