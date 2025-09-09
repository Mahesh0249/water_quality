# SportsTalent AI Deployment Guide

This guide covers deploying the SportsTalent AI platform to production.

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   FastAPI API    │    │   Firebase      │
│  (Mobile/Web)   │◄──►│    Backend       │◄──►│  Auth/Database  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   App Stores    │    │   Google Cloud   │    │   ML Models     │
│  iOS/Android    │    │    Platform      │    │  TensorFlow     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Prerequisites

- Google Cloud Platform account
- Firebase project
- Docker installed
- Flutter SDK (for mobile app)
- Python 3.9+ (for backend)

## Backend Deployment (Google Cloud Run)

### 1. Prepare Backend for Production

Create `backend/Dockerfile`:
```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Expose port
EXPOSE 8000

# Run application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 2. Build and Deploy

```bash
# Set up Google Cloud CLI
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# Build and deploy to Cloud Run
cd backend
gcloud run deploy sportstalent-api \
    --source . \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --memory 2Gi \
    --cpu 2 \
    --max-instances 10 \
    --set-env-vars="DEBUG=False,FIREBASE_PROJECT_ID=YOUR_PROJECT_ID"
```

### 3. Environment Variables

Set the following environment variables in Cloud Run:

```bash
DEBUG=False
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CREDENTIALS_PATH=/secrets/firebase-key.json
OPENAI_API_KEY=your-openai-key
GOOGLE_AI_API_KEY=your-google-ai-key
SECRET_KEY=your-secret-key
ALLOWED_HOSTS=["https://your-domain.com"]
```

### 4. Set up Secrets

```bash
# Create secret for Firebase service account
gcloud secrets create firebase-service-account \
    --data-file=path/to/service-account.json

# Mount secret in Cloud Run
gcloud run services update sportstalent-api \
    --update-secrets=/secrets/firebase-key.json=firebase-service-account:latest
```

## Mobile App Deployment

### iOS Deployment

1. **Configure iOS project**:
```bash
cd flutter_app
flutter pub get
cd ios
pod install
```

2. **Update iOS configuration** (`ios/Runner/Info.plist`):
```xml
<!-- Add camera and microphone permissions -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to record running videos for analysis</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for video recording</string>
```

3. **Build and deploy to App Store**:
```bash
flutter build ios --release
# Open ios/Runner.xcworkspace in Xcode
# Archive and upload to App Store Connect
```

### Android Deployment

1. **Configure Android build** (`android/app/build.gradle`):
```gradle
android {
    ...
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

2. **Add permissions** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

3. **Build and deploy**:
```bash
flutter build appbundle --release
# Upload to Google Play Console
```

## Firebase Configuration

### 1. Enable Required Services

```bash
# Enable Authentication
gcloud services enable identitytoolkit.googleapis.com

# Enable Firestore
gcloud services enable firestore.googleapis.com

# Enable Cloud Storage
gcloud services enable storage-component.googleapis.com
```

### 2. Configure Security Rules

Deploy Firestore and Storage rules:
```bash
cd cloud/firebase
firebase deploy --only firestore:rules,storage
```

### 3. Set up Authentication

Enable authentication providers in Firebase Console:
- Email/Password
- Google Sign-In (optional)
- Anonymous authentication for guest users

## Cloud Infrastructure Setup

### 1. Set up BigQuery for Analytics

```bash
# Create BigQuery dataset
bq mk --dataset \
    --description "SportsTalent AI Analytics Dataset" \
    YOUR_PROJECT_ID:sportstalent_analytics

# Create tables for user analytics
bq mk --table \
    YOUR_PROJECT_ID:sportstalent_analytics.user_assessments \
    user_id:STRING,assessment_id:STRING,timestamp:TIMESTAMP,score:FLOAT,metrics:JSON
```

### 2. Set up Cloud Storage Buckets

```bash
# Create bucket for video storage
gsutil mb -p YOUR_PROJECT_ID -l us-central1 gs://sportstalent-videos

# Create bucket for ML models
gsutil mb -p YOUR_PROJECT_ID -l us-central1 gs://sportstalent-models

# Set CORS for video uploads
cat > cors.json << EOF
[
  {
    "origin": ["https://your-domain.com", "http://localhost:3000"],
    "method": ["GET", "POST", "PUT"],
    "maxAgeSeconds": 3600
  }
]
EOF

gsutil cors set cors.json gs://sportstalent-videos
```

### 3. Deploy ML Models to Vertex AI

```bash
# Upload models to Cloud Storage
gsutil cp ml_models/pose_analysis/pose_estimation_model.tflite \
    gs://sportstalent-models/pose_analysis/

gsutil cp ml_models/talent_scoring/talent_scoring_model.pkl \
    gs://sportstalent-models/talent_scoring/

# Create Vertex AI model endpoint (for advanced features)
gcloud ai models upload \
    --region=us-central1 \
    --display-name=pose-analysis-model \
    --artifact-uri=gs://sportstalent-models/pose_analysis/
```

## Monitoring and Logging

### 1. Set up Cloud Monitoring

```bash
# Enable monitoring
gcloud services enable monitoring.googleapis.com

# Create uptime check
gcloud alpha monitoring uptime-checks create \
    --display-name="SportsTalent API Health Check" \
    --resource-type="URL" \
    --resource-label=host="your-api-domain.com" \
    --resource-label=path="/health"
```

### 2. Configure Logging

Add structured logging to your application and configure log-based metrics in Cloud Console.

### 3. Set up Alerting

Create alerts for:
- API response time > 5 seconds
- Error rate > 5%
- Video upload failures
- Model inference errors

## Performance Optimization

### 1. CDN Configuration

Set up Cloud CDN for static assets:
```bash
gcloud compute backend-services create sportstalent-backend \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=sportstalent-health-check \
    --global

gcloud compute url-maps create sportstalent-url-map \
    --default-service=sportstalent-backend
```

### 2. Database Optimization

- Enable Firestore cache for frequently accessed data
- Use composite indexes for complex queries
- Implement pagination for large result sets

### 3. Mobile App Optimization

- Enable R8 obfuscation for Android builds
- Optimize assets and images
- Implement proper caching strategies

## Security Configuration

### 1. API Security

- Enable CORS with specific origins
- Implement rate limiting
- Use HTTPS only
- Validate all inputs

### 2. Mobile App Security

- Enable certificate pinning
- Obfuscate sensitive code
- Implement root/jailbreak detection
- Use secure storage for tokens

### 3. Firebase Security

- Review and test security rules
- Enable App Check for mobile apps
- Monitor authentication anomalies

## Backup and Disaster Recovery

### 1. Database Backups

```bash
# Enable automated Firestore backups
gcloud firestore databases backups schedules create \
    --location=us-central1 \
    --backup-schedule=daily
```

### 2. Model Versioning

- Version ML models in Cloud Storage
- Maintain rollback capabilities
- Test model updates in staging

## Staging Environment

Create a staging environment that mirrors production:

```bash
# Deploy to staging
gcloud run deploy sportstalent-api-staging \
    --source . \
    --platform managed \
    --region us-central1 \
    --set-env-vars="DEBUG=True,ENVIRONMENT=staging"
```

## Deployment Checklist

- [ ] Backend deployed to Cloud Run
- [ ] Mobile apps published to app stores
- [ ] Firebase services configured
- [ ] Security rules deployed
- [ ] ML models uploaded
- [ ] Monitoring and alerting configured
- [ ] CDN and performance optimization
- [ ] Backup systems enabled
- [ ] Staging environment tested
- [ ] Load testing completed
- [ ] Security audit passed

## Post-Deployment

1. Monitor application metrics
2. Set up automated testing
3. Plan for capacity scaling
4. Regular security updates
5. User feedback collection
6. Performance optimization
7. Feature flag management

For detailed troubleshooting, see the [Troubleshooting Guide](troubleshooting.md).