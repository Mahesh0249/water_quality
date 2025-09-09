"""
Pydantic models for API request/response schemas.
"""

from datetime import datetime
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field
from enum import Enum


class AssessmentStatus(str, Enum):
    """Assessment processing status."""
    NOT_STARTED = "not_started"
    RECORDING = "recording"
    PROCESSING = "processing"
    COMPLETED = "completed"
    ERROR = "error"


class FitnessLevel(str, Enum):
    """User fitness levels."""
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"
    ELITE = "elite"


class SurfaceType(str, Enum):
    """Running surface types."""
    TRACK = "track"
    TREADMILL = "treadmill"
    ROAD = "road"
    TRAIL = "trail"


class ResultQuality(str, Enum):
    """Assessment result quality indicators."""
    EXCELLENT = "excellent"
    GOOD = "good"
    FAIR = "fair"
    POOR = "poor"


class UserProfileModel(BaseModel):
    """User profile data model."""
    id: str
    email: str
    display_name: Optional[str] = None
    photo_url: Optional[str] = None
    age: Optional[int] = Field(None, ge=10, le=100)
    height: Optional[float] = Field(None, ge=100, le=250, description="Height in cm")
    weight: Optional[float] = Field(None, ge=30, le=200, description="Weight in kg")
    fitness_level: FitnessLevel = FitnessLevel.BEGINNER
    preferred_surface: Optional[SurfaceType] = None
    goals: List[str] = []
    personal_bests: Optional[Dict[str, Any]] = None
    created_at: datetime
    updated_at: Optional[datetime] = None


class PoseKeypointModel(BaseModel):
    """Individual pose keypoint data."""
    name: str
    x: float
    y: float
    confidence: float = Field(ge=0.0, le=1.0)
    timestamp: int = Field(description="Timestamp in milliseconds")


class RunningMetricsModel(BaseModel):
    """Running biomechanics metrics."""
    cadence: float = Field(ge=120, le=220, description="Steps per minute")
    stride_length: float = Field(ge=0.5, le=2.5, description="Stride length in meters")
    ground_contact_time: float = Field(ge=150, le=350, description="Contact time in ms")
    vertical_oscillation: float = Field(ge=4, le=15, description="Vertical bounce in cm")
    foot_strike_pattern: float = Field(ge=0, le=1, description="Strike pattern score")
    arm_swing_angle: float = Field(ge=10, le=30, description="Arm swing in degrees")
    body_lean: float = Field(ge=0, le=10, description="Forward lean in degrees")
    symmetry_score: float = Field(ge=0, le=1, description="Left-right symmetry")
    keypoints: List[PoseKeypointModel] = []


class TalentScoreModel(BaseModel):
    """AI-generated talent assessment score."""
    overall_score: float = Field(ge=0, le=100, description="Overall talent score")
    category_scores: Dict[str, float] = Field(
        description="Scores by category (efficiency, form, potential, etc.)"
    )
    quality: ResultQuality
    strengths: List[str] = Field(description="Identified strengths")
    improvement_areas: List[str] = Field(description="Areas for improvement")
    recommendation: str = Field(description="Personalized recommendation")


class AssessmentModel(BaseModel):
    """Complete assessment data model."""
    id: str
    user_id: str
    created_at: datetime
    status: AssessmentStatus
    video_url: Optional[str] = None
    metrics: Optional[RunningMetricsModel] = None
    score: Optional[TalentScoreModel] = None
    feedback: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None


class RecordingSessionModel(BaseModel):
    """Video recording session data."""
    id: str
    start_time: datetime
    end_time: Optional[datetime] = None
    duration: int = Field(description="Duration in milliseconds")
    local_path: Optional[str] = None
    quality: str = Field(description="Recording quality (480p, 720p, 1080p, 4K)")
    settings: Optional[Dict[str, Any]] = None


# Request/Response Models
class CreateAssessmentRequest(BaseModel):
    """Request to create new assessment."""
    surface_type: Optional[SurfaceType] = None
    notes: Optional[str] = None


class UpdateProfileRequest(BaseModel):
    """Request to update user profile."""
    display_name: Optional[str] = None
    age: Optional[int] = Field(None, ge=10, le=100)
    height: Optional[float] = Field(None, ge=100, le=250)
    weight: Optional[float] = Field(None, ge=30, le=200)
    fitness_level: Optional[FitnessLevel] = None
    preferred_surface: Optional[SurfaceType] = None
    goals: Optional[List[str]] = None


class VideoUploadRequest(BaseModel):
    """Request for video upload."""
    assessment_id: str
    file_size: int = Field(description="File size in bytes")
    duration: int = Field(description="Video duration in seconds")


class AnalysisRequest(BaseModel):
    """Request to start analysis."""
    assessment_id: str
    video_url: str
    user_profile: Optional[Dict[str, Any]] = None


class FeedbackRequest(BaseModel):
    """Request for personalized feedback."""
    assessment_id: str
    rating: int = Field(ge=1, le=5, description="User rating of the assessment")
    comment: Optional[str] = None


# Response Models
class StatusResponse(BaseModel):
    """Generic status response."""
    status: str
    message: Optional[str] = None


class AssessmentStatusResponse(BaseModel):
    """Assessment status response."""
    id: str
    status: AssessmentStatus
    progress: Optional[float] = Field(None, ge=0, le=100)
    message: Optional[str] = None
    estimated_completion: Optional[datetime] = None


class AnalyticsResponse(BaseModel):
    """User analytics response."""
    user_id: str
    total_assessments: int
    average_score: Optional[float] = None
    best_score: Optional[float] = None
    improvement_trend: str = Field(description="positive, negative, or stable")
    recent_assessments: List[Dict[str, Any]] = []
    achievements: List[str] = []


class HealthCheckResponse(BaseModel):
    """Health check response."""
    status: str
    service: str
    version: str
    checks: Optional[Dict[str, str]] = None
    timestamp: datetime = Field(default_factory=datetime.now)