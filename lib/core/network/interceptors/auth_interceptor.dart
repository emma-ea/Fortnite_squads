import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../constants/api_constants.dart';
import '../../services/storage_service.dart';

@injectable
class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  // Mutex to prevent multiple refreshes firing simultaneously
  bool _isRefreshing = false;

  AuthInterceptor(this._storageService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Get the token from secure storage
    final accessToken = await _storageService.getAccessToken();

    // 2. If it exists, inject it into the header [cite: 227]
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 3. Check if the error is a 401 Unauthorized [cite: 228]
    if (err.response?.statusCode == 401) {
      // If the failed request was already a refresh attempt, don't loop.
      if (err.requestOptions.path.contains('/auth/refresh')) {
        await _storageService.clearTokens();
        return handler.next(err);
      }

      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          // 4. Attempt to get a new token [cite: 233]
          final newAccessToken = await _refreshToken();

          if (newAccessToken != null) {
            _isRefreshing = false;

            // 5. Retry the original request with the new token [cite: 229]
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            // We use a fresh Dio instance to avoid interceptor recursion issues
            final retryResponse = await Dio(
              BaseOptions(
                baseUrl: options.baseUrl,
                headers: options.headers,
              ),
            ).request(
              options.path,
              data: options.data,
              queryParameters: options.queryParameters,
            );

            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // Refresh failed (e.g., refresh token expired too)
          _isRefreshing = false;
          await _storageService.clearTokens();
          // In a real app, you might trigger a BLoC event here to redirect to login
        }
      }
    }

    return handler.next(err);
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      // Explicitly creating a new Dio instance to bypass interceptors
      // preventing an infinite loop if this request also fails.
      final response = await Dio().post(
        '${ApiConstants.baseUrl}/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken']; // [cite: 234]
        await _storageService.saveAccessToken(newAccessToken);
        return newAccessToken;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
