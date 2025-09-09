"""
Unit tests for Flutter app models and services.
"""

import 'package:flutter_test/flutter_test.dart';
import 'package:sports_talent_ai/models/user_model.dart';
import 'package:sports_talent_ai/models/assessment_model.dart';
import 'package:sports_talent_ai/utils/constants.dart';

void main() {
  group('User Model Tests', () {
    test('should create UserModel with required fields', () {
      final user = UserModel(
        id: 'test_user',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );

      expect(user.id, 'test_user');
      expect(user.email, 'test@example.com');
      expect(user.displayName, isNull);
    });

    test('should create UserModel with profile', () {
      final profile = UserProfile(
        age: 25,
        height: 175.0,
        weight: 70.0,
        fitnessLevel: FitnessLevel.intermediate,
        goals: ['Improve running form', 'Increase speed'],
      );

      final user = UserModel(
        id: 'test_user',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
        profile: profile,
      );

      expect(user.profile?.age, 25);
      expect(user.profile?.fitnessLevel, FitnessLevel.intermediate);
      expect(user.profile?.goals.length, 2);
    });

    test('should copy UserModel with new values', () {
      final originalUser = UserModel(
        id: 'test_user',
        email: 'test@example.com',
        displayName: 'Original Name',
        createdAt: DateTime.now(),
      );

      final updatedUser = originalUser.copyWith(
        displayName: 'Updated Name',
      );

      expect(updatedUser.id, originalUser.id);
      expect(updatedUser.email, originalUser.email);
      expect(updatedUser.displayName, 'Updated Name');
    });
  });

  group('Assessment Model Tests', () {
    test('should create AssessmentModel with required fields', () {
      final assessment = AssessmentModel(
        id: 'test_assessment',
        userId: 'test_user',
        createdAt: DateTime.now(),
        status: AssessmentStatus.notStarted,
      );

      expect(assessment.id, 'test_assessment');
      expect(assessment.userId, 'test_user');
      expect(assessment.status, AssessmentStatus.notStarted);
      expect(assessment.metrics, isNull);
      expect(assessment.score, isNull);
    });

    test('should create RunningMetrics with valid values', () {
      final keypoints = [
        PoseKeypoint(
          name: 'left_hip',
          x: 100.0,
          y: 200.0,
          confidence: 0.95,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      ];

      final metrics = RunningMetrics(
        cadence: 165.0,
        strideLength: 1.35,
        groundContactTime: 225.0,
        verticalOscillation: 8.2,
        footStrikePattern: 0.7,
        armSwingAngle: 18.5,
        bodyLean: 4.2,
        symmetryScore: 0.85,
        keypoints: keypoints,
      );

      expect(metrics.cadence, 165.0);
      expect(metrics.keypoints.length, 1);
      expect(metrics.keypoints.first.name, 'left_hip');
    });

    test('should create TalentScore with categories', () {
      final score = TalentScore(
        overallScore: 78.5,
        categoryScores: {
          'efficiency': 82.0,
          'form': 75.0,
          'potential': 83.0,
          'consistency': 74.0,
        },
        quality: ResultQuality.good,
        strengths: ['Excellent cadence', 'Good form'],
        improvementAreas: ['Work on symmetry', 'Reduce oscillation'],
        recommendation: 'Focus on cadence drills and core strengthening.',
      );

      expect(score.overallScore, 78.5);
      expect(score.categoryScores['efficiency'], 82.0);
      expect(score.quality, ResultQuality.good);
      expect(score.strengths.length, 2);
      expect(score.improvementAreas.length, 2);
    });
  });

  group('Constants and Enums Tests', () {
    test('should have correct assessment status display names', () {
      expect(AssessmentStatus.notStarted.displayName, 'Ready to Start');
      expect(AssessmentStatus.recording.displayName, 'Recording...');
      expect(AssessmentStatus.processing.displayName, 'Analyzing...');
      expect(AssessmentStatus.completed.displayName, 'Completed');
      expect(AssessmentStatus.error.displayName, 'Error');
    });

    test('should have correct assessment status colors', () {
      expect(AssessmentStatus.notStarted.color, Colors.grey);
      expect(AssessmentStatus.recording.color, Colors.red);
      expect(AssessmentStatus.processing.color, Colors.orange);
      expect(AssessmentStatus.completed.color, Colors.green);
      expect(AssessmentStatus.error.color, Colors.red);
    });

    test('should have correct fitness level display names', () {
      expect(FitnessLevel.beginner.displayName, 'Beginner');
      expect(FitnessLevel.intermediate.displayName, 'Intermediate');
      expect(FitnessLevel.advanced.displayName, 'Advanced');
      expect(FitnessLevel.elite.displayName, 'Elite');
    });

    test('should have correct result quality colors', () {
      expect(ResultQuality.excellent.color, Colors.green);
      expect(ResultQuality.good.color, Colors.lightGreen);
      expect(ResultQuality.fair.color, Colors.orange);
      expect(ResultQuality.poor.color, Colors.red);
    });
  });

  group('App Constants Tests', () {
    test('should have correct configuration values', () {
      expect(AppConstants.maxRecordingDuration, 60);
      expect(AppConstants.minRecordingDuration, 5);
      expect(AppConstants.poseDetectionConfidence, 0.7);
      expect(AppConstants.requiredRunningSteps, 20);
    });

    test('should have correct animation durations', () {
      expect(AppConstants.shortAnimation, const Duration(milliseconds: 200));
      expect(AppConstants.mediumAnimation, const Duration(milliseconds: 300));
      expect(AppConstants.longAnimation, const Duration(milliseconds: 500));
    });
  });

  group('Route Names Tests', () {
    test('should have correct route names', () {
      expect(AppRoutes.auth, 'auth');
      expect(AppRoutes.home, 'home');
      expect(AppRoutes.assessment, 'assessment');
      expect(AppRoutes.camera, 'camera');
      expect(AppRoutes.results, 'results');
      expect(AppRoutes.profile, 'profile');
    });
  });
}