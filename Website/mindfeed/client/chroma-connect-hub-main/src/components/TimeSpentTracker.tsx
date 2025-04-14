import React from "react";
import { useTimeTracking } from "@/lib/TimeTrackingContext";
import { cn } from "@/lib/utils";

const TimeSpentTracker = () => {
  const { timeSpent, timeLimit, formatTime } = useTimeTracking();
  
  // Calculate percentage of time used
  const percentUsed = Math.min((timeSpent / timeLimit) * 100, 100);
  
  // Determine color based on usage
  const getProgressColor = () => {
    if (percentUsed < 50) return "bg-green-500";
    if (percentUsed < 85) return "bg-yellow-500";
    return "bg-red-500";
  };

  return (
    <div className="p-4 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg text-center shadow-md border border-blue-100">
      <h2 className="text-xl font-semibold text-blue-800">⏱ Time on WellSta</h2>
      <p className="text-lg text-indigo-700 mt-2 font-mono">{formatTime(timeSpent)}</p>
      
      <div className="mt-2">
        <div className="relative h-2 w-full overflow-hidden rounded-full bg-gray-200">
          <div 
            className={cn("h-full transition-all", getProgressColor())}
            style={{ width: `${percentUsed}%` }}
          />
        </div>
        <div className="flex justify-between text-xs text-gray-500 mt-1">
          <span>0</span>
          <span>Daily limit: 35 min</span>
        </div>
      </div>
      
      <p className="text-xs text-gray-500 mt-2">Be mindful of your digital wellness</p>
    </div>
  );
};

export default TimeSpentTracker;
