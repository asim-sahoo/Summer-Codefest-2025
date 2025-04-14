import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useAuth } from './AuthContext';

interface TimeTrackingContextType {
  timeSpent: number;
  isTimeBlocked: boolean;
  timeLimit: number;
  continueAfterBlock: () => void;
  resetTimer: () => void;
  formatTime: (seconds: number) => string;
}

const TIME_LIMIT_SECONDS = 35 * 60; // 35 minutes in seconds
const TIME_STORAGE_PREFIX = 'wellsta_time_spent_';
const LAST_ACTIVE_PREFIX = 'wellsta_last_active_';

const TimeTrackingContext = createContext<TimeTrackingContextType | undefined>(undefined);

export const TimeTrackingProvider = ({ children }: { children: ReactNode }) => {
  const { user } = useAuth();
  const [timeSpent, setTimeSpent] = useState<number>(0);
  const [isTimeBlocked, setIsTimeBlocked] = useState<boolean>(false);
  const [timeLimit] = useState<number>(TIME_LIMIT_SECONDS);
  
  // Get user-specific storage keys
  const getUserTimeKey = () => {
    if (!user) return TIME_STORAGE_PREFIX + 'guest';
    return TIME_STORAGE_PREFIX + user._id;
  };
  
  const getUserLastActiveKey = () => {
    if (!user) return LAST_ACTIVE_PREFIX + 'guest';
    return LAST_ACTIVE_PREFIX + user._id;
  };

  // Initialize timer
  useEffect(() => {
    if (!user) return;
    
    // Reset time tracking when user changes
    const timeKey = getUserTimeKey();
    const lastActiveKey = getUserLastActiveKey();
    
    // Get stored time for this specific user
    const storedTime = localStorage.getItem(timeKey);
    const lastActive = localStorage.getItem(lastActiveKey);
    
    if (storedTime) {
      setTimeSpent(parseInt(storedTime, 10));
    } else {
      setTimeSpent(0);
    }
    
    // Check if session expired (inactive for more than 30 minutes)
    if (lastActive) {
      const lastActiveTime = parseInt(lastActive, 10);
      const currentTime = Date.now();
      const inactiveTime = (currentTime - lastActiveTime) / 1000; // convert to seconds
      
      if (inactiveTime > 30 * 60) { // 30 minutes
        // Reset timer if inactive for too long
        setTimeSpent(0);
        localStorage.setItem(timeKey, '0');
      }
    }
    
    // Update last active time
    localStorage.setItem(lastActiveKey, Date.now().toString());
    
    // Start timer
    const timer = setInterval(() => {
      setTimeSpent(prevTime => {
        const newTime = prevTime + 1;
        localStorage.setItem(timeKey, newTime.toString());
        
        // Check if time limit reached
        if (newTime >= timeLimit && !isTimeBlocked) {
          setIsTimeBlocked(true);
        }
        
        return newTime;
      });
      
      // Update last active time
      localStorage.setItem(lastActiveKey, Date.now().toString());
    }, 1000);
    
    return () => clearInterval(timer);
  }, [user?._id]);

  // Format time as mm:ss
  const formatTime = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  // Reset timer
  const resetTimer = (): void => {
    setTimeSpent(0);
    localStorage.setItem(getUserTimeKey(), '0');
  };

  // Continue after time block
  const continueAfterBlock = (): void => {
    setIsTimeBlocked(false);
    resetTimer();
  };

  return (
    <TimeTrackingContext.Provider
      value={{
        timeSpent,
        isTimeBlocked,
        timeLimit,
        continueAfterBlock,
        resetTimer,
        formatTime,
      }}
    >
      {children}
    </TimeTrackingContext.Provider>
  );
};

export const useTimeTracking = () => {
  const context = useContext(TimeTrackingContext);
  if (context === undefined) {
    throw new Error('useTimeTracking must be used within a TimeTrackingProvider');
  }
  return context;
};
