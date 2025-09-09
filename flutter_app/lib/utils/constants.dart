import 'package:flutter/material.dart';

/// App-wide constants and configuration values
class AppConstants {
  static const String appName = 'SportsTalent AI';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.sportstalent.ai/v1';
  static const String localBaseUrl = 'http://localhost:8000/api/v1';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String onboardingCompleteKey = 'onboarding_complete';
  
  // Video Recording Settings
  static const int maxRecordingDuration = 60; // seconds
  static const int minRecordingDuration = 5;  // seconds
  
  // Pose Detection Settings
  static const double poseDetectionConfidence = 0.7;
  static const int maxPoseDetectionResults = 1;
  
  // Assessment Settings
  static const int requiredRunningSteps = 20;
  static const double cadenceThreshold = 150.0; // steps per minute
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// Route names for navigation
class AppRoutes {
  static const String auth = 'auth';
  static const String home = 'home';
  static const String assessment = 'assessment';
  static const String camera = 'camera';
  static const String results = 'results';
  static const String profile = 'profile';
}

/// Assessment status enumeration
enum AssessmentStatus {
  notStarted,
  recording,
  processing,
  completed,
  error,
}

/// User fitness levels
enum FitnessLevel {
  beginner,
  intermediate,
  advanced,
  elite,
}

/// Running surface types
enum SurfaceType {
  track,
  treadmill,
  road,
  trail,
}

/// Assessment result quality indicators
enum ResultQuality {
  excellent,
  good,
  fair,
  poor,
}

/// Extension methods for enums
extension AssessmentStatusExtension on AssessmentStatus {
  String get displayName {
    switch (this) {
      case AssessmentStatus.notStarted:
        return 'Ready to Start';
      case AssessmentStatus.recording:
        return 'Recording...';
      case AssessmentStatus.processing:
        return 'Analyzing...';
      case AssessmentStatus.completed:
        return 'Completed';
      case AssessmentStatus.error:
        return 'Error';
    }
  }
  
  Color get color {
    switch (this) {
      case AssessmentStatus.notStarted:
        return Colors.grey;
      case AssessmentStatus.recording:
        return Colors.red;
      case AssessmentStatus.processing:
        return Colors.orange;
      case AssessmentStatus.completed:
        return Colors.green;
      case AssessmentStatus.error:
        return Colors.red;
    }
  }
}

extension FitnessLevelExtension on FitnessLevel {
  String get displayName {
    switch (this) {
      case FitnessLevel.beginner:
        return 'Beginner';
      case FitnessLevel.intermediate:
        return 'Intermediate';
      case FitnessLevel.advanced:
        return 'Advanced';
      case FitnessLevel.elite:
        return 'Elite';
    }
  }
}

extension SurfaceTypeExtension on SurfaceType {
  String get displayName {
    switch (this) {
      case SurfaceType.track:
        return 'Track';
      case SurfaceType.treadmill:
        return 'Treadmill';
      case SurfaceType.road:
        return 'Road';
      case SurfaceType.trail:
        return 'Trail';
    }
  }
}

extension ResultQualityExtension on ResultQuality {
  String get displayName {
    switch (this) {
      case ResultQuality.excellent:
        return 'Excellent';
      case ResultQuality.good:
        return 'Good';
      case ResultQuality.fair:
        return 'Fair';
      case ResultQuality.poor:
        return 'Poor';
    }
  }
  
  Color get color {
    switch (this) {
      case ResultQuality.excellent:
        return Colors.green;
      case ResultQuality.good:
        return Colors.lightGreen;
      case ResultQuality.fair:
        return Colors.orange;
      case ResultQuality.poor:
        return Colors.red;
    }
  }
}