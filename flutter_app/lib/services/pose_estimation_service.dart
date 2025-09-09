import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/assessment_model.dart';
import '../utils/constants.dart';

/// Pose estimation service using MediaPipe and ML Kit
class PoseEstimationService {
  static final PoseEstimationService _instance = PoseEstimationService._internal();
  static PoseEstimationService get instance => _instance;

  PoseEstimationService._internal();

  PoseDetector? _poseDetector;
  Interpreter? _interpreter;
  bool _isInitialized = false;

  /// Initialize pose estimation service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize ML Kit pose detector
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
          minimumConfidence: AppConstants.poseDetectionConfidence,
          maximumResults: AppConstants.maxPoseDetectionResults,
        ),
      );

      // Load TensorFlow Lite model for advanced analysis
      await _loadTFLiteModel();

      _isInitialized = true;
      print('Pose estimation service initialized successfully');
    } catch (e) {
      print('Error initializing pose estimation service: $e');
      throw Exception('Failed to initialize pose estimation service');
    }
  }

  /// Load TensorFlow Lite model
  Future<void> _loadTFLiteModel() async {
    try {
      // Load the pose analysis model
      _interpreter = await Interpreter.fromAsset('assets/models/pose_analysis_model.tflite');
      print('TensorFlow Lite model loaded successfully');
    } catch (e) {
      print('Error loading TensorFlow Lite model: $e');
      // Continue without TFLite model for basic functionality
    }
  }

  /// Detect poses from camera image
  Future<List<PoseKeypoint>> detectPosesFromImage(CameraImage image) async {
    if (!_isInitialized || _poseDetector == null) {
      throw Exception('Pose estimation service not initialized');
    }

    try {
      // Convert CameraImage to InputImage
      final inputImage = _convertCameraImageToInputImage(image);
      
      // Detect poses
      final poses = await _poseDetector!.processImage(inputImage);
      
      if (poses.isEmpty) return [];

      // Convert poses to keypoints
      final keypoints = <PoseKeypoint>[];
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      for (final pose in poses) {
        for (final landmark in pose.landmarks.values) {
          keypoints.add(PoseKeypoint(
            name: landmark.type.name,
            x: landmark.x,
            y: landmark.y,
            confidence: 1.0, // ML Kit doesn't provide confidence per landmark
            timestamp: timestamp,
          ));
        }
      }

      return keypoints;
    } catch (e) {
      print('Error detecting poses: $e');
      return [];
    }
  }

  /// Analyze running form from video file
  Future<RunningMetrics> analyzeRunningForm(File videoFile) async {
    if (!_isInitialized) {
      throw Exception('Pose estimation service not initialized');
    }

    try {
      // This is a simplified implementation
      // In production, you would process video frame by frame
      final allKeypoints = <PoseKeypoint>[];
      
      // For demo purposes, create mock running metrics
      // In production, this would be calculated from actual video analysis
      return _calculateRunningMetrics(allKeypoints);
    } catch (e) {
      print('Error analyzing running form: $e');
      throw Exception('Failed to analyze running form');
    }
  }

  /// Calculate running metrics from keypoints
  RunningMetrics _calculateRunningMetrics(List<PoseKeypoint> keypoints) {
    // This is a simplified calculation for demo purposes
    // In production, you would implement sophisticated biomechanical analysis
    
    return RunningMetrics(
      cadence: _calculateCadence(keypoints),
      strideLength: _calculateStrideLength(keypoints),
      groundContactTime: _calculateGroundContactTime(keypoints),
      verticalOscillation: _calculateVerticalOscillation(keypoints),
      footStrikePattern: _calculateFootStrikePattern(keypoints),
      armSwingAngle: _calculateArmSwingAngle(keypoints),
      bodyLean: _calculateBodyLean(keypoints),
      symmetryScore: _calculateSymmetryScore(keypoints),
      keypoints: keypoints,
    );
  }

  /// Calculate cadence (steps per minute)
  double _calculateCadence(List<PoseKeypoint> keypoints) {
    // Mock calculation - in production would analyze foot strikes over time
    return 165.0 + (keypoints.length * 0.1) % 20; // Random between 165-185
  }

  /// Calculate stride length
  double _calculateStrideLength(List<PoseKeypoint> keypoints) {
    // Mock calculation - in production would analyze hip and ankle positions
    return 1.2 + (keypoints.length * 0.01) % 0.4; // Random between 1.2-1.6m
  }

  /// Calculate ground contact time
  double _calculateGroundContactTime(List<PoseKeypoint> keypoints) {
    // Mock calculation - in production would analyze foot contact phases
    return 200 + (keypoints.length * 0.5) % 50; // Random between 200-250ms
  }

  /// Calculate vertical oscillation
  double _calculateVerticalOscillation(List<PoseKeypoint> keypoints) {
    // Mock calculation - in production would analyze center of mass movement
    return 6.0 + (keypoints.length * 0.05) % 4.0; // Random between 6-10cm
  }

  /// Calculate foot strike pattern
  double _calculateFootStrikePattern(List<PoseKeypoint> keypoints) {
    // Mock calculation - in production would analyze ankle angle at contact
    return 0.3 + (keypoints.length * 0.001) % 0.4; // Random pattern score
  }

  /// Calculate arm swing angle
  double _calculateArmSwingAngle(List<PoseKeypoint> keypoints) {
    // Mock calculation - in production would analyze shoulder-elbow-wrist angles
    return 15 + (keypoints.length * 0.1) % 10; // Random between 15-25 degrees
  }

  /// Calculate body lean
  double _calculateBodyLean(List<PoseKeypoint> keypoints) {
    // Mock calculation - in production would analyze torso angle
    return 3.0 + (keypoints.length * 0.02) % 4.0; // Random between 3-7 degrees
  }

  /// Calculate symmetry score
  double _calculateSymmetryScore(List<PoseKeypoint> keypoints) {
    // Mock calculation - in production would compare left vs right side metrics
    return 0.7 + (keypoints.length * 0.001) % 0.3; // Random between 0.7-1.0
  }

  /// Convert CameraImage to InputImage for ML Kit
  InputImage _convertCameraImageToInputImage(CameraImage image) {
    // Get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    // Get image dimensions
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());

    // Create InputImageData
    final inputImageData = InputImageMetadata(
      size: imageSize,
      rotation: InputImageRotation.rotation0deg,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    // Convert to InputImage
    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: inputImageData,
    );
  }

  /// Real-time pose analysis for camera preview
  Stream<List<PoseKeypoint>> getRealTimePoseStream(Stream<CameraImage> imageStream) async* {
    await for (final image in imageStream) {
      try {
        final keypoints = await detectPosesFromImage(image);
        yield keypoints;
      } catch (e) {
        print('Error in real-time pose detection: $e');
        yield [];
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _poseDetector?.close();
    _interpreter?.close();
    _isInitialized = false;
  }

  /// Check if service is ready
  bool get isReady => _isInitialized;

  /// Get supported camera resolutions for pose detection
  List<ResolutionPreset> getSupportedResolutions() {
    return [
      ResolutionPreset.medium,
      ResolutionPreset.high,
      ResolutionPreset.veryHigh,
    ];
  }

  /// Validate pose detection quality
  bool validatePoseQuality(List<PoseKeypoint> keypoints) {
    if (keypoints.isEmpty) return false;
    
    // Check if key running pose landmarks are detected
    final requiredLandmarks = [
      'left_hip',
      'right_hip',
      'left_knee',
      'right_knee',
      'left_ankle',
      'right_ankle',
    ];
    
    final detectedLandmarks = keypoints.map((kp) => kp.name.toLowerCase()).toSet();
    
    for (final landmark in requiredLandmarks) {
      if (!detectedLandmarks.contains(landmark)) {
        return false;
      }
    }
    
    // Check confidence levels
    final avgConfidence = keypoints
        .map((kp) => kp.confidence)
        .reduce((a, b) => a + b) / keypoints.length;
    
    return avgConfidence >= AppConstants.poseDetectionConfidence;
  }
}