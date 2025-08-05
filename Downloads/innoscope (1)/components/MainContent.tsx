import React, { useState, useEffect, useRef } from 'react';
import type { ResearchAnalysis, RelatedDocument, ChatMessage } from '../types';
import { SparklesIcon, SearchIcon, LightbulbIcon, LoaderIcon, AlertTriangleIcon, BookOpenIcon, LogoIcon, FileTextIcon, SendIcon } from './Icons';

interface MainContentProps {
  analysis: ResearchAnalysis | null;
  isLoading: boolean;
  error: string | null;
  onAnalyze: (prompt: string, tags: string[]) => void;
  prompt: string;
  chatHistory: ChatMessage[];
  isChatLoading: boolean;
  onSendMessage: (message: string) => void;
}

const relatedFields = [
  "Machine Learning", "Biotechnology", "Quantum Computing", 
  "Renewable Energy", "Robotics", "Healthcare IT", "Cybersecurity",
  "AR/VR", "Data Science", "Space Tech", "FinTech", "EdTech"
];

const RelatedDocuments: React.FC<{ documents: RelatedDocument[] }> = ({ documents }) => (
    <div>
      <h2 className="flex items-center text-2xl font-bold text-slate-800 dark:text-slate-100 mb-4">
        <BookOpenIcon className="w-7 h-7 mr-3 text-blue-600" />
        Related Documents
      </h2>
      <ul className="space-y-4">
        {documents.map((doc, index) => (
          <li key={index} className="border-l-4 border-blue-200 dark:border-blue-800 pl-4 py-1">
            <a 
              href={doc.url} 
              target="_blank" 
              rel="noopener noreferrer" 
              className="text-blue-600 dark:text-blue-400 hover:underline font-semibold"
            >
              {doc.title}
            </a>
            <p className="text-slate-600 dark:text-slate-400 leading-relaxed mt-1 text-sm">{doc.summary}</p>
          </li>
        ))}
      </ul>
    </div>
);

const AnalysisResult: React.FC<{ analysis: ResearchAnalysis }> = ({ analysis }) => (
  <div className="space-y-8 animate-fade-in">
    <div>
      <h2 className="flex items-center text-2xl font-bold text-slate-800 dark:text-slate-100 mb-4">
        <SparklesIcon className="w-7 h-7 mr-3 text-blue-600" />
        Analysis
      </h2>
      <p className="text-slate-600 dark:text-slate-300 leading-relaxed bg-white dark:bg-slate-800 p-4 rounded-lg shadow-sm">{analysis.noveltyAnalysis}</p>
    </div>
    <div>
      <h2 className="flex items-center text-2xl font-bold text-slate-800 dark:text-slate-100 mb-4">
        <SearchIcon className="w-7 h-7 mr-3 text-blue-600" />
        Identified Research Gaps
      </h2>
      <ul className="space-y-3">
        {analysis.researchGaps.map((gap, index) => (
          <li key={index} className="flex items-start">
            <div className="flex-shrink-0 w-6 h-6 bg-blue-100 dark:bg-blue-800 text-blue-700 dark:text-blue-200 rounded-full flex items-center justify-center font-bold text-sm mr-4 mt-1">{index + 1}</div>
            <p className="text-slate-600 dark:text-slate-400 leading-relaxed">{gap}</p>
          </li>
        ))}
      </ul>
    </div>
    <div>
      <h2 className="flex items-center text-2xl font-bold text-slate-800 dark:text-slate-100 mb-4">
        <LightbulbIcon className="w-7 h-7 mr-3 text-blue-600" />
        Innovative Suggestions
      </h2>
      <ul className="space-y-3">
        {analysis.innovativeSuggestions.map((suggestion, index) => (
          <li key={index} className="flex items-start">
            <div className="flex-shrink-0 w-6 h-6 bg-green-100 dark:bg-green-900 text-green-700 dark:text-green-200 rounded-full flex items-center justify-center font-bold text-sm mr-4 mt-1">💡</div>
            <p className="text-slate-600 dark:text-slate-400 leading-relaxed">{suggestion}</p>
          </li>
        ))}
      </ul>
    </div>
    {analysis.relatedDocuments && analysis.relatedDocuments.length > 0 && (
      <RelatedDocuments documents={analysis.relatedDocuments} />
    )}
  </div>
);

const ChatMessageBubble: React.FC<{ message: ChatMessage }> = ({ message }) => {
    const isUser = message.role === 'user';
    return (
        <div className={`flex items-start gap-3 ${isUser ? 'justify-end' : 'justify-start'} animate-fade-in-fast`}>
            {!isUser && (
                <div className="w-8 h-8 rounded-full bg-slate-700 flex items-center justify-center flex-shrink-0">
                    <LogoIcon className="w-5 h-5 text-blue-400" />
                </div>
            )}
            <div className={`max-w-xl p-3 rounded-xl shadow-sm ${isUser ? 'bg-blue-600 text-white rounded-br-none' : 'bg-white dark:bg-slate-700 text-slate-800 dark:text-slate-200 rounded-bl-none'}`}>
                <p className="text-sm leading-relaxed whitespace-pre-wrap">{message.content}</p>
            </div>
        </div>
    );
};

const ChatInput: React.FC<{ onSendMessage: (message: string) => void, isLoading: boolean }> = ({ onSendMessage, isLoading }) => {
    const [input, setInput] = useState('');
    const inputRef = useRef<HTMLTextAreaElement>(null);

    const handleSend = () => {
        if (input.trim() && !isLoading) {
            onSendMessage(input.trim());
            setInput('');
        }
    };

    const handleKeyPress = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            handleSend();
        }
    };
    
    useEffect(() => {
      if (inputRef.current) {
        inputRef.current.style.height = 'auto';
        inputRef.current.style.height = `${inputRef.current.scrollHeight}px`;
      }
    }, [input]);

    return (
        <div className="relative">
            <textarea
                ref={inputRef}
                value={input}
                onChange={e => setInput(e.target.value)}
                onKeyDown={handleKeyPress}
                placeholder="Ask a follow-up question..."
                className="w-full max-h-40 p-3 pr-14 text-sm bg-white dark:bg-slate-800 border-2 border-slate-200 dark:border-slate-700 text-slate-900 dark:text-slate-200 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition resize-none"
                rows={1}
                disabled={isLoading}
            />
            <button
                onClick={handleSend}
                disabled={isLoading || !input.trim()}
                className="absolute right-3 bottom-2.5 p-2 rounded-full bg-blue-600 text-white hover:bg-blue-700 disabled:bg-slate-400 dark:disabled:bg-slate-600 transition-all"
                aria-label="Send message"
            >
                {isLoading ? <LoaderIcon className="w-5 h-5" /> : <SendIcon className="w-5 h-5"/>}
            </button>
        </div>
    );
};

const ChatView: React.FC<{ chatHistory: ChatMessage[], isLoading: boolean, onSendMessage: (message: string) => void }> = ({ chatHistory, isLoading, onSendMessage }) => {
    const chatContainerRef = useRef<HTMLDivElement>(null);
    useEffect(() => {
        if (chatContainerRef.current) {
            chatContainerRef.current.scrollTop = chatContainerRef.current.scrollHeight;
        }
    }, [chatHistory]);

    return (
        <div>
            <h2 className="flex items-center text-2xl font-bold text-slate-800 dark:text-slate-100 mb-6">
                <FileTextIcon className="w-7 h-7 mr-3 text-blue-600" />
                Follow-up Conversation
            </h2>
            <div ref={chatContainerRef} className="space-y-4 pr-2 max-h-[50vh] overflow-y-auto mb-4">
                {chatHistory.length === 0 && !isLoading && (
                    <p className="text-slate-500 dark:text-slate-400 text-center py-4">No follow-up questions yet. Ask something below!</p>
                )}
                {chatHistory.map((msg, index) => <ChatMessageBubble key={index} message={msg} />)}
                {isLoading && chatHistory.length > 0 && chatHistory[chatHistory.length-1].role === 'user' && (
                     <div className="flex items-start gap-3 justify-start animate-fade-in-fast">
                        <div className="w-8 h-8 rounded-full bg-slate-700 flex items-center justify-center flex-shrink-0">
                            <LogoIcon className="w-5 h-5 text-blue-400" />
                        </div>
                        <div className="p-3 rounded-xl bg-white dark:bg-slate-700 text-slate-800 dark:text-slate-200 rounded-bl-none">
                            <LoaderIcon className="w-5 h-5 text-slate-500" />
                        </div>
                    </div>
                )}
            </div>
            <ChatInput onSendMessage={onSendMessage} isLoading={isLoading} />
        </div>
    );
};


const MainContent: React.FC<MainContentProps> = ({ analysis, isLoading, error, onAnalyze, prompt: initialPrompt, chatHistory, isChatLoading, onSendMessage }) => {
  const [prompt, setPrompt] = useState('');
  const [selectedTags, setSelectedTags] = useState<string[]>([]);

  useEffect(() => {
    if(initialPrompt) {
        const justThePrompt = initialPrompt.replace(/^Analysis of: /, '');
        setPrompt(justThePrompt);
    } else {
        setPrompt('');
    }
    setSelectedTags([]);
  }, [initialPrompt]);

  const handleTagClick = (tag: string) => {
    setSelectedTags(prev => 
      prev.includes(tag) ? prev.filter(t => t !== tag) : [...prev, tag]
    );
  };

  const handleSubmit = () => {
    onAnalyze(prompt, selectedTags);
  };
  
  const canAnalyze = !isLoading && (prompt.trim() !== '' || selectedTags.length > 0);

  return (
    <main className="flex-1 flex flex-col p-8 lg:p-12 overflow-y-auto bg-slate-100 dark:bg-slate-900 transition-colors duration-300">
      <div className="w-full max-w-4xl mx-auto my-auto">
        {isLoading ? (
          <div className="flex flex-col items-center justify-center text-center">
            <LoaderIcon className="w-16 h-16 text-blue-600" />
            <h2 className="text-2xl font-semibold text-slate-700 dark:text-slate-200 mt-6">Analyzing...</h2>
            <p className="text-slate-500 dark:text-slate-400 mt-2">The AI is connecting the dots. This might take a moment.</p>
          </div>
        ) : error ? (
           <div className="flex flex-col items-center justify-center text-center bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-500/30 rounded-lg p-8">
            <AlertTriangleIcon className="w-16 h-16 text-red-500" />
            <h2 className="text-2xl font-semibold text-slate-700 dark:text-slate-200 mt-6">
                {error.startsWith('Your idea is a bit short') || error.startsWith('Please enter a research idea') ? 'More Information Needed' : 'Analysis Failed'}
            </h2>
            <p className="text-slate-500 dark:text-slate-400 mt-2 max-w-md">{error}</p>
          </div>
        ) : analysis ? (
          <div>
            <h1 className="text-3xl font-extrabold text-slate-800 dark:text-slate-100 mb-2">Analysis Complete</h1>
            <p className="text-slate-500 dark:text-slate-400 mb-8 max-w-2xl border-b border-slate-200 dark:border-slate-700 pb-4">
              Analyzed: <span className="font-medium text-slate-600 dark:text-slate-300">"{initialPrompt}"</span>
            </p>
            <AnalysisResult analysis={analysis} />
            <hr className="my-10 border-slate-300 dark:border-slate-700" />
            <ChatView 
              chatHistory={chatHistory}
              isLoading={isChatLoading}
              onSendMessage={onSendMessage}
            />
          </div>
        ) : (
          <div className="text-center">
            <h1 className="text-6xl font-extrabold text-slate-800 dark:text-slate-100 tracking-tight">InnoScope</h1>
            <div className="mt-12">
              <textarea
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
                placeholder="Describe your project idea... (optional if fields are selected)"
                className="w-full h-40 p-4 text-base bg-white dark:bg-slate-800 border-2 border-slate-200 dark:border-slate-700 text-slate-900 dark:text-slate-200 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
              />
              <div className="mt-4 text-left">
                <p className="text-sm font-medium text-slate-600 dark:text-slate-400 mb-2">Or select related fields to generate ideas from:</p>
                <div className="flex flex-wrap gap-2">
                  {relatedFields.map(field => (
                    <button
                      key={field}
                      onClick={() => handleTagClick(field)}
                      className={`px-3 py-1 text-sm font-medium rounded-full border transition-colors ${
                        selectedTags.includes(field)
                          ? 'bg-blue-600 text-white border-blue-600'
                          : 'bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-300 border-slate-300 dark:border-slate-600 hover:bg-slate-100 dark:hover:bg-slate-700'
                      }`}
                    >
                      {field}
                    </button>
                  ))}
                </div>
              </div>
            </div>
            <div className="mt-8 flex justify-end">
              <button
                onClick={handleSubmit}
                disabled={!canAnalyze}
                className="px-8 py-3 bg-blue-600 text-white font-bold rounded-lg shadow-md hover:bg-blue-700 transition-all disabled:bg-slate-400 dark:disabled:bg-slate-600 disabled:cursor-not-allowed flex items-center gap-2"
              >
                <SparklesIcon className="w-5 h-5"/>
                Analyze
              </button>
            </div>
          </div>
        )}
      </div>
    </main>
  );
};

export default MainContent;