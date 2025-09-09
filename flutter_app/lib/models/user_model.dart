import 'package:json_annotation/json_annotation.dart';
import '../utils/constants.dart';

part 'user_model.g.dart';

/// User model representing an athlete's profile
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserProfile? profile;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? profile,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
    );
  }
}

/// User profile containing athlete-specific information
@JsonSerializable()
class UserProfile {
  final int? age;
  final double? height; // in cm
  final double? weight; // in kg
  final FitnessLevel fitnessLevel;
  final String? preferredSurface;
  final List<String> goals;
  final Map<String, dynamic>? personalBests;

  const UserProfile({
    this.age,
    this.height,
    this.weight,
    required this.fitnessLevel,
    this.preferredSurface,
    this.goals = const [],
    this.personalBests,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    int? age,
    double? height,
    double? weight,
    FitnessLevel? fitnessLevel,
    String? preferredSurface,
    List<String>? goals,
    Map<String, dynamic>? personalBests,
  }) {
    return UserProfile(
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      preferredSurface: preferredSurface ?? this.preferredSurface,
      goals: goals ?? this.goals,
      personalBests: personalBests ?? this.personalBests,
    );
  }
}