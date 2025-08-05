
import React from 'react';
import { UserIcon, Trash2Icon, LogoutIcon, MoonIcon, SunIcon, XIcon } from './Icons';
import type { Theme } from '../App';
import type { User } from '../types';


interface SettingsModalProps {
  isOpen: boolean;
  onClose: () => void;
  onLogout: () => void;
  onClearHistory: () => void;
  theme: Theme;
  toggleTheme: () => void;
  currentUser: User | null;
}

const SettingsModal: React.FC<SettingsModalProps> = ({ isOpen, onClose, onLogout, onClearHistory, theme, toggleTheme, currentUser }) => {
  if (!isOpen) return null;

  return (
    <div 
      className="fixed inset-0 bg-slate-900 bg-opacity-75 flex items-center justify-center z-50 animate-fade-in-fast"
      onClick={onClose}
    >
      <div 
        className="relative bg-white dark:bg-slate-800 rounded-xl shadow-2xl w-full max-w-md m-4 p-8 flex flex-col gap-6"
        onClick={(e) => e.stopPropagation()}
      >
        <button onClick={onClose} className="absolute top-4 right-4 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
            <XIcon className="w-6 h-6"/>
        </button>

        <div>
          <h2 className="text-2xl font-bold text-slate-800 dark:text-slate-100">Settings</h2>
          <p className="text-slate-500 dark:text-slate-400 mt-1">Manage your account and data.</p>
        </div>

        <div className="bg-slate-100 dark:bg-slate-700/50 p-4 rounded-lg flex items-center gap-4">
          <UserIcon className="w-8 h-8 text-slate-500 dark:text-slate-400 flex-shrink-0" />
          <div>
            <p className="text-sm text-slate-500 dark:text-slate-400">Logged in as</p>
            <p className="font-medium text-slate-700 dark:text-slate-200">{currentUser?.email || 'Guest'}</p>
          </div>
        </div>
        
        <div className="border-t dark:border-slate-700 pt-6 space-y-3">
          <button
              onClick={toggleTheme}
              className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-slate-200 dark:bg-slate-700 text-slate-800 dark:text-slate-200 font-bold rounded-lg hover:bg-slate-300 dark:hover:bg-slate-600 transition-colors"
            >
              {theme === 'light' ? <MoonIcon className="w-5 h-5" /> : <SunIcon className="w-5 h-5" />}
              Switch to {theme === 'light' ? 'Dark' : 'Light'} Mode
            </button>
           <button
            onClick={() => {
              if (window.confirm("Are you sure you want to delete all your research history? This action cannot be undone.")) {
                onClearHistory();
              }
            }}
            className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-red-100 dark:bg-red-900/40 text-red-700 dark:text-red-300 font-bold rounded-lg hover:bg-red-200 dark:hover:bg-red-900/60 transition-colors"
          >
            <Trash2Icon className="w-5 h-5" />
            Clear All History
          </button>
           <button
            onClick={onLogout}
            className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-slate-200 dark:bg-slate-700 text-slate-800 dark:text-slate-200 font-bold rounded-lg hover:bg-slate-300 dark:hover:bg-slate-600 transition-colors"
          >
            <LogoutIcon className="w-5 h-5" />
            Log Out
          </button>
        </div>
      </div>
    </div>
  );
};

export default SettingsModal;
