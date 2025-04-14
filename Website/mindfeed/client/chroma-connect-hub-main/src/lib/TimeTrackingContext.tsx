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
const TIME_STORAGE_KEY = 'mindfeed_time_spent';
const LAST_ACTIVE_KEY = 'mindfeed_last_active';
const USER_ID_KEY = 'mindfeed_user_id';

const TimeTrackingContext = createContext<TimeTrackingContextType | undefined>(undefined);

export const TimeTrackingProvider = ({ children }: { children: ReactNode }) => {
  const { user } = useAuth();
  const [timeSpent, setTimeSpent] = useState<number>(0);
  const [isTimeBlocked, setIsTimeBlocked] = useState<boolean>(false);
  const [timeLimit] = useState<number>(TIME_LIMIT_SECONDS);
  const [isActive, setIsActive] = useState<boolean>(true);
  const [currentUserId, setCurrentUserId] = useState<string | null>(null);

  // Initialize or update current user ID when user changes
  useEffect(() => {
    if (user) {
      setCurrentUserId(user._id);
    } else {
      setCurrentUserId(null);
    }
  }, [user]);

  // Load saved time on initial load or when user changes
  useEffect(() => {
    if (!user) {
      return;
    }
    
    const savedTime = localStorage.getItem(`${TIME_STORAGE_KEY}_${user._id}`);
    const lastActive = localStorage.getItem(`${LAST_ACTIVE_KEY}_${user._id}`);
    const savedUserId = localStorage.getItem(USER_ID_KEY);
    
    // If this is a new user (first login or different from last user)
    if (savedUserId !== user._id) {
      console.log('User changed or first login, initializing timer');
      
      // If there's no saved time for this user, start from 0
      if (!savedTime) {
        setTimeSpent(0);
        localStorage.setItem(`${TIME_STORAGE_KEY}_${user._id}`, '0');
        localStorage.setItem(`${LAST_ACTIVE_KEY}_${user._id}`, new Date().toISOString());
      } else {
        // Otherwise load their saved time
        setTimeSpent(parseInt(savedTime, 10));
        
        // Check if we should block immediately on load
        if (parseInt(savedTime, 10) >= TIME_LIMIT_SECONDS) {
          setIsTimeBlocked(true);
        }
      }
      
      // Update the current user ID in localStorage
      localStorage.setItem(USER_ID_KEY, user._id);
      return;
    }
    
    // Regular load for the same user
    if (savedTime) {
      // If it's a new day, reset the timer
      if (lastActive && isNewDay(new Date(lastActive))) {
        resetTimerForUser(user._id);
      } else {
        setTimeSpent(parseInt(savedTime, 10));
        
        // Check if we should block immediately on load
        if (parseInt(savedTime, 10) >= TIME_LIMIT_SECONDS) {
          setIsTimeBlocked(true);
        }
      }
    } else {
      // No saved time, initialize to 0
      setTimeSpent(0);
      localStorage.setItem(`${TIME_STORAGE_KEY}_${user._id}`, '0');
    }
    
    // Update last active timestamp
    localStorage.setItem(`${LAST_ACTIVE_KEY}_${user._id}`, new Date().toISOString());
  }, [user]);

  // Timer effect
  useEffect(() => {
    if (!user || !currentUserId) return; // Don't track time if no user is logged in
    
    let interval: number | undefined;
    
    if (isActive && !isTimeBlocked) {
      interval = window.setInterval(() => {
        setTimeSpent(prevTime => {
          const newTime = prevTime + 1;
          localStorage.setItem(`${TIME_STORAGE_KEY}_${currentUserId}`, newTime.toString());
          
          // Check if time limit reached
          if (newTime >= TIME_LIMIT_SECONDS && !isTimeBlocked) {
            setIsTimeBlocked(true);
          }
          
          return newTime;
        });
      }, 1000);
    }
    
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isActive, isTimeBlocked, user, currentUserId]);

  // Track visibility changes
  useEffect(() => {
    if (!user || !currentUserId) return; // Don't track visibility if no user is logged in
    
    const handleVisibilityChange = () => {
      setIsActive(!document.hidden);
      
      // Update last active timestamp when becoming visible
      if (!document.hidden) {
        localStorage.setItem(`${LAST_ACTIVE_KEY}_${currentUserId}`, new Date().toISOString());
      }
    };
    
    document.addEventListener('visibilitychange', handleVisibilityChange);
    
    return () => {
      document.removeEventListener('visibilitychange', handleVisibilityChange);
    };
  }, [user, currentUserId]);

  // Check for user activity
  useEffect(() => {
    if (!user || !currentUserId) return; // Don't track activity if no user is logged in
    
    const activityEvents = ['mousedown', 'keydown', 'touchstart', 'scroll'];
    
    const updateLastActive = () => {
      localStorage.setItem(`${LAST_ACTIVE_KEY}_${currentUserId}`, new Date().toISOString());
    };
    
    activityEvents.forEach(event => {
      window.addEventListener(event, updateLastActive);
    });
    
    return () => {
      activityEvents.forEach(event => {
        window.removeEventListener(event, updateLastActive);
      });
    };
  }, [user, currentUserId]);

  const isNewDay = (lastDate: Date): boolean => {
    const now = new Date();
    return (
      lastDate.getDate() !== now.getDate() ||
      lastDate.getMonth() !== now.getMonth() ||
      lastDate.getFullYear() !== now.getFullYear()
    );
  };

  const continueAfterBlock = () => {
    if (!user) return;
    setIsTimeBlocked(false);
    // Reset timer when user continues
    resetTimerForUser(user._id);
  };

  const resetTimerForUser = (userId: string) => {
    setTimeSpent(0);
    setIsTimeBlocked(false);
    localStorage.setItem(`${TIME_STORAGE_KEY}_${userId}`, '0');
    localStorage.setItem(`${LAST_ACTIVE_KEY}_${userId}`, new Date().toISOString());
  };

  const resetTimer = () => {
    if (!user) return;
    resetTimerForUser(user._id);
  };

  const formatTime = (totalSeconds: number) => {
    const hours = String(Math.floor(totalSeconds / 3600)).padStart(2, '0');
    const minutes = String(Math.floor((totalSeconds % 3600) / 60)).padStart(2, '0');
    const secs = String(totalSeconds % 60).padStart(2, '0');
    return `${hours}:${minutes}:${secs}`;
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
