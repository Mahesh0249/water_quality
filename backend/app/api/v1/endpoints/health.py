"""
Health check endpoints for monitoring and status verification.
"""

from fastapi import APIRouter
from app.core.logging import logger

router = APIRouter()


@router.get("/")
async def health_check():
    """Basic health check endpoint."""
    logger.info("Health check requested")
    return {
        "status": "healthy",
        "service": "sportsTalent-ai-backend",
        "version": "1.0.0"
    }


@router.get("/detailed")
async def detailed_health_check():
    """Detailed health check with service dependencies."""
    logger.info("Detailed health check requested")
    
    # Check various service dependencies
    checks = {
        "api": "healthy",
        "firebase": "checking...",  # TODO: Implement Firebase connection check
        "openai": "checking...",    # TODO: Implement OpenAI API check
        "storage": "checking...",   # TODO: Implement storage check
    }
    
    return {
        "status": "healthy",
        "service": "sportsTalent-ai-backend",
        "version": "1.0.0",
        "checks": checks
    }