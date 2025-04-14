import React from 'react';
import { useLoading } from '../lib/LoadingContext';

const LoadingScreen = () => {
  const { isLoading } = useLoading();

  if (!isLoading) return null;

  return (
    <div 
      className="fixed inset-0 bg-gradient-to-r from-blue-500 to-purple-500 flex flex-col items-center justify-center z-50"
      style={{ 
        opacity: isLoading ? 1 : 0,
        transition: 'opacity 0.5s ease-in-out',
      }}
    >
      <img 
        src="/logo.png" 
        alt="WellSta Logo" 
        className="w-32 h-auto mb-6"
      />
      <h1 className="text-white text-3xl font-bold mb-6">WellSta</h1>
      <div className="flex space-x-2">
        <div className="w-3 h-3 bg-white rounded-full animate-pulse" style={{ animationDelay: '0s' }}></div>
        <div className="w-3 h-3 bg-white rounded-full animate-pulse" style={{ animationDelay: '0.3s' }}></div>
        <div className="w-3 h-3 bg-white rounded-full animate-pulse" style={{ animationDelay: '0.6s' }}></div>
      </div>
    </div>
  );
};

export default LoadingScreen;
