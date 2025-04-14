import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Leaf } from "lucide-react";

const mindfulnessPrompts = [
  "Focus on your breath. Notice the sensation of air flowing in and out.",
  "Observe your surroundings. What do you see, hear, smell, feel, and taste?",
  "Scan your body from head to toe. Notice any sensations without judgment.",
  "Watch your thoughts pass by like clouds in the sky, without attaching to them.",
  "Focus on the present moment. What is happening right now?",
  "Bring awareness to the feeling of your feet touching the ground.",
  "Notice the weight of your body against the chair or floor.",
  "Pay attention to the sounds around you, near and far."
];

const MindfulnessExercise = () => {
  const [isActive, setIsActive] = useState(false);
  const [seconds, setSeconds] = useState(0);
  const [currentPrompt, setCurrentPrompt] = useState(0);
  const [totalTime, setTotalTime] = useState(0);
  const sessionLength = 120; // 2 minutes in seconds

  useEffect(() => {
    let interval: NodeJS.Timeout | null = null;
    
    if (isActive && seconds < sessionLength) {
      interval = setInterval(() => {
        setSeconds(prev => {
          const newValue = prev + 1;
          // Change prompt every 30 seconds
          if (newValue % 30 === 0) {
            setCurrentPrompt(current => (current + 1) % mindfulnessPrompts.length);
          }
          return newValue;
        });
      }, 1000);
    } else if (seconds >= sessionLength) {
      setIsActive(false);
      setTotalTime(prev => prev + seconds);
      // Session completed
    }
    
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isActive, seconds]);

  const handleStart = () => {
    setIsActive(true);
  };

  const handlePause = () => {
    setIsActive(false);
  };

  const handleReset = () => {
    setIsActive(false);
    setSeconds(0);
    setCurrentPrompt(0);
  };

  const formatTime = (totalSeconds: number) => {
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  return (
    <Card className="w-full">
      <CardHeader className="bg-gradient-to-r from-green-50 to-blue-50 pb-2">
        <div className="flex items-center">
          <Leaf className="h-5 w-5 mr-2 text-green-600" />
          <CardTitle className="text-lg text-green-800">Mindfulness Practice</CardTitle>
        </div>
        <CardDescription>Take a moment to be present</CardDescription>
      </CardHeader>
      <CardContent className="pt-4">
        <div className="text-center mb-4">
          <div className="text-4xl font-mono mb-2">{formatTime(seconds)}</div>
          <Progress value={(seconds / sessionLength) * 100} className="h-2" />
        </div>
        
        <div className="bg-green-50 p-4 rounded-lg mb-4">
          <p className="text-green-800 italic">{mindfulnessPrompts[currentPrompt]}</p>
        </div>
        
        {!isActive && seconds >= sessionLength && (
          <div className="text-center text-green-700 mb-2">
            <p>Great job! You completed a mindfulness session.</p>
            <p className="text-sm">Total mindfulness time: {formatTime(totalTime + seconds)}</p>
          </div>
        )}
      </CardContent>
      <CardFooter className="flex justify-between">
        {!isActive ? (
          <Button 
            onClick={handleStart} 
            className="bg-green-600 hover:bg-green-700 text-white"
            disabled={seconds >= sessionLength}
          >
            {seconds === 0 ? "Start" : "Resume"}
          </Button>
        ) : (
          <Button onClick={handlePause} variant="outline" className="border-green-600 text-green-700">
            Pause
          </Button>
        )}
        <Button onClick={handleReset} variant="ghost" className="text-gray-500">
          Reset
        </Button>
      </CardFooter>
    </Card>
  );
};

export default MindfulnessExercise;
