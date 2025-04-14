import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { PenLine, Save, ArrowRight, List } from "lucide-react";
import { useToast } from "@/components/ui/use-toast";

const journalPrompts = [
  "What are three things you're grateful for today?",
  "What's something that challenged you today and how did you handle it?",
  "Describe a moment that made you smile recently.",
  "What's something you're looking forward to?",
  "What's one thing you learned today?",
  "How are you feeling right now and why?",
  "What's one thing you'd like to improve about yourself?",
  "Write about a recent interaction that had an impact on you.",
  "What boundaries do you need to set or maintain in your life?",
  "Describe your ideal day. What would it look like?"
];

interface JournalEntry {
  id: string;
  date: string;
  content: string;
  prompt: string;
}

const JournalingTool = () => {
  const [journalContent, setJournalContent] = useState('');
  const [currentPrompt, setCurrentPrompt] = useState(0);
  const [entries, setEntries] = useState<JournalEntry[]>([]);
  const [showEntries, setShowEntries] = useState(false);
  const { toast } = useToast();

  // Load saved entries from localStorage
  useEffect(() => {
    const savedEntries = localStorage.getItem('journalEntries');
    if (savedEntries) {
      setEntries(JSON.parse(savedEntries));
    }
    
    // Set a random prompt when component mounts
    setCurrentPrompt(Math.floor(Math.random() * journalPrompts.length));
  }, []);

  const handleSave = () => {
    if (!journalContent.trim()) {
      toast({
        description: "Please write something before saving",
        variant: "destructive",
      });
      return;
    }
    
    const newEntry: JournalEntry = {
      id: Date.now().toString(),
      date: new Date().toLocaleString(),
      content: journalContent,
      prompt: journalPrompts[currentPrompt]
    };
    
    const updatedEntries = [newEntry, ...entries];
    setEntries(updatedEntries);
    localStorage.setItem('journalEntries', JSON.stringify(updatedEntries));
    
    toast({
      description: "Journal entry saved successfully",
    });
    
    setJournalContent('');
    // Set a new random prompt
    setCurrentPrompt(Math.floor(Math.random() * journalPrompts.length));
  };

  const handleNewPrompt = () => {
    let newPrompt = currentPrompt;
    // Ensure we get a different prompt
    while (newPrompt === currentPrompt) {
      newPrompt = Math.floor(Math.random() * journalPrompts.length);
    }
    setCurrentPrompt(newPrompt);
  };

  const handleDeleteEntry = (id: string) => {
    const updatedEntries = entries.filter(entry => entry.id !== id);
    setEntries(updatedEntries);
    localStorage.setItem('journalEntries', JSON.stringify(updatedEntries));
    
    toast({
      description: "Journal entry deleted",
    });
  };

  return (
    <Card className="w-full">
      <CardHeader className="bg-gradient-to-r from-purple-50 to-pink-50 pb-2">
        <div className="flex items-center">
          <PenLine className="h-5 w-5 mr-2 text-purple-600" />
          <CardTitle className="text-lg text-purple-800">Journaling</CardTitle>
        </div>
        <CardDescription>Express your thoughts and feelings</CardDescription>
      </CardHeader>
      
      {!showEntries ? (
        <>
          <CardContent className="pt-4">
            <div className="bg-purple-50 p-3 rounded-lg mb-4">
              <p className="text-purple-800 font-medium">{journalPrompts[currentPrompt]}</p>
              <Button 
                variant="ghost" 
                size="sm" 
                className="text-purple-600 p-0 h-auto mt-1"
                onClick={handleNewPrompt}
              >
                <ArrowRight className="h-4 w-4 mr-1" />
                <span className="text-xs">Try another prompt</span>
              </Button>
            </div>
            
            <Textarea
              placeholder="Start writing here..."
              className="min-h-[150px] resize-none border-purple-200 focus-visible:ring-purple-400"
              value={journalContent}
              onChange={(e) => setJournalContent(e.target.value)}
            />
          </CardContent>
          
          <CardFooter className="flex justify-between">
            <Button 
              variant="outline" 
              className="border-purple-300 text-purple-700"
              onClick={() => setShowEntries(true)}
            >
              <List className="h-4 w-4 mr-2" />
              View Entries
            </Button>
            <Button 
              onClick={handleSave} 
              className="bg-purple-600 hover:bg-purple-700 text-white"
              disabled={!journalContent.trim()}
            >
              <Save className="h-4 w-4 mr-2" />
              Save Entry
            </Button>
          </CardFooter>
        </>
      ) : (
        <>
          <CardContent className="pt-4">
            <h3 className="font-medium text-purple-800 mb-3">Your Journal Entries</h3>
            
            {entries.length === 0 ? (
              <div className="text-center py-8 text-gray-500">
                <p>You haven't created any journal entries yet.</p>
              </div>
            ) : (
              <div className="space-y-4 max-h-[300px] overflow-y-auto pr-2">
                {entries.map(entry => (
                  <div key={entry.id} className="border border-purple-100 rounded-lg p-3">
                    <div className="flex justify-between items-start mb-2">
                      <span className="text-xs text-gray-500">{entry.date}</span>
                      <Button 
                        variant="ghost" 
                        size="sm" 
                        className="h-6 w-6 p-0 text-gray-400 hover:text-red-500"
                        onClick={() => handleDeleteEntry(entry.id)}
                      >
                        ×
                      </Button>
                    </div>
                    <p className="text-xs text-purple-600 italic mb-2">{entry.prompt}</p>
                    <p className="text-sm whitespace-pre-wrap">{entry.content}</p>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
          
          <CardFooter>
            <Button 
              onClick={() => setShowEntries(false)} 
              className="w-full bg-purple-600 hover:bg-purple-700 text-white"
            >
              Write New Entry
            </Button>
          </CardFooter>
        </>
      )}
    </Card>
  );
};

export default JournalingTool;
