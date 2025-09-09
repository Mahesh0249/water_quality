import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/assessment_model.dart';

/// Firebase service for authentication and data management
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseService get instance => _instance;

  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Initialize Firebase service
  Future<void> initialize() async {
    // Set persistence for offline support
    await _firestore.enablePersistence(
      const PersistenceSettings(synchronizeTabs: true),
    );
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign up with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update user profile
      await result.user?.updateDisplayName(displayName);
      
      // Create user document in Firestore
      if (result.user != null) {
        await _createUserDocument(result.user!);
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final userModel = UserModel(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toJson());
  }

  /// Get user document from Firestore
  Future<UserModel?> getUserDocument(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }

  /// Update user document
  Future<void> updateUserDocument(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .update(user.toJson());
  }

  /// Save assessment to Firestore
  Future<void> saveAssessment(AssessmentModel assessment) async {
    await _firestore
        .collection('assessments')
        .doc(assessment.id)
        .set(assessment.toJson());
  }

  /// Get user assessments
  Stream<List<AssessmentModel>> getUserAssessments(String userId) {
    return _firestore
        .collection('assessments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssessmentModel.fromJson(doc.data()))
            .toList());
  }

  /// Get assessment by ID
  Future<AssessmentModel?> getAssessment(String assessmentId) async {
    try {
      final doc = await _firestore
          .collection('assessments')
          .doc(assessmentId)
          .get();
      if (doc.exists) {
        return AssessmentModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting assessment: $e');
      return null;
    }
  }

  /// Upload video to Firebase Storage
  Future<String> uploadVideo({
    required File videoFile,
    required String userId,
    required String assessmentId,
    void Function(double)? onProgress,
  }) async {
    try {
      final fileName = 'assessments/$userId/$assessmentId.mp4';
      final ref = _storage.ref().child(fileName);
      
      final uploadTask = ref.putFile(videoFile);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });
      
      await uploadTask;
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading video: $e');
      throw Exception('Failed to upload video');
    }
  }

  /// Upload profile image
  Future<String> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final fileName = 'profiles/$userId/avatar.jpg';
      final ref = _storage.ref().child(fileName);
      
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image');
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}