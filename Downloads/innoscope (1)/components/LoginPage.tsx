
import React, { useState } from 'react';
import { LogoIcon } from './Icons';

interface LoginPageProps {
  onLogin: (email: string) => void;
}

const LoginPage: React.FC<LoginPageProps> = ({ onLogin }) => {
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');

  // WARNING: For demonstration purposes only. Storing passwords in localStorage is insecure.
  // In a real application, use a secure backend with password hashing.
  const getUsers = () => JSON.parse(localStorage.getItem('innoscope_users') || '[]');
  const setUsers = (users: any) => localStorage.setItem('innoscope_users', JSON.stringify(users));

  const handleSignUp = () => {
    if (!email || !password || !confirmPassword) {
      setError('Please fill in all fields.');
      return;
    }
    if (password !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }
    if (password.length < 6) {
      setError('Password should be at least 6 characters long.');
      return;
    }

    const users = getUsers();
    const existingUser = users.find((user: any) => user.email === email);
    if (existingUser) {
      setError('An account with this email already exists.');
      return;
    }
    
    users.push({ email, password });
    setUsers(users);
    setError('');
    onLogin(email);
  };

  const handleSignIn = () => {
    if (!email || !password) {
      setError('Please enter both email and password.');
      return;
    }

    const users = getUsers();
    const user = users.find((u: any) => u.email === email);
    
    if (user && user.password === password) {
      setError('');
      onLogin(email);
    } else {
      setError('Invalid email or password.');
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    if (isSignUp) {
      handleSignUp();
    } else {
      handleSignIn();
    }
  };

  const toggleAuthMode = () => {
    setIsSignUp(!isSignUp);
    setError('');
    setEmail('');
    setPassword('');
    setConfirmPassword('');
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-slate-100 dark:bg-slate-900 p-4 transition-colors duration-300">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <div className="inline-block bg-white dark:bg-slate-800 p-4 rounded-full shadow-md mb-4">
            <LogoIcon className="w-12 h-12 text-blue-600" />
          </div>
          <h1 className="text-4xl font-bold text-slate-800 dark:text-slate-100">
            {isSignUp ? 'Create an Account' : 'Welcome to InnoScope'}
          </h1>
          <p className="text-slate-500 dark:text-slate-400 mt-2">
            {isSignUp ? 'Start your journey of innovation.' : 'Your AI-powered research partner.'}
          </p>
        </div>
        
        <div className="bg-white dark:bg-slate-800 rounded-xl shadow-lg p-8">
          <form onSubmit={handleSubmit}>
            <div className="mb-4">
              <label className="block text-slate-700 dark:text-slate-300 text-sm font-bold mb-2" htmlFor="email">
                Email Address
              </label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@example.com"
                className="w-full px-4 py-3 rounded-lg bg-slate-100 dark:bg-slate-700 text-slate-900 dark:text-slate-200 border border-slate-200 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
                required
              />
            </div>
            <div className="mb-4">
              <label className="block text-slate-700 dark:text-slate-300 text-sm font-bold mb-2" htmlFor="password">
                Password
              </label>
              <input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full px-4 py-3 rounded-lg bg-slate-100 dark:bg-slate-700 text-slate-900 dark:text-slate-200 border border-slate-200 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
                required
              />
            </div>
             {isSignUp && (
              <div className="mb-6">
                <label className="block text-slate-700 dark:text-slate-300 text-sm font-bold mb-2" htmlFor="confirm-password">
                  Confirm Password
                </label>
                <input
                  id="confirm-password"
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full px-4 py-3 rounded-lg bg-slate-100 dark:bg-slate-700 text-slate-900 dark:text-slate-200 border border-slate-200 dark:border-slate-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
                  required
                />
              </div>
            )}
            {error && <p className="text-red-500 text-xs italic mb-4">{error}</p>}
            <div className="flex flex-col space-y-3">
              <button
                type="submit"
                className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg focus:outline-none focus:shadow-outline transition duration-300"
              >
                {isSignUp ? 'Sign Up' : 'Sign In'}
              </button>
            </div>
          </form>
           <p className="text-center text-slate-400 dark:text-slate-500 text-xs mt-6">
            {isSignUp ? 'Already have an account?' : "Don't have an account?"}
            <button onClick={toggleAuthMode} className="text-blue-500 hover:text-blue-400 font-semibold ml-1">
              {isSignUp ? 'Sign In' : 'Sign Up'}
            </button>
          </p>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
