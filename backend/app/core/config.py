"""
Configuration settings for the FastAPI backend application.
"""

from typing import List, Optional
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Application settings
    DEBUG: bool = Field(default=True, description="Debug mode")
    HOST: str = Field(default="0.0.0.0", description="Host to bind to")
    PORT: int = Field(default=8000, description="Port to bind to")
    ALLOWED_HOSTS: List[str] = Field(
        default=["localhost", "127.0.0.1", "0.0.0.0"],
        description="Allowed hosts for CORS"
    )
    
    # API Configuration
    API_V1_PREFIX: str = Field(default="/api/v1", description="API version 1 prefix")
    SECRET_KEY: str = Field(
        default="your-secret-key-change-in-production",
        description="Secret key for JWT tokens"
    )
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(
        default=30 * 24 * 60,  # 30 days
        description="Access token expiration in minutes"
    )
    
    # Firebase Configuration
    FIREBASE_CREDENTIALS_PATH: Optional[str] = Field(
        default=None,
        description="Path to Firebase service account JSON file"
    )
    FIREBASE_PROJECT_ID: Optional[str] = Field(
        default=None,
        description="Firebase project ID"
    )
    
    # OpenAI Configuration
    OPENAI_API_KEY: Optional[str] = Field(
        default=None,
        description="OpenAI API key for LLM services"
    )
    
    # Google AI Configuration
    GOOGLE_AI_API_KEY: Optional[str] = Field(
        default=None,
        description="Google AI API key for Gemini"
    )
    
    # Google Cloud Configuration
    GOOGLE_CLOUD_PROJECT: Optional[str] = Field(
        default=None,
        description="Google Cloud project ID"
    )
    GOOGLE_CLOUD_BUCKET: Optional[str] = Field(
        default=None,
        description="Google Cloud Storage bucket for videos"
    )
    
    # ML Model Configuration
    POSE_MODEL_PATH: str = Field(
        default="./models/pose_estimation_model.tflite",
        description="Path to pose estimation TensorFlow Lite model"
    )
    TALENT_MODEL_PATH: str = Field(
        default="./models/talent_scoring_model.pkl",
        description="Path to talent scoring model"
    )
    
    # Video Processing Configuration
    MAX_VIDEO_SIZE_MB: int = Field(
        default=100,
        description="Maximum video file size in MB"
    )
    SUPPORTED_VIDEO_FORMATS: List[str] = Field(
        default=["mp4", "mov", "avi"],
        description="Supported video file formats"
    )
    VIDEO_PROCESSING_TIMEOUT: int = Field(
        default=300,  # 5 minutes
        description="Video processing timeout in seconds"
    )
    
    # Rate Limiting
    RATE_LIMIT_REQUESTS: int = Field(
        default=100,
        description="Number of requests per minute per user"
    )
    
    # Logging
    LOG_LEVEL: str = Field(default="INFO", description="Logging level")
    LOG_FORMAT: str = Field(
        default="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        description="Log format"
    )

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
    )


# Create global settings instance
settings = Settings()

# Validate required settings in production
if not settings.DEBUG:
    required_env_vars = [
        "SECRET_KEY",
        "FIREBASE_PROJECT_ID",
        "GOOGLE_CLOUD_PROJECT",
    ]
    
    for var in required_env_vars:
        if not getattr(settings, var):
            raise ValueError(f"Required environment variable {var} is not set")