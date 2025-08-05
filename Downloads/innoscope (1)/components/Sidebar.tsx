import React from 'react';
import type { ResearchHistoryItem } from '../types';
import type { Theme } from '../App';
import { PlusIcon, FileTextIcon, LogoIcon, Trash2Icon, ChevronsLeftIcon, ChevronsRightIcon, SettingsIcon, MoonIcon, SunIcon } from './Icons';

interface SidebarProps {
  history: ResearchHistoryItem[];
  onNew: () => void;
  onSelect: (id: string) => void;
  onDelete: (id: string) => void;
  selectedId: string | null;
  isCollapsed: boolean;
  onToggleCollapse: () => void;
  onOpenSettings: () => void;
  theme: Theme;
  toggleTheme: () => void;
}

const Sidebar: React.FC<SidebarProps> = ({ 
  history, 
  onNew, 
  onSelect, 
  onDelete, 
  selectedId, 
  isCollapsed,
  onToggleCollapse,
  onOpenSettings,
  theme,
  toggleTheme
}) => {
  return (
    <aside className={`bg-white dark:bg-slate-800 border-r border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 flex flex-col shadow-lg transition-all duration-300 ${isCollapsed ? 'w-20' : 'w-80'} p-4`}>
      <div className={`flex items-center gap-3 mb-8 px-2 ${isCollapsed ? 'justify-center' : ''}`}>
        <LogoIcon className="w-9 h-9 text-blue-500 flex-shrink-0" />
        {!isCollapsed && <h1 className="text-2xl font-bold text-slate-800 dark:text-white whitespace-nowrap">InnoScope</h1>}
      </div>

      <button
        onClick={onNew}
        className={`flex items-center gap-3 w-full px-4 py-3 text-left font-semibold bg-blue-600 text-white rounded-lg hover:bg-blue-500 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75 ${isCollapsed ? 'justify-center text-lg' : 'text-lg'}`}
      >
        <PlusIcon className="w-6 h-6 flex-shrink-0" />
        {!isCollapsed && <span className="whitespace-nowrap">New Analysis</span>}
      </button>

      <h2 className={`mt-8 mb-3 px-2 text-sm font-semibold tracking-wider text-slate-500 dark:text-slate-400 uppercase ${isCollapsed ? 'text-center' : ''}`}>
        {isCollapsed ? '...' : 'Recent'}
      </h2>
      <div className="flex-grow overflow-y-auto pr-1 -mr-1" style={{ scrollbarWidth: 'thin' }}>
        <ul className="space-y-1">
          {history.map(item => (
            <li key={item.id} title={isCollapsed ? item.prompt : undefined}>
              <button
                onClick={() => onSelect(item.id)}
                className={`group flex items-center justify-between w-full text-left px-3 py-2.5 rounded-md transition-colors duration-200 ${
                  selectedId === item.id ? 'bg-slate-200 dark:bg-slate-700 text-slate-800 dark:text-white font-medium' : 'hover:bg-slate-100 dark:hover:bg-slate-700/50'
                } ${isCollapsed ? 'justify-center' : ''}`}
              >
                <div className="flex items-center gap-3 truncate">
                  <FileTextIcon className="w-5 h-5 flex-shrink-0 text-slate-400" />
                  {!isCollapsed && <span className="truncate text-sm">{item.prompt}</span>}
                </div>
                {!isCollapsed && 
                  <Trash2Icon 
                    onClick={(e) => { e.stopPropagation(); onDelete(item.id); }} 
                    className="w-4 h-4 text-slate-500 flex-shrink-0 opacity-0 group-hover:opacity-100 hover:text-red-500 transition-opacity"
                  />
                }
              </button>
            </li>
          ))}
        </ul>
      </div>
      
      <div className="mt-4 pt-4 border-t border-slate-200 dark:border-slate-700 space-y-1">
        <button
            onClick={onOpenSettings}
            className={`flex items-center gap-3 w-full px-3 py-2.5 rounded-md text-slate-500 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-700 hover:text-slate-700 dark:hover:text-slate-200 transition-colors duration-200 ${isCollapsed ? 'justify-center' : ''}`}
        >
            <SettingsIcon className="w-5 h-5 flex-shrink-0" />
            {!isCollapsed && <span className="text-sm font-medium whitespace-nowrap">Settings</span>}
        </button>
         <button
            onClick={toggleTheme}
            className={`flex items-center gap-3 w-full px-3 py-2.5 rounded-md text-slate-500 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-700 hover:text-slate-700 dark:hover:text-slate-200 transition-colors duration-200 ${isCollapsed ? 'justify-center' : ''}`}
        >
            {theme === 'light' ? <MoonIcon className="w-5 h-5 flex-shrink-0" /> : <SunIcon className="w-5 h-5 flex-shrink-0" />}
            {!isCollapsed && <span className="text-sm font-medium whitespace-nowrap">{theme === 'light' ? 'Dark Mode' : 'Light Mode'}</span>}
        </button>
         <button
            onClick={onToggleCollapse}
            className={`flex items-center gap-3 w-full px-3 py-2.5 rounded-md text-slate-500 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-700 hover:text-slate-700 dark:hover:text-slate-200 transition-colors duration-200 ${isCollapsed ? 'justify-center' : ''}`}
        >
            {isCollapsed ? <ChevronsRightIcon className="w-5 h-5 flex-shrink-0" /> : <ChevronsLeftIcon className="w-5 h-5 flex-shrink-0" />}
            {!isCollapsed && <span className="text-sm font-medium whitespace-nowrap">Collapse</span>}
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;