## Firebase Configuration

This directory contains Firebase configuration files for the SportsTalent AI platform.

### Files Required

1. **firebase-config.json** - Firebase project configuration
2. **service-account-key.json** - Firebase Admin SDK service account key
3. **firestore.rules** - Firestore security rules
4. **storage.rules** - Cloud Storage security rules

### Setup Instructions

1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication, Firestore, and Storage
3. Download the configuration files and place them in this directory
4. Update environment variables with your project details

### Security Rules

The included rules provide secure access patterns for:
- User authentication and profile data
- Assessment video storage
- Real-time pose data synchronization
- Analytics and reporting data

### Environment Variables

```bash
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
GOOGLE_CLOUD_PROJECT=your-project-id
```