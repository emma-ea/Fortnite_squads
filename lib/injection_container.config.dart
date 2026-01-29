// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i5;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'core/network/dio_client.dart' as _i18;
import 'core/network/interceptors/auth_interceptor.dart' as _i4;
import 'core/services/storage_service.dart' as _i3;
import 'domain/repositories/auth_repository.dart' as _i10;
import 'domain/repositories/auth_repository_impl.dart' as _i11;
import 'domain/repositories/chat_repository.dart' as _i12;
import 'domain/repositories/chat_repository_impl.dart' as _i13;
import 'domain/repositories/squad_repository.dart' as _i6;
import 'domain/repositories/squad_repository_impl.dart' as _i7;
import 'domain/repositories/user_repository.dart' as _i8;
import 'domain/repositories/user_repository_impl.dart' as _i9;
import 'presentation/blocs/auth/auth_bloc.dart' as _i16;
import 'presentation/blocs/chat/chat_bloc.dart' as _i17;
import 'presentation/blocs/squad/squad_bloc.dart' as _i14;
import 'presentation/blocs/user/user_bloc.dart' as _i15;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i3.StorageService>(() => _i3.StorageServiceImpl());
    gh.factory<_i4.AuthInterceptor>(
        () => _i4.AuthInterceptor(gh<_i3.StorageService>()));
    gh.lazySingleton<_i5.Dio>(
        () => networkModule.dio(gh<_i4.AuthInterceptor>()));
    gh.lazySingleton<_i6.SquadRepository>(
        () => _i7.SquadRepositoryImpl(gh<_i5.Dio>()));
    gh.lazySingleton<_i8.UserRepository>(
        () => _i9.UserRepositoryImpl(gh<_i5.Dio>()));
    gh.lazySingleton<_i10.AuthRepository>(() => _i11.AuthRepositoryImpl(
          gh<_i5.Dio>(),
          gh<_i3.StorageService>(),
        ));
    gh.lazySingleton<_i12.ChatRepository>(
        () => _i13.ChatRepositoryImpl(gh<_i5.Dio>()));
    gh.factory<_i14.SquadBloc>(() => _i14.SquadBloc(gh<_i6.SquadRepository>()));
    gh.factory<_i15.UserBloc>(() => _i15.UserBloc(gh<_i8.UserRepository>()));
    gh.factory<_i16.AuthBloc>(() => _i16.AuthBloc(
          gh<_i10.AuthRepository>(),
          gh<_i3.StorageService>(),
        ));
    gh.factory<_i17.ChatBloc>(() => _i17.ChatBloc(gh<_i12.ChatRepository>()));
    return this;
  }
}

class _$NetworkModule extends _i18.NetworkModule {}
