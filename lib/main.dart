import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Enviroment.initEnv();
  await Supabase.initialize(
    url: Enviroment.supabaseUrl,
    anonKey: Enviroment.supabaseKey,
  );
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    Future.microtask(() => ref.read(authProvider.notifier).checkInitialStatus());

    final appRouter = ref.watch(appRouterProvider);
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Meal Plan App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme()
    );
  }
}

