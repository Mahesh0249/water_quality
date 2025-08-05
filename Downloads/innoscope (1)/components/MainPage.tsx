import React, { useState, useEffect, useCallback } from 'react';
import Sidebar from './Sidebar';
import MainContent from './MainContent';
import SettingsModal from './SettingsModal';
import { getAnalysis, continueChat } from '../services/geminiService';
import type { ResearchHistoryItem, ResearchAnalysis, ChatMessage, User } from '../types';
import type { Theme } from '../App';

interface MainPageProps {
  onLogout: () => void;
  theme: Theme;
  toggleTheme: () => void;
  currentUser: User | null;
}

const MainPage: React.FC<MainPageProps> = ({ onLogout, theme, toggleTheme, currentUser }) => {
  const [history, setHistory] = useState<ResearchHistoryItem[]>([]);
  const [currentAnalysis, setCurrentAnalysis] = useState<ResearchAnalysis | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [isChatLoading, setIsChatLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedHistoryId, setSelectedHistoryId] = useState<string | null>(null);
  const [promptForSelected, setPromptForSelected] = useState<string>("");
  const [isSidebarCollapsed, setSidebarCollapsed] = useState<boolean>(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState<boolean>(false);


  useEffect(() => {
    if (!currentUser?.email) return;
    try {
      const historyKey = `innoscope_history_${currentUser.email}`;
      const storedHistory = localStorage.getItem(historyKey);
      if (storedHistory) {
        // Ensure all items have a chatHistory property
        const parsedHistory = JSON.parse(storedHistory).map((item: any) => ({
          ...item,
          chatHistory: item.chatHistory || []
        }));
        setHistory(parsedHistory);
      } else {
        setHistory([]); // Clear history for the new user or if none exists
      }
    } catch (e) {
      console.error("Failed to parse history from localStorage", e);
      setHistory([]);
    }
  }, [currentUser]);

  useEffect(() => {
    if (!currentUser?.email) return;
    try {
      const historyKey = `innoscope_history_${currentUser.email}`;
      localStorage.setItem(historyKey, JSON.stringify(history));
    } catch(e) {
      console.error("Failed to save history to localStorage", e);
    }
  }, [history, currentUser]);

  const handleNewAnalysis = () => {
    setCurrentAnalysis(null);
    setSelectedHistoryId(null);
    setPromptForSelected("");
    setError(null);
  };

  const handleSelectHistory = (itemId: string) => {
    const selectedItem = history.find(item => item.id === itemId);
    if (selectedItem) {
      setCurrentAnalysis(selectedItem.analysis);
      setSelectedHistoryId(selectedItem.id);
      setPromptForSelected(selectedItem.prompt);
      setError(null);
    }
  };

  const handleDeleteHistory = (itemId: string) => {
    setHistory(prev => prev.filter(item => item.id !== itemId));
    if (selectedHistoryId === itemId) {
      handleNewAnalysis();
    }
  };
  
  const handleClearHistory = () => {
    setHistory([]);
    handleNewAnalysis();
    setIsSettingsOpen(false);
  };


  const handleAnalyze = useCallback(async (prompt: string, tags: string[]) => {
    const trimmedPrompt = prompt.trim();
    const wordCount = trimmedPrompt.split(/\s+/).filter(Boolean).length;

    if (trimmedPrompt === '' && tags.length === 0) {
      setError("Please enter a research idea or select at least one field to start.");
      return;
    }

    if (trimmedPrompt !== '' && tags.length === 0 && wordCount < 3) {
      setError("Your idea is a bit short. Please provide at least 3 words for a meaningful analysis, or select related fields.");
      return;
    }
    
    setIsLoading(true);
    setError(null);
    setCurrentAnalysis(null);
    
    try {
      const analysisResult = await getAnalysis(prompt, tags);
      const newPromptText = prompt.trim() || `Analysis of: ${tags.join(', ')}`;
      const newItem: ResearchHistoryItem = {
        id: new Date().toISOString(),
        prompt: newPromptText,
        timestamp: new Date().toLocaleString(),
        analysis: analysisResult,
        chatHistory: [],
      };
      
      setHistory(prev => [newItem, ...prev]);
      setCurrentAnalysis(analysisResult);
      setSelectedHistoryId(newItem.id);
      setPromptForSelected(newPromptText);

    } catch (err: any) {
      setError(err.message || 'An unknown error occurred.');
    } finally {
      setIsLoading(false);
    }
  }, []);

  const handleSendMessage = useCallback(async (message: string) => {
    if (!selectedHistoryId || !message.trim()) return;

    setIsChatLoading(true);
    setError(null);

    const currentItemIndex = history.findIndex(item => item.id === selectedHistoryId);
    if (currentItemIndex === -1) {
        setIsChatLoading(false);
        return;
    }

    const currentItem = history[currentItemIndex];
    
    const userMessage: ChatMessage = { role: 'user', content: message };
    
    const itemWithUserMessage = {
        ...currentItem,
        chatHistory: [...(currentItem.chatHistory || []), userMessage]
    };
    
    const updatedUserMessageHistory = [...history];
    updatedUserMessageHistory[currentItemIndex] = itemWithUserMessage;
    setHistory(updatedUserMessageHistory);
    
    try {
        const modelResponse = await continueChat(
            currentItem.prompt,
            currentItem.analysis,
            itemWithUserMessage.chatHistory,
            message
        );

        const modelMessage: ChatMessage = { role: 'model', content: modelResponse };
        const itemWithModelResponse = {
            ...itemWithUserMessage,
            chatHistory: [...itemWithUserMessage.chatHistory, modelMessage]
        };

        const finalHistory = [...updatedUserMessageHistory];
        finalHistory[currentItemIndex] = itemWithModelResponse;
        setHistory(finalHistory);

    } catch (err: any) {
        const errorMessage: ChatMessage = { role: 'model', content: `Error: ${err.message}` };
        const itemWithErrorMessage = {
            ...itemWithUserMessage,
            chatHistory: [...itemWithUserMessage.chatHistory, errorMessage]
        };
        const finalHistory = [...updatedUserMessageHistory];
        finalHistory[currentItemIndex] = itemWithErrorMessage;
        setHistory(finalHistory);
    } finally {
        setIsChatLoading(false);
    }
  }, [history, selectedHistoryId]);
  
  const currentItem = history.find(item => item.id === selectedHistoryId);

  return (
    <div className="flex h-screen font-sans transition-colors duration-300">
      <Sidebar 
        isCollapsed={isSidebarCollapsed}
        onToggleCollapse={() => setSidebarCollapsed(prev => !prev)}
        history={history}
        onNew={handleNewAnalysis}
        onSelect={handleSelectHistory}
        onDelete={handleDeleteHistory}
        selectedId={selectedHistoryId}
        onOpenSettings={() => setIsSettingsOpen(true)}
        theme={theme}
        toggleTheme={toggleTheme}
      />
      <MainContent 
        analysis={currentAnalysis}
        isLoading={isLoading}
        error={error}
        onAnalyze={handleAnalyze}
        prompt={promptForSelected}
        chatHistory={currentItem?.chatHistory || []}
        isChatLoading={isChatLoading}
        onSendMessage={handleSendMessage}
      />
      <SettingsModal 
        isOpen={isSettingsOpen}
        onClose={() => setIsSettingsOpen(false)}
        onLogout={onLogout}
        onClearHistory={handleClearHistory}
        theme={theme}
        toggleTheme={toggleTheme}
        currentUser={currentUser}
      />
    </div>
  );
};

export default MainPage;