"""
Training script for talent scoring model.
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.preprocessing import StandardScaler
import joblib
import json
import os
from datetime import datetime

class TalentScoringTrainer:
    """Trainer for talent scoring models."""
    
    def __init__(self, model_name="talent_scoring_model"):
        self.model_name = model_name
        self.model = None
        self.scaler = None
        self.feature_names = None
    
    def load_dataset(self, dataset_path):
        """Load assessment dataset for training."""
        print(f"Loading dataset from {dataset_path}")
        
        try:
            # Load CSV dataset
            df = pd.read_csv(dataset_path)
            print(f"Loaded {len(df)} training samples")
            return df
            
        except FileNotFoundError:
            print(f"Dataset not found: {dataset_path}")
            print("Generating mock data for demonstration")
            
            # Generate mock training data
            num_samples = 1000
            
            # Mock running metrics
            data = {
                'cadence': np.random.normal(170, 15, num_samples),
                'stride_length': np.random.normal(1.3, 0.2, num_samples),
                'ground_contact_time': np.random.normal(230, 30, num_samples),
                'vertical_oscillation': np.random.normal(8, 2, num_samples),
                'foot_strike_pattern': np.random.uniform(0, 1, num_samples),
                'arm_swing_angle': np.random.normal(20, 5, num_samples),
                'body_lean': np.random.normal(5, 2, num_samples),
                'symmetry_score': np.random.uniform(0.6, 1.0, num_samples),
                'age': np.random.randint(15, 60, num_samples),
                'height': np.random.normal(170, 15, num_samples),
                'weight': np.random.normal(70, 15, num_samples),
                'fitness_level': np.random.randint(1, 5, num_samples),  # 1-4 for beginner to elite
            }
            
            # Generate target talent score based on metrics (mock formula)
            talent_score = (
                (data['cadence'] - 120) / 80 * 25 +  # Cadence contribution
                (1 / data['ground_contact_time'] * 100000) * 15 +  # GCT contribution
                data['symmetry_score'] * 20 +  # Symmetry contribution
                (10 - data['vertical_oscillation']) * 2 +  # Vertical oscillation
                np.random.normal(0, 5, num_samples)  # Random noise
            )
            
            # Normalize to 0-100 scale
            talent_score = np.clip(talent_score, 0, 100)
            data['talent_score'] = talent_score
            
            df = pd.DataFrame(data)
            return df
    
    def prepare_features(self, df):
        """Prepare features for training."""
        # Define feature columns
        feature_columns = [
            'cadence', 'stride_length', 'ground_contact_time',
            'vertical_oscillation', 'foot_strike_pattern',
            'arm_swing_angle', 'body_lean', 'symmetry_score',
            'age', 'height', 'weight', 'fitness_level'
        ]
        
        # Extract features and target
        X = df[feature_columns].values
        y = df['talent_score'].values
        
        self.feature_names = feature_columns
        
        return X, y
    
    def build_model(self):
        """Build Random Forest model for talent scoring."""
        model = RandomForestRegressor(
            n_estimators=100,
            max_depth=10,
            min_samples_split=5,
            min_samples_leaf=2,
            random_state=42,
            n_jobs=-1
        )
        
        self.model = model
        return model
    
    def train(self, X, y):
        """Train the talent scoring model."""
        if self.model is None:
            self.build_model()
        
        print(f"Training model with {X.shape[0]} samples...")
        
        # Scale features
        self.scaler = StandardScaler()
        X_scaled = self.scaler.fit_transform(X)
        
        # Train the model
        self.model.fit(X_scaled, y)
        
        # Cross-validation
        cv_scores = cross_val_score(self.model, X_scaled, y, cv=5, scoring='neg_mean_absolute_error')
        print(f"Cross-validation MAE: {-cv_scores.mean():.2f} (+/- {cv_scores.std() * 2:.2f})")
        
        return self.model
    
    def evaluate(self, X_test, y_test):
        """Evaluate model performance."""
        if self.model is None or self.scaler is None:
            print("Model not trained yet!")
            return None
        
        # Scale test features
        X_test_scaled = self.scaler.transform(X_test)
        
        # Make predictions
        y_pred = self.model.predict(X_test_scaled)
        
        # Calculate metrics
        mae = mean_absolute_error(y_test, y_pred)
        r2 = r2_score(y_test, y_pred)
        
        print(f"Test MAE: {mae:.2f}")
        print(f"Test R²: {r2:.3f}")
        
        # Feature importance
        if hasattr(self.model, 'feature_importances_'):
            importance_df = pd.DataFrame({
                'feature': self.feature_names,
                'importance': self.model.feature_importances_
            }).sort_values('importance', ascending=False)
            
            print("\nFeature Importance:")
            for _, row in importance_df.head(5).iterrows():
                print(f"  {row['feature']}: {row['importance']:.3f}")
        
        return {"mae": mae, "r2": r2, "feature_importance": importance_df}
    
    def save_model(self, save_path):
        """Save trained model."""
        if self.model is None or self.scaler is None:
            print("No model to save!")
            return
        
        # Save model and scaler
        model_data = {
            'model': self.model,
            'scaler': self.scaler,
            'feature_names': self.feature_names,
            'model_name': self.model_name,
            'timestamp': datetime.now().isoformat()
        }
        
        joblib.dump(model_data, save_path)
        print(f"Model saved to {save_path}")
    
    def save_training_metrics(self, metrics_path, evaluation_results):
        """Save training metrics."""
        metrics = {
            "model_name": self.model_name,
            "timestamp": datetime.now().isoformat(),
            "test_mae": float(evaluation_results['mae']),
            "test_r2": float(evaluation_results['r2']),
            "feature_importance": evaluation_results['feature_importance'].to_dict('records'),
            "model_params": self.model.get_params() if self.model else None
        }
        
        with open(metrics_path, 'w') as f:
            json.dump(metrics, f, indent=2)
        
        print(f"Training metrics saved to {metrics_path}")
    
    def predict_talent_score(self, metrics_dict):
        """Predict talent score from running metrics."""
        if self.model is None or self.scaler is None:
            print("Model not trained yet!")
            return None
        
        # Convert metrics to feature vector
        features = np.array([[
            metrics_dict.get('cadence', 170),
            metrics_dict.get('stride_length', 1.3),
            metrics_dict.get('ground_contact_time', 230),
            metrics_dict.get('vertical_oscillation', 8),
            metrics_dict.get('foot_strike_pattern', 0.5),
            metrics_dict.get('arm_swing_angle', 20),
            metrics_dict.get('body_lean', 5),
            metrics_dict.get('symmetry_score', 0.8),
            metrics_dict.get('age', 25),
            metrics_dict.get('height', 170),
            metrics_dict.get('weight', 70),
            metrics_dict.get('fitness_level', 2)
        ]])
        
        # Scale features
        features_scaled = self.scaler.transform(features)
        
        # Make prediction
        score = self.model.predict(features_scaled)[0]
        
        return max(0, min(100, score))  # Ensure score is between 0-100


def main():
    """Main training function."""
    print("SportsTalent AI - Talent Scoring Model Training")
    print("=" * 50)
    
    # Create directories
    os.makedirs("models", exist_ok=True)
    os.makedirs("metrics", exist_ok=True)
    
    # Initialize trainer
    trainer = TalentScoringTrainer("talent_scoring_v1")
    
    # Load dataset
    df = trainer.load_dataset("data/assessment_dataset.csv")
    
    # Prepare features
    X, y = trainer.prepare_features(df)
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Train model
    model = trainer.train(X_train, y_train)
    
    # Evaluate model
    results = trainer.evaluate(X_test, y_test)
    
    # Save model and metrics
    trainer.save_model("models/talent_scoring_model.pkl")
    trainer.save_training_metrics("metrics/talent_scoring_training.json", results)
    
    print("\nTraining completed successfully! 🎉")
    print(f"Final test MAE: {results['mae']:.2f}")
    print(f"Final test R²: {results['r2']:.3f}")
    
    # Test prediction
    test_metrics = {
        'cadence': 165,
        'stride_length': 1.35,
        'ground_contact_time': 225,
        'vertical_oscillation': 8.2,
        'foot_strike_pattern': 0.7,
        'arm_swing_angle': 18.5,
        'body_lean': 4.2,
        'symmetry_score': 0.85,
        'age': 25,
        'height': 175,
        'weight': 70,
        'fitness_level': 2
    }
    
    predicted_score = trainer.predict_talent_score(test_metrics)
    print(f"\nTest prediction: {predicted_score:.1f}/100")


if __name__ == "__main__":
    main()