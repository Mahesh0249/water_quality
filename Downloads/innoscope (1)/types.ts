
export interface ChatMessage {
  role: 'user' | 'model';
  content: string;
}

export interface RelatedDocument {
  title: string;
  url: string;
  summary: string;
}

export interface ResearchAnalysis {
  noveltyAnalysis: string;
  researchGaps: string[];
  innovativeSuggestions: string[];
  relatedDocuments: RelatedDocument[];
}

export interface ResearchHistoryItem {
  id: string;
  prompt: string;
  timestamp: string;
  analysis: ResearchAnalysis;
  chatHistory: ChatMessage[];
}

export interface User {
  email: string;
}
