import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/qr_generator/presentation/bloc/qr_generator_bloc.dart';
import 'features/scanner/presentation/bloc/scanner_bloc.dart';
import 'features/files/presentation/bloc/files_bloc.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'core/permissions/bloc/permissions_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();
  runApp(const QrGeneratorApp());
}

class QrGeneratorApp extends StatelessWidget {
  const QrGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => sl<QrGeneratorBloc>()),
        BlocProvider(create: (_) => sl<ScannerBloc>()),
        BlocProvider(create: (_) => sl<FilesBloc>()),
        BlocProvider(create: (_) => sl<HistoryBloc>()),
        BlocProvider(create: (_) => sl<PermissionsBloc>()),
      ],
      child: MaterialApp.router(
        title: 'QR Generator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
