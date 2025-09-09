import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'services/firebase_service.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/assessment/assessment_screen.dart';
import 'screens/camera/camera_screen.dart';
import 'screens/results/results_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Firebase service
  await FirebaseService.instance.initialize();
  
  runApp(
    ProviderScope(
      child: SportstalentAiApp(),
    ),
  );
}

class SportstalentAiApp extends StatelessWidget {
  SportstalentAiApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/assessment',
        name: AppRoutes.assessment,
        builder: (context, state) => const AssessmentScreen(),
      ),
      GoRoute(
        path: '/camera',
        name: AppRoutes.camera,
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/results',
        name: AppRoutes.results,
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = FirebaseService.instance.currentUser != null;
      final isAuthRoute = state.location == '/';
      
      // If not logged in and trying to access protected routes
      if (!isLoggedIn && !isAuthRoute) {
        return '/';
      }
      
      // If logged in and on auth route, redirect to home
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }
      
      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'SportsTalent AI',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}