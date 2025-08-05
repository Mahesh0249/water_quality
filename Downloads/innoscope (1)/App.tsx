
import React, { useState, useEffect } from 'react';
import { HashRouter, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from './components/LoginPage';
import MainPage from './components/MainPage';
import type { User } from './types';

export type Theme = 'light' | 'dark';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [isAuthChecked, setIsAuthChecked] = useState<boolean>(false);
  const [theme, setTheme] = useState<Theme>(() => {
    const savedTheme = localStorage.getItem('innoscope_theme');
    return (savedTheme === 'dark' || savedTheme === 'light') ? savedTheme : 'light';
  });

  useEffect(() => {
    // Check for an existing session
    const sessionEmail = localStorage.getItem('innoscope_user_email');
    if (sessionEmail) {
      setIsAuthenticated(true);
      setCurrentUser({ email: sessionEmail });
    }
    setIsAuthChecked(true);
  }, []);
  
  useEffect(() => {
    if (theme === 'dark') {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
    localStorage.setItem('innoscope_theme', theme);
  }, [theme]);


  const handleLogin = (email: string) => {
    localStorage.setItem('innoscope_user_email', email);
    setIsAuthenticated(true);
    setCurrentUser({ email });
  };

  const handleLogout = () => {
    localStorage.removeItem('innoscope_user_email');
    setIsAuthenticated(false);
    setCurrentUser(null);
  };
  
  const toggleTheme = () => {
    setTheme(prevTheme => prevTheme === 'light' ? 'dark' : 'light');
  };

  if (!isAuthChecked) {
    return (
      <div className="flex items-center justify-center h-screen bg-slate-100 dark:bg-slate-900">
        <div className="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <HashRouter>
      <Routes>
        <Route path="/login" element={
          isAuthenticated ? <Navigate to="/" /> : <LoginPage onLogin={handleLogin} />
        } />
        <Route path="/" element={
          isAuthenticated ? <MainPage onLogout={handleLogout} theme={theme} toggleTheme={toggleTheme} currentUser={currentUser} /> : <Navigate to="/login" />
        } />
      </Routes>
    </HashRouter>
  );
}

export default App;
