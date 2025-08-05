
import { GoogleGenAI, Type } from "@google/genai";
import type { ResearchAnalysis, RelatedDocument, ChatMessage } from '../types';

if (!process.env.API_KEY) {
  console.warn("API_KEY environment variable not set. Using a placeholder key. Please set your API key for the app to function.");
}

const ai = new GoogleGenAI({ apiKey: process.env.API_KEY || "YOUR_API_KEY_HERE" });

const relatedDocumentSchema = {
    type: Type.OBJECT,
    properties: {
        title: {
            type: Type.STRING,
            description: "The full title of the academic paper or article."
        },
        url: {
            type: Type.STRING,
            description: "A valid, direct URL to access the document."
        },
        summary: {
            type: Type.STRING,
            description: "A concise, one-sentence summary explaining the document's relevance to the topic."
        }
    },
    required: ["title", "url", "summary"]
};


const responseSchema = {
  type: Type.OBJECT,
  properties: {
    noveltyAnalysis: {
      type: Type.STRING,
      description: "A detailed analysis of the idea's novelty, or a summary of the state-of-the-art if only fields are provided. Explain why it is or isn't novel.",
    },
    researchGaps: {
      type: Type.ARRAY,
      items: { type: Type.STRING },
      description: "A list of 3 specific, actionable research gaps that this idea could potentially address, or general gaps in the specified fields.",
    },
    innovativeSuggestions: {
      type: Type.ARRAY,
      items: { type: Type.STRING },
      description: "A list of 3 creative suggestions to expand the idea, or a list of new project ideas if only fields are provided.",
    },
    relatedDocuments: {
      type: Type.ARRAY,
      items: relatedDocumentSchema,
      description: "A list of 3-5 highly relevant academic papers or technical articles to serve as a starting point for research."
    }
  },
  required: ["noveltyAnalysis", "researchGaps", "innovativeSuggestions", "relatedDocuments"],
};

export const getAnalysis = async (idea: string, fields: string[]): Promise<ResearchAnalysis> => {
  let promptContent = "As a world-class research analyst and innovation consultant, your task is to perform the following analysis based on the provided information. Provide a detailed, critical, and constructive assessment.\n\n";

  const hasIdea = idea.trim() !== '';
  const hasFields = fields.length > 0;

  if (hasIdea) {
    promptContent += `**Project Idea:** "${idea}"\n\n`;
  }
  if (hasFields) {
    promptContent += `**Related Fields:** ${fields.join(", ")}\n\n`;
  }

  const baseTasks = `
    1.  **Novelty Analysis / State-of-the-Art:** Critically assess the novelty of the idea. If only fields are provided, summarize the current state-of-the-art. Compare against existing research and commercial products.
    2.  **Identify Research Gaps:** Pinpoint exactly 3 specific, unanswered questions or underexplored areas.
    3.  **Provide Innovative Suggestions:** Offer exactly 3 creative, forward-thinking suggestions to enhance the project's impact or scope. If only fields are given, these should be new project ideas.
    4.  **Find Related Documents:** Identify 3-5 highly relevant academic papers or technical articles. For each, provide its title, a direct URL, and a one-sentence summary of its relevance.
  `;
  
  promptContent += `**Your Analysis Task:**\n${baseTasks}\n\nPlease provide your response strictly in the JSON format defined by the schema.`;

  try {
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: promptContent,
      config: {
        responseMimeType: "application/json",
        responseSchema: responseSchema,
        temperature: 0.7,
      },
    });

    const jsonText = response.text.trim();
    const parsedJson = JSON.parse(jsonText);
    
    // Deeper validation
    if (
        typeof parsedJson.noveltyAnalysis === 'string' &&
        Array.isArray(parsedJson.researchGaps) &&
        Array.isArray(parsedJson.innovativeSuggestions) &&
        Array.isArray(parsedJson.relatedDocuments) &&
        parsedJson.relatedDocuments.every((doc: any) => 
            typeof doc.title === 'string' && 
            typeof doc.url === 'string' && 
            typeof doc.summary === 'string'
        )
    ) {
        return parsedJson as ResearchAnalysis;
    } else {
        throw new Error("API response does not match the expected structure.");
    }
    
  } catch (error) {
    console.error("Error fetching or parsing analysis from Gemini API:", error);
    throw new Error("Failed to get analysis from AI. The model may have returned an invalid response. Please check the console for details.");
  }
};

export const continueChat = async (
  initialPrompt: string,
  initialAnalysis: ResearchAnalysis,
  chatHistory: ChatMessage[],
  newUserMessage: string
): Promise<string> => {
  
  const historyText = chatHistory.map(m => `${m.role === 'user' ? 'User' : 'AI'}: ${m.content}`).join('\n');
  const analysisSummary = `
- **Novelty/State-of-the-Art**: ${initialAnalysis.noveltyAnalysis.substring(0, 200)}...
- **Identified Gaps**: ${initialAnalysis.researchGaps.join(', ')}
- **Innovative Suggestions**: ${initialAnalysis.innovativeSuggestions.join(', ')}
  `.trim();

  const prompt = `
You are InnoScope, a helpful and concise AI research assistant. You have already provided a detailed analysis for a user's idea. Now, you must answer their follow-up question.
Keep your answer focused and directly related to the question. Do not repeat information from the initial analysis unless it's necessary to answer the question.

**CONTEXT FROM INITIAL ANALYSIS**
**User's Original Idea/Topic:** "${initialPrompt}"
**Summary of Your Analysis:**
${analysisSummary}

**PREVIOUS CONVERSATION**
${historyText}

**USER'S NEW QUESTION**
"${newUserMessage}"

Your response:
  `.trim();

  try {
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: prompt,
      config: {
        temperature: 0.5,
      },
    });

    return response.text.trim();
  } catch (error) {
    console.error("Error continuing chat with Gemini API:", error);
    throw new Error("Failed to get a response from the AI. Please try again.");
  }
};
