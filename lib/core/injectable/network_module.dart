import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:catering/constants/const.dart';
import 'package:catering/Domain/TokenManager/token_service.dart';
import 'package:catering/core/injectable/injectable.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final tokenService = getIt<TokenService>();
        final token = await tokenService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final tokenService = getIt<TokenService>();
          final refreshToken = await tokenService.getRefreshToken();
          
          if (refreshToken != null) {
            try {
              final role = await tokenService.getRole() ?? 1;
              final String base = role == 1 ? 'owner' : 'staff';
              
              // Create a dedicated Dio instance for refresh to avoid circular dependency
              final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
              final response = await refreshDio.post(
                'api/v1/$base/refresh-token',
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                final newAccessToken = response.data['data']['accessToken'];
                final newRefreshToken = response.data['data']['refreshToken'];
                
                await tokenService.saveToken(newAccessToken);
                await tokenService.saveRefreshToken(newRefreshToken);

                // Retry original request with new token
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $newAccessToken';
                
                final retryResponse = await dio.fetch(options);
                return handler.resolve(retryResponse);
              }
            } catch (e) {
              // Refresh failed, clear session and proceed with error
              await tokenService.clearAll();
            }
          }
        }
        return handler.next(error);
      },
    ));

    return dio;
  }
}
