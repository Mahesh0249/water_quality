# SportsTalent AI Backend API Documentation

## Overview

The SportsTalent AI Backend API provides endpoints for video upload, pose analysis, talent assessment, and user management for the AI-powered sports talent assessment platform.

## Base URL

- **Development**: `http://localhost:8000/api/v1`
- **Production**: `https://api.sportstalent.ai/v1`

## Authentication

All API endpoints require authentication using Firebase JWT tokens.

Include the token in the Authorization header:
```
Authorization: Bearer <firebase_jwt_token>
```

## Endpoints

### Health Check

#### GET /health/
Basic health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "service": "sportsTalent-ai-backend",
  "version": "1.0.0"
}
```

#### GET /health/detailed
Detailed health check with service dependencies.

**Response:**
```json
{
  "status": "healthy",
  "service": "sportsTalent-ai-backend",
  "version": "1.0.0",
  "checks": {
    "api": "healthy",
    "firebase": "healthy",
    "openai": "healthy",
    "storage": "healthy"
  }
}
```

### Authentication

#### POST /auth/login
Authenticate user and return access token.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "secure_password"
}
```

**Response:**
```json
{
  "access_token": "jwt_token_here",
  "token_type": "bearer",
  "expires_in": 2592000
}
```

#### POST /auth/logout
Logout user and invalidate token.

**Response:**
```json
{
  "message": "Successfully logged out"
}
```

#### POST /auth/refresh
Refresh access token.

**Response:**
```json
{
  "access_token": "new_jwt_token_here",
  "token_type": "bearer",
  "expires_in": 2592000
}
```

### User Management

#### GET /users/me
Get current user profile.

**Response:**
```json
{
  "id": "user_id",
  "email": "user@example.com",
  "display_name": "John Doe",
  "age": 25,
  "height": 175.0,
  "weight": 70.0,
  "fitness_level": "intermediate",
  "created_at": "2024-01-01T00:00:00Z"
}
```

#### PUT /users/me
Update current user profile.

**Request:**
```json
{
  "display_name": "John Doe",
  "age": 26,
  "height": 175.0,
  "weight": 68.0,
  "fitness_level": "advanced"
}
```

**Response:**
```json
{
  "id": "user_id",
  "email": "user@example.com",
  "display_name": "John Doe",
  "age": 26,
  "height": 175.0,
  "weight": 68.0,
  "fitness_level": "advanced",
  "created_at": "2024-01-01T00:00:00Z"
}
```

#### GET /users/{user_id}/analytics
Get user analytics and performance data.

**Response:**
```json
{
  "user_id": "user_id",
  "total_assessments": 5,
  "average_score": 78.5,
  "best_score": 92.0,
  "improvement_trend": "positive",
  "recent_assessments": [
    {"date": "2024-01-15", "score": 85.0},
    {"date": "2024-01-10", "score": 82.0},
    {"date": "2024-01-05", "score": 79.0}
  ]
}
```

### Assessments

#### POST /assessments/upload
Upload video file for pose analysis.

**Request:**
- **Content-Type**: `multipart/form-data`
- **Fields**:
  - `video`: Video file (MP4, MOV, or AVI, max 100MB)
  - `assessment_id`: Assessment ID

**Response:**
```json
{
  "id": "assessment_id",
  "status": "processing",
  "progress": 0.0,
  "message": "Video uploaded successfully, starting analysis..."
}
```

#### POST /assessments/analyze
Start pose analysis on uploaded video.

**Request:**
```json
{
  "assessment_id": "assessment_id",
  "video_url": "https://storage.example.com/video.mp4"
}
```

**Response:**
```json
{
  "assessment_id": "assessment_id",
  "status": "started",
  "message": "Pose analysis started successfully"
}
```

#### GET /assessments/{assessment_id}/status
Get assessment processing status.

**Response:**
```json
{
  "id": "assessment_id",
  "status": "completed",
  "progress": 100.0,
  "message": "Assessment completed successfully"
}
```

#### GET /assessments/{assessment_id}/results
Get pose analysis results and running metrics.

**Response:**
```json
{
  "cadence": 165.0,
  "stride_length": 1.35,
  "ground_contact_time": 225.0,
  "vertical_oscillation": 8.2,
  "foot_strike_pattern": 0.7,
  "arm_swing_angle": 18.5,
  "body_lean": 4.2,
  "symmetry_score": 0.85
}
```

#### POST /assessments/score
Generate talent score using AI analysis.

**Request:**
```json
{
  "assessment_id": "assessment_id",
  "metrics": {
    "cadence": 165.0,
    "stride_length": 1.35,
    "ground_contact_time": 225.0,
    "vertical_oscillation": 8.2,
    "foot_strike_pattern": 0.7,
    "arm_swing_angle": 18.5,
    "body_lean": 4.2,
    "symmetry_score": 0.85
  },
  "user_profile": {
    "age": 25,
    "fitness_level": "intermediate"
  }
}
```

**Response:**
```json
{
  "overall_score": 78.5,
  "category_scores": {
    "efficiency": 82.0,
    "form": 75.0,
    "potential": 83.0,
    "consistency": 74.0
  },
  "quality": "good",
  "strengths": [
    "Excellent cadence consistency",
    "Good forward lean angle",
    "Balanced arm swing"
  ],
  "improvement_areas": [
    "Reduce vertical oscillation",
    "Work on symmetry between left and right leg",
    "Optimize foot strike pattern"
  ],
  "recommendation": "Focus on cadence drills and core strengthening exercises to improve running efficiency."
}
```

#### POST /assessments/feedback
Generate personalized feedback using LLM.

**Request:**
```json
{
  "assessment_id": "assessment_id",
  "score": {
    "overall_score": 78.5,
    "quality": "good",
    "strengths": ["Excellent cadence consistency"],
    "improvement_areas": ["Reduce vertical oscillation"],
    "recommendation": "Focus on cadence drills..."
  },
  "user_profile": {
    "age": 25,
    "fitness_level": "intermediate"
  }
}
```

**Response:**
```json
{
  "feedback": "Based on your assessment, you show strong potential with an overall score of 78.5/100. Your key strengths include excellent cadence consistency, good forward lean angle. To improve further, focus on reducing vertical oscillation, working on symmetry between left and right leg. Focus on cadence drills and core strengthening exercises to improve running efficiency. Keep up the great work and continue practicing regularly!"
}
```

#### GET /assessments/{user_id}/history
Get user's assessment history.

**Query Parameters:**
- `limit`: Number of assessments to return (default: 10)

**Response:**
```json
[
  {
    "id": "assessment_1",
    "user_id": "user_id",
    "created_at": "2024-01-15T10:00:00Z",
    "status": "completed",
    "video_url": "https://storage.example.com/videos/user_id/assessment_1.mp4"
  }
]
```

## Error Responses

All endpoints may return the following error responses:

#### 400 Bad Request
```json
{
  "detail": "Bad request. Please check your input."
}
```

#### 401 Unauthorized
```json
{
  "detail": "Authentication failed. Please login again."
}
```

#### 403 Forbidden
```json
{
  "detail": "Access denied. You don't have permission."
}
```

#### 404 Not Found
```json
{
  "detail": "Resource not found."
}
```

#### 500 Internal Server Error
```json
{
  "detail": "Server error. Please try again later."
}
```

## Rate Limiting

API requests are limited to 100 requests per minute per authenticated user.

## File Upload Limits

- **Video files**: Maximum 100MB, formats: MP4, MOV, AVI
- **Image files**: Maximum 5MB, formats: JPG, JPEG, PNG

## WebSocket Endpoints

### Real-time Assessment Updates

Connect to `/ws/assessment/{assessment_id}` for real-time updates during video processing.

**Messages:**
```json
{
  "type": "status_update",
  "data": {
    "assessment_id": "assessment_id",
    "status": "processing",
    "progress": 45.0,
    "message": "Analyzing pose data..."
  }
}
```