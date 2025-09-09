"""
LangChain AI service for talent assessment and feedback generation.
"""

import json
from typing import Dict, Any, Optional, List
from langchain.chat_models import ChatOpenAI
from langchain.schema import SystemMessage, HumanMessage
from langchain.agents import AgentType, initialize_agent, Tool
from langchain.memory import ConversationBufferMemory
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate

from app.core.config import settings
from app.core.logging import logger
from app.models.schemas import RunningMetricsModel, TalentScoreModel, ResultQuality


class TalentAssessmentAgent:
    """LangChain agent for running talent assessment and coaching."""
    
    def __init__(self):
        """Initialize the talent assessment agent."""
        self.llm = None
        self.agent = None
        self.memory = ConversationBufferMemory(return_messages=True)
        self._initialize_llm()
        self._setup_tools()
        self._initialize_agent()
    
    def _initialize_llm(self):
        """Initialize the language model."""
        if settings.OPENAI_API_KEY:
            self.llm = ChatOpenAI(
                model_name="gpt-4",
                openai_api_key=settings.OPENAI_API_KEY,
                temperature=0.3,  # Lower temperature for more consistent analysis
                max_tokens=1000,
            )
            logger.info("OpenAI LLM initialized successfully")
        else:
            logger.warning("OpenAI API key not provided, using mock responses")
    
    def _setup_tools(self):
        """Setup tools for the agent."""
        self.tools = [
            Tool(
                name="biomechanics_analyzer",
                description="Analyze running biomechanics data and provide technical insights",
                func=self._analyze_biomechanics,
            ),
            Tool(
                name="performance_assessor",
                description="Assess running performance and potential based on metrics",
                func=self._assess_performance,
            ),
            Tool(
                name="coaching_advisor",
                description="Provide personalized coaching advice and recommendations",
                func=self._generate_coaching_advice,
            ),
        ]
    
    def _initialize_agent(self):
        """Initialize the LangChain agent."""
        if self.llm:
            self.agent = initialize_agent(
                tools=self.tools,
                llm=self.llm,
                agent_type=AgentType.CHAT_CONVERSATIONAL_REACT_DESCRIPTION,
                memory=self.memory,
                verbose=settings.DEBUG,
            )
            logger.info("LangChain agent initialized successfully")
    
    async def analyze_running_talent(
        self,
        metrics: RunningMetricsModel,
        user_profile: Dict[str, Any]
    ) -> TalentScoreModel:
        """Analyze running talent based on biomechanics and user profile."""
        logger.info("Starting talent analysis", user_id=user_profile.get("id"))
        
        if not self.agent:
            logger.warning("Agent not available, using fallback analysis")
            return self._fallback_talent_analysis(metrics, user_profile)
        
        try:
            # Prepare analysis context
            context = {
                "metrics": metrics.dict(),
                "user_profile": user_profile,
                "analysis_type": "talent_assessment"
            }
            
            # Generate analysis prompt
            prompt = self._create_talent_analysis_prompt(context)
            
            # Run agent analysis
            response = await self.agent.arun(prompt)
            
            # Parse and structure the response
            talent_score = self._parse_talent_response(response, metrics)
            
            logger.info("Talent analysis completed", overall_score=talent_score.overall_score)
            return talent_score
            
        except Exception as e:
            logger.error("Error in talent analysis", error=str(e))
            return self._fallback_talent_analysis(metrics, user_profile)
    
    async def generate_personalized_feedback(
        self,
        talent_score: TalentScoreModel,
        user_profile: Dict[str, Any]
    ) -> str:
        """Generate personalized feedback and recommendations."""
        logger.info("Generating personalized feedback", user_id=user_profile.get("id"))
        
        if not self.agent:
            return self._fallback_feedback(talent_score, user_profile)
        
        try:
            # Create feedback generation prompt
            prompt = self._create_feedback_prompt(talent_score, user_profile)
            
            # Generate personalized feedback
            feedback = await self.agent.arun(prompt)
            
            logger.info("Personalized feedback generated successfully")
            return feedback
            
        except Exception as e:
            logger.error("Error generating feedback", error=str(e))
            return self._fallback_feedback(talent_score, user_profile)
    
    def _create_talent_analysis_prompt(self, context: Dict[str, Any]) -> str:
        """Create prompt for talent analysis."""
        metrics = context["metrics"]
        profile = context["user_profile"]
        
        return f"""
        As a world-class running coach and biomechanics expert, analyze the following running data:
        
        BIOMECHANICS METRICS:
        - Cadence: {metrics['cadence']} steps/min
        - Stride Length: {metrics['stride_length']} meters
        - Ground Contact Time: {metrics['ground_contact_time']} ms
        - Vertical Oscillation: {metrics['vertical_oscillation']} cm
        - Foot Strike Pattern: {metrics['foot_strike_pattern']}
        - Arm Swing Angle: {metrics['arm_swing_angle']} degrees
        - Body Lean: {metrics['body_lean']} degrees
        - Symmetry Score: {metrics['symmetry_score']}
        
        ATHLETE PROFILE:
        - Age: {profile.get('age', 'Unknown')}
        - Height: {profile.get('height', 'Unknown')} cm
        - Weight: {profile.get('weight', 'Unknown')} kg
        - Fitness Level: {profile.get('fitness_level', 'Unknown')}
        
        Please provide:
        1. Overall talent score (0-100)
        2. Category scores for efficiency, form, potential, consistency
        3. Top 3 strengths
        4. Top 3 improvement areas
        5. Specific recommendation
        
        Focus on actionable insights and be encouraging while honest about areas for improvement.
        """
    
    def _create_feedback_prompt(
        self,
        talent_score: TalentScoreModel,
        user_profile: Dict[str, Any]
    ) -> str:
        """Create prompt for personalized feedback."""
        return f"""
        As a supportive running coach, create personalized feedback for this athlete:
        
        ASSESSMENT RESULTS:
        - Overall Score: {talent_score.overall_score}/100
        - Quality: {talent_score.quality}
        - Strengths: {', '.join(talent_score.strengths)}
        - Improvement Areas: {', '.join(talent_score.improvement_areas)}
        - Recommendation: {talent_score.recommendation}
        
        ATHLETE PROFILE:
        - Age: {user_profile.get('age', 'Unknown')}
        - Fitness Level: {user_profile.get('fitness_level', 'Unknown')}
        - Goals: {user_profile.get('goals', [])}
        
        Create encouraging, personalized feedback that:
        1. Celebrates their strengths
        2. Provides specific, actionable advice
        3. Motivates continued improvement
        4. Suggests next steps for training
        
        Keep the tone positive and professional. Limit to 200 words.
        """
    
    def _analyze_biomechanics(self, metrics_json: str) -> str:
        """Tool function for biomechanics analysis."""
        try:
            metrics = json.loads(metrics_json)
            # Analyze each metric and provide insights
            insights = []
            
            cadence = metrics.get("cadence", 0)
            if cadence < 160:
                insights.append("Low cadence - work on increasing step rate")
            elif cadence > 180:
                insights.append("High cadence - focus on maintaining efficiency")
            else:
                insights.append("Good cadence range")
            
            return "; ".join(insights)
        except:
            return "Unable to analyze biomechanics data"
    
    def _assess_performance(self, data_json: str) -> str:
        """Tool function for performance assessment."""
        try:
            data = json.loads(data_json)
            metrics = data.get("metrics", {})
            
            # Simple scoring algorithm
            scores = []
            
            # Cadence scoring
            cadence = metrics.get("cadence", 0)
            if 160 <= cadence <= 180:
                scores.append(85)
            elif 150 <= cadence <= 190:
                scores.append(75)
            else:
                scores.append(60)
            
            # Add more scoring logic here
            avg_score = sum(scores) / len(scores) if scores else 50
            
            return f"Performance assessment: {avg_score:.1f}/100"
        except:
            return "Unable to assess performance"
    
    def _generate_coaching_advice(self, context_json: str) -> str:
        """Tool function for coaching advice."""
        try:
            context = json.loads(context_json)
            advice = []
            
            # Generate basic coaching advice based on common patterns
            advice.append("Focus on consistent training")
            advice.append("Work on form drills twice weekly")
            advice.append("Include strength training for runners")
            
            return "; ".join(advice)
        except:
            return "Focus on consistent training and proper form"
    
    def _parse_talent_response(
        self,
        response: str,
        metrics: RunningMetricsModel
    ) -> TalentScoreModel:
        """Parse agent response into structured talent score."""
        # This is a simplified parser - in production, you'd use more sophisticated parsing
        try:
            # Extract scores and insights from the response
            # For now, use a basic scoring algorithm based on metrics
            overall_score = self._calculate_overall_score(metrics)
            
            return TalentScoreModel(
                overall_score=overall_score,
                category_scores={
                    "efficiency": min(100, max(0, overall_score + 5)),
                    "form": min(100, max(0, overall_score - 5)),
                    "potential": min(100, max(0, overall_score + 10)),
                    "consistency": min(100, max(0, overall_score - 3)),
                },
                quality=self._determine_quality(overall_score),
                strengths=[
                    "Good running cadence",
                    "Efficient stride mechanics",
                    "Balanced form"
                ],
                improvement_areas=[
                    "Work on symmetry",
                    "Reduce vertical oscillation",
                    "Optimize foot strike"
                ],
                recommendation="Focus on cadence drills and strength training to improve overall efficiency."
            )
        except Exception as e:
            logger.error("Error parsing talent response", error=str(e))
            return self._fallback_talent_analysis(metrics, {})
    
    def _calculate_overall_score(self, metrics: RunningMetricsModel) -> float:
        """Calculate overall score from metrics."""
        scores = []
        
        # Cadence scoring (optimal range: 160-180)
        cadence_score = 100 - abs(metrics.cadence - 170) * 2
        scores.append(max(0, min(100, cadence_score)))
        
        # Symmetry scoring (higher is better)
        symmetry_score = metrics.symmetry_score * 100
        scores.append(max(0, min(100, symmetry_score)))
        
        # Add more sophisticated scoring here
        
        return sum(scores) / len(scores)
    
    def _determine_quality(self, score: float) -> ResultQuality:
        """Determine result quality from score."""
        if score >= 85:
            return ResultQuality.EXCELLENT
        elif score >= 75:
            return ResultQuality.GOOD
        elif score >= 60:
            return ResultQuality.FAIR
        else:
            return ResultQuality.POOR
    
    def _fallback_talent_analysis(
        self,
        metrics: RunningMetricsModel,
        user_profile: Dict[str, Any]
    ) -> TalentScoreModel:
        """Fallback talent analysis when LLM is not available."""
        overall_score = self._calculate_overall_score(metrics)
        
        return TalentScoreModel(
            overall_score=overall_score,
            category_scores={
                "efficiency": overall_score * 1.05,
                "form": overall_score * 0.95,
                "potential": overall_score * 1.1,
                "consistency": overall_score * 0.9,
            },
            quality=self._determine_quality(overall_score),
            strengths=[
                "Consistent running cadence",
                "Good body positioning",
                "Balanced stride mechanics"
            ],
            improvement_areas=[
                "Improve left-right symmetry",
                "Work on foot strike efficiency",
                "Reduce vertical oscillation"
            ],
            recommendation="Focus on form drills and strength training to enhance your running efficiency and reduce injury risk."
        )
    
    def _fallback_feedback(
        self,
        talent_score: TalentScoreModel,
        user_profile: Dict[str, Any]
    ) -> str:
        """Fallback feedback generation."""
        return f"""
        Great job on completing your running assessment! Your overall score of {talent_score.overall_score:.1f}/100 shows {talent_score.quality} potential.

        Your key strengths include {', '.join(talent_score.strengths[:2])}. Keep building on these fundamentals.

        To improve further, focus on {', '.join(talent_score.improvement_areas[:2])}. 

        {talent_score.recommendation}

        Remember, consistency is key to improvement. Keep up the excellent work!
        """.strip()


# Global instance
talent_agent = TalentAssessmentAgent()