import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Wind } from "lucide-react";

type BreathingPattern = {
  name: string;
  inhale: number;
  hold1: number;
  exhale: number;
  hold2: number;
  description: string;
};

const breathingPatterns: Record<string, BreathingPattern> = {
  box: {
    name: "Box Breathing",
    inhale: 4,
    hold1: 4,
    exhale: 4,
    hold2: 4,
    description: "Equal parts inhale, hold, exhale, and hold. Great for stress reduction."
  },
  relaxing: {
    name: "Relaxing Breath",
    inhale: 4,
    hold1: 7,
    exhale: 8,
    hold2: 0,
    description: "Longer exhale helps activate the parasympathetic nervous system."
  },
  energizing: {
    name: "Energizing Breath",
    inhale: 6,
    hold1: 0,
    exhale: 2,
    hold2: 0,
    description: "Quick exhale helps increase energy and alertness."
  },
  calm: {
    name: "Calming Breath",
    inhale: 4,
    hold1: 2,
    exhale: 6,
    hold2: 0,
    description: "Longer exhale than inhale helps calm the mind and body."
  }
};

const BreathingExercise = () => {
  const [isActive, setIsActive] = useState(false);
  const [currentPhase, setCurrentPhase] = useState<'inhale' | 'hold1' | 'exhale' | 'hold2'>('inhale');
  const [secondsLeft, setSecondsLeft] = useState(4);
  const [totalBreaths, setTotalBreaths] = useState(0);
  const [selectedPattern, setSelectedPattern] = useState<string>('box');
  const [circleSize, setCircleSize] = useState(100);

  useEffect(() => {
    let interval: NodeJS.Timeout | null = null;
    
    if (isActive) {
      interval = setInterval(() => {
        setSecondsLeft(prev => {
          if (prev <= 1) {
            // Move to next phase
            switch (currentPhase) {
              case 'inhale':
                setCurrentPhase('hold1');
                return breathingPatterns[selectedPattern].hold1 || 1;
              case 'hold1':
                setCurrentPhase('exhale');
                return breathingPatterns[selectedPattern].exhale;
              case 'exhale':
                setCurrentPhase('hold2');
                return breathingPatterns[selectedPattern].hold2 || 1;
              case 'hold2':
                setCurrentPhase('inhale');
                setTotalBreaths(prev => prev + 1);
                return breathingPatterns[selectedPattern].inhale;
              default:
                return prev;
            }
          }
          return prev - 1;
        });
      }, 1000);
    }
    
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isActive, currentPhase, selectedPattern]);

  // Animation effect for the breathing circle
  useEffect(() => {
    if (currentPhase === 'inhale') {
      setCircleSize(prev => Math.min(prev + 5, 180));
    } else if (currentPhase === 'exhale') {
      setCircleSize(prev => Math.max(prev - 5, 100));
    }
  }, [secondsLeft, currentPhase]);

  const handleStart = () => {
    setIsActive(true);
    setCurrentPhase('inhale');
    setSecondsLeft(breathingPatterns[selectedPattern].inhale);
  };

  const handleStop = () => {
    setIsActive(false);
  };

  const handleReset = () => {
    setIsActive(false);
    setCurrentPhase('inhale');
    setSecondsLeft(breathingPatterns[selectedPattern].inhale);
    setTotalBreaths(0);
  };

  const handlePatternChange = (value: string) => {
    setSelectedPattern(value);
    setCurrentPhase('inhale');
    setSecondsLeft(breathingPatterns[value].inhale);
    setIsActive(false);
  };

  const getPhaseText = () => {
    switch (currentPhase) {
      case 'inhale': return 'Inhale';
      case 'hold1': return 'Hold';
      case 'exhale': return 'Exhale';
      case 'hold2': return 'Hold';
      default: return '';
    }
  };

  return (
    <Card className="w-full">
      <CardHeader className="bg-gradient-to-r from-blue-50 to-cyan-50 pb-2">
        <div className="flex items-center">
          <Wind className="h-5 w-5 mr-2 text-blue-600" />
          <CardTitle className="text-lg text-blue-800">Breathing Exercise</CardTitle>
        </div>
        <CardDescription>Calm your mind with controlled breathing</CardDescription>
      </CardHeader>
      <CardContent className="pt-4">
        <div className="mb-4">
          <label className="text-sm font-medium text-gray-700 mb-1 block">Breathing Pattern</label>
          <Select
            value={selectedPattern}
            onValueChange={handlePatternChange}
            disabled={isActive}
          >
            <SelectTrigger className="w-full">
              <SelectValue placeholder="Select a breathing pattern" />
            </SelectTrigger>
            <SelectContent>
              {Object.entries(breathingPatterns).map(([key, pattern]) => (
                <SelectItem key={key} value={key}>{pattern.name}</SelectItem>
              ))}
            </SelectContent>
          </Select>
          <p className="text-xs text-gray-500 mt-1">
            {breathingPatterns[selectedPattern].description}
          </p>
        </div>
        
        <div className="flex flex-col items-center justify-center py-4">
          <div 
            className={`rounded-full bg-blue-100 flex items-center justify-center transition-all duration-1000 mb-4`}
            style={{ 
              width: `${circleSize}px`, 
              height: `${circleSize}px`,
              borderWidth: '2px',
              borderColor: currentPhase === 'hold1' || currentPhase === 'hold2' ? '#3b82f6' : 'transparent',
              borderStyle: 'solid'
            }}
          >
            <div className="text-center">
              <div className="text-blue-800 font-medium text-lg">{getPhaseText()}</div>
              <div className="text-blue-600 text-xl">{secondsLeft}</div>
            </div>
          </div>
          
          <div className="text-sm text-gray-600">
            Total breaths: <span className="font-medium">{totalBreaths}</span>
          </div>
        </div>
      </CardContent>
      <CardFooter className="flex justify-between">
        {!isActive ? (
          <Button 
            onClick={handleStart} 
            className="bg-blue-600 hover:bg-blue-700 text-white"
          >
            Start
          </Button>
        ) : (
          <Button 
            onClick={handleStop} 
            variant="outline"
            className="border-blue-300 text-blue-700"
          >
            Pause
          </Button>
        )}
        <Button 
          onClick={handleReset} 
          variant="ghost"
          className="text-gray-500"
          disabled={totalBreaths === 0 && !isActive}
        >
          Reset
        </Button>
      </CardFooter>
    </Card>
  );
};

export default BreathingExercise;
