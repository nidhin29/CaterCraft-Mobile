// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:catering/Application/booking/booking_cubit.dart' as _i767;
import 'package:catering/Application/Chat/chat_cubit.dart' as _i344;
import 'package:catering/Application/loggedin/loggedin_cubit.dart' as _i75;
import 'package:catering/Application/Owner/owner_cubit.dart' as _i980;
import 'package:catering/Application/signin/signin_cubit.dart' as _i388;
import 'package:catering/Application/Staff/staff_cubit.dart' as _i324;
import 'package:catering/core/injectable/network_module.dart' as _i565;
import 'package:catering/Domain/bookings/booking_service.dart' as _i346;
import 'package:catering/Domain/Chat/chat_service.dart' as _i872;
import 'package:catering/Domain/LoggedIn/logged_in_service.dart' as _i712;
import 'package:catering/Domain/Owner/owner_service.dart' as _i430;
import 'package:catering/Domain/Security/security_service.dart' as _i165;
import 'package:catering/Domain/Service/service_management_service.dart'
    as _i951;
import 'package:catering/Domain/SignIn/sign_in_service.dart' as _i675;
import 'package:catering/Domain/TokenManager/token_service.dart' as _i870;
import 'package:catering/Infrastructure/booking/booking_repo.dart' as _i284;
import 'package:catering/Infrastructure/Chat/chat_local_db.dart' as _i255;
import 'package:catering/Infrastructure/Chat/chat_repo.dart' as _i686;
import 'package:catering/Infrastructure/Core/injectable_module.dart' as _i873;
import 'package:catering/Infrastructure/Core/socket_service.dart' as _i717;
import 'package:catering/Infrastructure/LoggedIn/logged_in_repo.dart' as _i852;
import 'package:catering/Infrastructure/Owner/owner_repo.dart' as _i699;
import 'package:catering/Infrastructure/Service/service_management_repo.dart'
    as _i501;
import 'package:catering/Infrastructure/SignIn/sign_in_repo.dart' as _i545;
import 'package:catering/Infrastructure/TokenManager/token_repo.dart' as _i623;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final injectableModule = _$InjectableModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => injectableModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i165.SecurityService>(() => _i165.SecurityService());
    gh.lazySingleton<_i717.SocketService>(() => _i717.SocketService());
    gh.lazySingleton<_i255.ChatLocalDb>(() => _i255.ChatLocalDb());
    gh.lazySingleton<_i346.BookingService>(
      () => _i284.BookingRepo(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i870.TokenService>(
      () => _i623.TokenRepo(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i872.ChatService>(
      () => _i686.ChatRepo(gh<_i361.Dio>(), gh<_i255.ChatLocalDb>()),
    );
    gh.factory<_i767.BookingCubit>(
      () => _i767.BookingCubit(gh<_i346.BookingService>()),
    );
    gh.lazySingleton<_i675.SignInService>(
      () => _i545.SignInRepo(gh<_i361.Dio>(), gh<_i870.TokenService>()),
    );
    gh.lazySingleton<_i712.LoggedInService>(
      () => _i852.LoggedInRepo(gh<_i361.Dio>(), gh<_i870.TokenService>()),
    );
    gh.lazySingleton<_i951.ServiceManagementService>(
      () => _i501.ServiceManagementRepo(
        gh<_i361.Dio>(),
        gh<_i870.TokenService>(),
      ),
    );
    gh.factory<_i388.SigninCubit>(
      () => _i388.SigninCubit(
        gh<_i675.SignInService>(),
        gh<_i870.TokenService>(),
      ),
    );
    gh.lazySingleton<_i430.OwnerService>(
      () => _i699.OwnerRepo(gh<_i361.Dio>(), gh<_i870.TokenService>()),
    );
    gh.lazySingleton<_i324.StaffCubit>(
      () => _i324.StaffCubit(
        gh<_i346.BookingService>(),
        gh<_i430.OwnerService>(),
      ),
    );
    gh.factory<_i75.LoggedinCubit>(
      () => _i75.LoggedinCubit(
        gh<_i870.TokenService>(),
        gh<_i712.LoggedInService>(),
      ),
    );
    gh.factory<_i344.ChatCubit>(
      () => _i344.ChatCubit(
        gh<_i872.ChatService>(),
        gh<_i717.SocketService>(),
        gh<_i165.SecurityService>(),
      ),
    );
    gh.lazySingleton<_i980.OwnerCubit>(
      () => _i980.OwnerCubit(
        gh<_i346.BookingService>(),
        gh<_i951.ServiceManagementService>(),
        gh<_i430.OwnerService>(),
        gh<_i717.SocketService>(),
        gh<_i872.ChatService>(),
        gh<_i165.SecurityService>(),
      ),
    );
    return this;
  }
}

class _$InjectableModule extends _i873.InjectableModule {}

class _$NetworkModule extends _i565.NetworkModule {}
