"""
Simple test script to verify the backend structure.
"""

import sys
sys.path.append('/home/runner/work/water_quality/water_quality/backend')

def test_imports():
    """Test that all modules can be imported successfully."""
    try:
        print("Testing imports...")
        
        # Test core modules
        from app.core.config import settings
        print("✓ Config imported successfully")
        
        from app.models.schemas import UserProfileModel, AssessmentModel
        print("✓ Schema models imported successfully")
        
        # Test API structure
        from app.api.v1.router import api_router
        print("✓ API router imported successfully")
        
        print("\nAll imports successful! 🎉")
        return True
        
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def test_basic_functionality():
    """Test basic functionality without external dependencies."""
    try:
        from app.core.config import settings
        print(f"Debug mode: {settings.DEBUG}")
        print(f"Host: {settings.HOST}")
        print(f"Port: {settings.PORT}")
        
        from app.models.schemas import UserProfileModel, FitnessLevel
        
        # Test model creation
        user = UserProfileModel(
            id="test_user",
            email="test@example.com",
            fitness_level=FitnessLevel.BEGINNER,
            created_at="2024-01-01T00:00:00Z"
        )
        print(f"Created user model: {user.email}")
        
        print("✓ Basic functionality test passed")
        return True
        
    except Exception as e:
        print(f"❌ Functionality test failed: {e}")
        return False

if __name__ == "__main__":
    print("=== Backend Structure Test ===\n")
    
    imports_ok = test_imports()
    if imports_ok:
        functionality_ok = test_basic_functionality()
        
        if functionality_ok:
            print("\n🎉 All tests passed! Backend structure is working.")
        else:
            print("\n⚠️ Imports work but functionality has issues.")
    else:
        print("\n❌ Basic imports failed. Check file structure.")