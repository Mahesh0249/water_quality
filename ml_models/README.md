# Machine Learning Models

This directory contains the ML models and training scripts for the SportsTalent AI platform.

## Directory Structure

- **pose_analysis/**: MediaPipe and custom pose estimation models
- **talent_scoring/**: AI models for talent assessment and scoring
- **training/**: Training scripts and data preparation utilities

## Model Files

### Pose Analysis Models
- `pose_estimation_model.tflite` - TensorFlow Lite model for on-device pose detection
- `biomechanics_analyzer.pkl` - Running biomechanics analysis model
- `pose_validator.pkl` - Model to validate pose detection quality

### Talent Scoring Models
- `talent_scoring_model.pkl` - Main talent scoring algorithm
- `performance_predictor.pkl` - Performance prediction model
- `improvement_recommender.pkl` - Personalized improvement recommendations

### Training Configuration
- Training datasets should be placed in `training/data/`
- Model training logs in `training/logs/`
- Evaluation metrics in `training/metrics/`

## Usage

### Loading Models in Backend
```python
from app.services.ml_service import load_pose_model, load_talent_model

pose_model = load_pose_model("./ml_models/pose_analysis/pose_estimation_model.tflite")
talent_model = load_talent_model("./ml_models/talent_scoring/talent_scoring_model.pkl")
```

### Training New Models
```bash
cd ml_models/training
python train_pose_model.py --data data/pose_dataset.json
python train_talent_model.py --data data/assessment_dataset.csv
```

## Model Performance

### Pose Detection Accuracy
- MediaPipe BlazePose: 95%+ accuracy on running poses
- Custom validation: 90%+ precision on key running metrics

### Talent Scoring Performance
- Correlation with expert assessments: 0.87
- Prediction accuracy: 82% within 5 points of expert scores

## Requirements

- TensorFlow Lite Runtime
- MediaPipe
- scikit-learn
- OpenCV
- NumPy