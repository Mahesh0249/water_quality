import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/assessment_model.dart';
import '../utils/constants.dart';

/// API service for backend communication
class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;

  ApiService._internal();

  late final Dio _dio;

  /// Initialize API service
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add authentication interceptor
    _dio.interceptors.add(AuthInterceptor());
    
    // Add logging interceptor in debug mode
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  /// Upload video for analysis
  Future<String> uploadVideoForAnalysis({
    required File videoFile,
    required String assessmentId,
    void Function(double)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(
          videoFile.path,
          filename: 'assessment_$assessmentId.mp4',
        ),
        'assessment_id': assessmentId,
      });

      final response = await _dio.post(
        '/assessments/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (total != -1) {
            final progress = sent / total;
            onProgress?.call(progress);
          }
        },
      );

      return response.data['video_url'] as String;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Start pose analysis
  Future<Map<String, dynamic>> startPoseAnalysis({
    required String assessmentId,
    required String videoUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/assessments/analyze',
        data: {
          'assessment_id': assessmentId,
          'video_url': videoUrl,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get analysis results
  Future<RunningMetrics> getAnalysisResults(String assessmentId) async {
    try {
      final response = await _dio.get('/assessments/$assessmentId/results');
      return RunningMetrics.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generate talent score
  Future<TalentScore> generateTalentScore({
    required String assessmentId,
    required RunningMetrics metrics,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      final response = await _dio.post(
        '/assessments/score',
        data: {
          'assessment_id': assessmentId,
          'metrics': metrics.toJson(),
          'user_profile': userProfile,
        },
      );

      return TalentScore.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get personalized feedback
  Future<String> getPersonalizedFeedback({
    required String assessmentId,
    required TalentScore score,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      final response = await _dio.post(
        '/assessments/feedback',
        data: {
          'assessment_id': assessmentId,
          'score': score.toJson(),
          'user_profile': userProfile,
        },
      );

      return response.data['feedback'] as String;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get assessment status
  Future<AssessmentStatus> getAssessmentStatus(String assessmentId) async {
    try {
      final response = await _dio.get('/assessments/$assessmentId/status');
      final statusString = response.data['status'] as String;
      
      return AssessmentStatus.values.firstWhere(
        (status) => status.toString().split('.').last == statusString,
        orElse: () => AssessmentStatus.error,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get user analytics
  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/analytics');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Submit user feedback
  Future<void> submitFeedback({
    required String assessmentId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _dio.post(
        '/feedback',
        data: {
          'assessment_id': assessmentId,
          'rating': rating,
          'comment': comment,
        },
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Handle Dio exceptions
  String _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] as String?;
        
        switch (statusCode) {
          case 400:
            return message ?? 'Bad request. Please check your input.';
          case 401:
            return 'Authentication failed. Please login again.';
          case 403:
            return 'Access denied. You don\'t have permission.';
          case 404:
            return 'Resource not found.';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return message ?? 'An error occurred. Please try again.';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}

/// Authentication interceptor for adding Firebase JWT tokens
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final token = await user.getIdToken();
        options.headers['Authorization'] = 'Bearer $token';
      } catch (e) {
        print('Error getting Firebase token: $e');
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle token refresh on 401 errors
    if (err.response?.statusCode == 401) {
      // Token might be expired, attempt to refresh
      _refreshTokenAndRetry(err, handler);
    } else {
      handler.next(err);
    }
  }

  Future<void> _refreshTokenAndRetry(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Force token refresh
        final token = await user.getIdToken(true);
        
        // Retry the original request with new token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $token';
        
        final response = await Dio().fetch(options);
        handler.resolve(response);
      } else {
        handler.next(err);
      }
    } catch (e) {
      handler.next(err);
    }
  }
}