import React, { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { BrainCircuit } from "lucide-react";
import MindfulnessExercise from './MindfulnessExercise';
import JournalingTool from './JournalingTool';
import BreathingExercise from './BreathingExercise';
import MoodCheck from './MoodCheck';

const WellnessDashboard = () => {
  const [activeTab, setActiveTab] = useState('mindfulness');

  return (
    <Card className="w-full">
      <CardHeader className="bg-gradient-to-r from-blue-50 to-purple-50 pb-2">
        <div className="flex items-center">
          <BrainCircuit className="h-5 w-5 mr-2 text-blue-600" />
          <CardTitle className="text-lg text-blue-800">Wellness Center</CardTitle>
        </div>
        <CardDescription>Tools to support your mental wellbeing</CardDescription>
      </CardHeader>
      
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <div className="px-4 pt-2">
          <TabsList className="w-full">
            <TabsTrigger value="mindfulness" className="flex-1">Mindfulness</TabsTrigger>
            <TabsTrigger value="journaling" className="flex-1">Journaling</TabsTrigger>
            <TabsTrigger value="breathing" className="flex-1">Breathing</TabsTrigger>
            <TabsTrigger value="mood" className="flex-1">Mood Check</TabsTrigger>
          </TabsList>
        </div>
        
        <TabsContent value="mindfulness" className="p-0">
          <CardContent className="p-0">
            <MindfulnessExercise />
          </CardContent>
        </TabsContent>
        
        <TabsContent value="journaling" className="p-0">
          <CardContent className="p-0">
            <JournalingTool />
          </CardContent>
        </TabsContent>
        
        <TabsContent value="breathing" className="p-0">
          <CardContent className="p-0">
            <BreathingExercise />
          </CardContent>
        </TabsContent>
        
        <TabsContent value="mood" className="p-0">
          <CardContent className="p-0">
            <MoodCheck />
          </CardContent>
        </TabsContent>
      </Tabs>
    </Card>
  );
};

export default WellnessDashboard;
