import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:nexus/Providers/arrays_operations_provider.dart';
import 'package:nexus/Providers/badges_provider.dart';
import 'package:nexus/Providers/chart_provider.dart';
import 'package:nexus/Providers/daily_task_provider.dart';
import 'package:nexus/Providers/progress_update_provider.dart';
import 'package:nexus/Providers/trees_operations_provider.dart';
import 'package:nexus/Providers/user_provider.dart';
import 'package:nexus/Screens/login_screen.dart';
import 'package:nexus/Screens/services.dart';
import 'package:nexus/Screens/splash_screen.dart';
import 'package:nexus/firebase_options.dart';
import 'package:nexus/navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  await Hive.openBox('queryCountsBox');
  
  await Supabase.initialize(
    url: Secrets.supabaseUrl,
    anonKey: Secrets.supabaseKey,
  );



  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ArraysOperationsProvider()),
        ChangeNotifierProvider(create: (_)=>TreesOperationsProvider()),
        ChangeNotifierProvider(create: (_)=>UserProvider()),
        ChangeNotifierProvider(create: (_)=>BadgesProvider()),
         ChangeNotifierProvider(create: (_)=>DailyTaskProvider()),
        ChangeNotifierProvider(create: (_)=>ChatProvider()),
        ChangeNotifierProvider(create: (_)=>ProgressUpdateProvider())
      ],
      child:  const MainApp(),
    ),
  );
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

 

  @override
  Widget build(BuildContext context) {

     Future<Widget> getLandingPage() async {
    final box = Hive.box('userBox');
    final bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);
    final String? uid = box.get('uid');
    final user = FirebaseAuth.instance.currentUser;

    if(user != null && isLoggedIn && uid != null){
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUserId(uid);
      return NavigationsBar(uid: uid,);

    }else{
      return const LoginPage();
    }
  }
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
       themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.amber,
          surface: Colors.black,
        ),
         textTheme: TextTheme(
          headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
          displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16),
          labelMedium: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w400, fontSize: 14 ),
          labelSmall: TextStyle(color: Colors.white54, fontWeight: FontWeight.w200, fontSize: 14)
        ),
         elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.lightBlueAccent),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            elevation: WidgetStatePropertyAll(0),
            padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))
          )
        ),
      ),
      home: Builder(
        builder: (context) => NexusSplashScreen(
          onFinish: () async {
            final nextPage = await getLandingPage();
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => nextPage),
            );
          },
        ),
      ),
    );
  }
}



