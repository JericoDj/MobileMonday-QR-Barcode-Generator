import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../database/database_helper.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/update_profile_usecase.dart';
import '../../features/auth/domain/usecases/update_password_usecase.dart';
import '../../features/auth/domain/usecases/delete_account_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/qr_generator/data/datasources/qr_local_datasource.dart';
import '../../features/qr_generator/data/datasources/qr_remote_datasource.dart';
import '../../features/qr_generator/data/repositories/qr_repository_impl.dart';
import '../../features/qr_generator/domain/repositories/qr_repository.dart';
import '../../features/qr_generator/domain/usecases/generate_qr_usecase.dart';
import '../../features/qr_generator/domain/usecases/get_generated_items_usecase.dart';
import '../../features/qr_generator/domain/usecases/delete_generated_item_usecase.dart';
import '../../features/qr_generator/presentation/bloc/qr_generator_bloc.dart';
import '../../features/scanner/data/datasources/scan_local_datasource.dart';
import '../../features/scanner/data/repositories/scan_repository_impl.dart';
import '../../features/scanner/domain/repositories/scan_repository.dart';
import '../../features/scanner/domain/usecases/save_scan_usecase.dart';
import '../../features/scanner/domain/usecases/get_scan_history_usecase.dart';
import '../../features/scanner/presentation/bloc/scanner_bloc.dart';
import '../../features/files/data/datasources/files_local_datasource.dart';
import '../../features/files/data/datasources/files_remote_datasource.dart';
import '../../features/files/data/repositories/files_repository_impl.dart';
import '../../features/files/domain/repositories/files_repository.dart';
import '../../features/files/domain/usecases/get_user_files_usecase.dart';
import '../../features/files/domain/usecases/create_folder_usecase.dart';
import '../../features/files/domain/usecases/delete_file_item_usecase.dart';
import '../../features/files/presentation/bloc/files_bloc.dart';
import '../../features/history/data/datasources/history_local_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/get_history_usecase.dart';
import '../../features/history/domain/usecases/clear_history_usecase.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../permissions/data/repositories/permissions_repository_impl.dart';
import '../permissions/domain/repositories/permissions_repository.dart';
import '../permissions/domain/usecases/request_app_permissions_usecase.dart';
import '../permissions/domain/usecases/check_app_permissions_usecase.dart';
import '../permissions/bloc/permissions_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── External ──────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => DatabaseHelper.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);

  // ─── Auth Feature ──────────────────────────────────────
  sl.registerLazySingleton(() => AuthRemoteDatasource(sl(), sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerFactory(
    () => AuthBloc(
      loginUsecase: sl(),
      registerUsecase: sl(),
      getCurrentUserUsecase: sl(),
      logoutUsecase: sl(),
      forgotPasswordUsecase: sl(),
      updateProfileUseCase: sl(),
      updatePasswordUseCase: sl(),
      deleteAccountUseCase: sl(),
    ),
  );

  // ─── QR Generator Feature ─────────────────────────────
  sl.registerLazySingleton(() => QrLocalDatasource(sl()));
  sl.registerLazySingleton(() => QrRemoteDatasource(sl()));
  sl.registerLazySingleton<QrRepository>(() => QrRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GenerateQrUsecase(sl()));
  sl.registerLazySingleton(() => GetGeneratedItemsUsecase(sl()));
  sl.registerLazySingleton(() => DeleteGeneratedItemUsecase(sl()));
  sl.registerFactory(
    () => QrGeneratorBloc(
      generateQrUsecase: sl(),
      getGeneratedItemsUsecase: sl(),
      deleteGeneratedItemUsecase: sl(),
    ),
  );

  // ─── Scanner Feature ──────────────────────────────────
  sl.registerLazySingleton(() => ScanLocalDatasource(sl()));
  sl.registerLazySingleton<ScanRepository>(() => ScanRepositoryImpl(sl()));
  sl.registerLazySingleton(() => SaveScanUsecase(sl()));
  sl.registerLazySingleton(() => GetScanHistoryUsecase(sl()));
  sl.registerFactory(
    () => ScannerBloc(saveScanUsecase: sl(), getScanHistoryUsecase: sl()),
  );

  // ─── Files Feature ────────────────────────────────────
  sl.registerLazySingleton(() => FilesLocalDatasource(sl()));
  sl.registerLazySingleton(() => FilesRemoteDatasource(sl(), sl(), sl()));
  sl.registerLazySingleton<FilesRepository>(
    () => FilesRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton(() => GetUserFilesUsecase(sl()));
  sl.registerLazySingleton(() => CreateFolderUsecase(sl()));
  sl.registerLazySingleton(() => DeleteFileItemUsecase(sl()));
  sl.registerFactory(
    () => FilesBloc(
      getUserFilesUsecase: sl(),
      createFolderUsecase: sl(),
      deleteFileItemUsecase: sl(),
    ),
  );

  // ─── History Feature ──────────────────────────────────
  sl.registerLazySingleton(() => HistoryLocalDatasource(sl()));
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetHistoryUsecase(sl()));
  sl.registerLazySingleton(() => ClearHistoryUsecase(sl()));
  sl.registerFactory(
    () => HistoryBloc(getHistoryUsecase: sl(), clearHistoryUsecase: sl()),
  );

  // ─── Permissions Feature ──────────────────────────────
  sl.registerLazySingleton<PermissionsRepository>(
    () => PermissionsRepositoryImpl(),
  );
  sl.registerLazySingleton(() => CheckAppPermissionsUsecase(sl()));
  sl.registerLazySingleton(() => RequestAppPermissionsUsecase(sl()));
  sl.registerFactory(
    () => PermissionsBloc(
      checkAppPermissionsUsecase: sl(),
      requestAppPermissionsUsecase: sl(),
    ),
  );
}
