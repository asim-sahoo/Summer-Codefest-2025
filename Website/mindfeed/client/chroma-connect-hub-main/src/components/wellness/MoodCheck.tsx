import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Smile, BarChart2 } from "lucide-react";
import { useToast } from "@/components/ui/use-toast";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

type Mood = {
  emoji: string;
  label: string;
  value: number;
};

const moods: Mood[] = [
  { emoji: "😢", label: "Sad", value: 1 },
  { emoji: "😟", label: "Worried", value: 2 },
  { emoji: "😐", label: "Neutral", value: 3 },
  { emoji: "🙂", label: "Good", value: 4 },
  { emoji: "😄", label: "Happy", value: 5 }
];

interface MoodEntry {
  id: string;
  date: string;
  timestamp: number;
  mood: Mood;
  note: string;
}

const MoodCheck = () => {
  const [selectedMood, setSelectedMood] = useState<Mood | null>(null);
  const [note, setNote] = useState('');
  const [moodEntries, setMoodEntries] = useState<MoodEntry[]>([]);
  const [activeTab, setActiveTab] = useState('check');
  const { toast } = useToast();

  // Load saved mood entries from localStorage
  useEffect(() => {
    const savedEntries = localStorage.getItem('moodEntries');
    if (savedEntries) {
      setMoodEntries(JSON.parse(savedEntries));
    }
  }, []);

  const handleSaveMood = () => {
    if (!selectedMood) {
      toast({
        description: "Please select a mood",
        variant: "destructive",
      });
      return;
    }
    
    const now = new Date();
    const newEntry: MoodEntry = {
      id: Date.now().toString(),
      date: now.toLocaleString(),
      timestamp: now.getTime(),
      mood: selectedMood,
      note: note.trim()
    };
    
    const updatedEntries = [newEntry, ...moodEntries];
    setMoodEntries(updatedEntries);
    localStorage.setItem('moodEntries', JSON.stringify(updatedEntries));
    
    toast({
      description: "Mood logged successfully",
    });
    
    // Reset form
    setSelectedMood(null);
    setNote('');
  };

  const handleDeleteEntry = (id: string) => {
    const updatedEntries = moodEntries.filter(entry => entry.id !== id);
    setMoodEntries(updatedEntries);
    localStorage.setItem('moodEntries', JSON.stringify(updatedEntries));
    
    toast({
      description: "Mood entry deleted",
    });
  };

  // Group entries by day for the chart
  const getChartData = () => {
    const last7Days: { [key: string]: { date: string, average: number, count: number } } = {};
    
    // Create entries for the last 7 days
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toLocaleDateString(undefined, { weekday: 'short' });
      last7Days[dateStr] = { date: dateStr, average: 0, count: 0 };
    }
    
    // Fill in data from entries
    moodEntries.forEach(entry => {
      const entryDate = new Date(entry.timestamp);
      // Only include entries from the last 7 days
      const now = new Date();
      const diffTime = Math.abs(now.getTime() - entryDate.getTime());
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
      
      if (diffDays <= 7) {
        const dateStr = entryDate.toLocaleDateString(undefined, { weekday: 'short' });
        if (last7Days[dateStr]) {
          last7Days[dateStr].average += entry.mood.value;
          last7Days[dateStr].count += 1;
        }
      }
    });
    
    // Calculate averages
    Object.keys(last7Days).forEach(key => {
      if (last7Days[key].count > 0) {
        last7Days[key].average = last7Days[key].average / last7Days[key].count;
      }
    });
    
    return Object.values(last7Days);
  };

  const chartData = getChartData();

  // Get mood trend text
  const getMoodTrend = () => {
    if (moodEntries.length < 2) return "Log more moods to see your trend";
    
    const recentEntries = moodEntries.slice(0, Math.min(5, moodEntries.length));
    const avgMood = recentEntries.reduce((sum, entry) => sum + entry.mood.value, 0) / recentEntries.length;
    
    if (avgMood > 4) return "You've been feeling great lately! 🌟";
    if (avgMood > 3) return "You've been in a good mood recently 😊";
    if (avgMood > 2) return "Your mood has been neutral lately 😐";
    return "You've been feeling down recently. Consider talking to someone about it 💙";
  };

  return (
    <Card className="w-full">
      <CardHeader className="bg-gradient-to-r from-amber-50 to-yellow-50 pb-2">
        <div className="flex items-center">
          <Smile className="h-5 w-5 mr-2 text-amber-600" />
          <CardTitle className="text-lg text-amber-800">Mood Check</CardTitle>
        </div>
        <CardDescription>Track how you're feeling over time</CardDescription>
      </CardHeader>
      
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <div className="px-4 pt-2">
          <TabsList className="w-full">
            <TabsTrigger value="check" className="flex-1">Check In</TabsTrigger>
            <TabsTrigger value="history" className="flex-1">History</TabsTrigger>
            <TabsTrigger value="insights" className="flex-1">Insights</TabsTrigger>
          </TabsList>
        </div>
        
        <TabsContent value="check" className="pt-2">
          <CardContent>
            <div className="text-center mb-4">
              <h3 className="font-medium text-gray-700 mb-2">How are you feeling right now?</h3>
              <div className="flex justify-center gap-2">
                {moods.map(mood => (
                  <button
                    key={mood.label}
                    className={`text-2xl p-2 rounded-full transition-all ${
                      selectedMood?.label === mood.label 
                        ? 'bg-amber-100 scale-125 shadow-sm' 
                        : 'hover:bg-amber-50'
                    }`}
                    onClick={() => setSelectedMood(mood)}
                    title={mood.label}
                  >
                    {mood.emoji}
                  </button>
                ))}
              </div>
              {selectedMood && (
                <p className="text-amber-600 mt-2">You selected: {selectedMood.emoji} {selectedMood.label}</p>
              )}
            </div>
            
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Add a note (optional)
              </label>
              <textarea
                className="w-full p-2 border border-amber-200 rounded-md focus:ring-amber-500 focus:border-amber-500"
                rows={3}
                placeholder="What's contributing to your mood right now?"
                value={note}
                onChange={(e) => setNote(e.target.value)}
              />
            </div>
          </CardContent>
          
          <CardFooter>
            <Button 
              onClick={handleSaveMood} 
              className="w-full bg-amber-600 hover:bg-amber-700 text-white"
              disabled={!selectedMood}
            >
              Log Mood
            </Button>
          </CardFooter>
        </TabsContent>
        
        <TabsContent value="history" className="pt-2">
          <CardContent>
            <h3 className="font-medium text-gray-700 mb-3">Your Mood History</h3>
            
            {moodEntries.length === 0 ? (
              <div className="text-center py-8 text-gray-500">
                <p>You haven't logged any moods yet.</p>
              </div>
            ) : (
              <div className="space-y-3 max-h-[300px] overflow-y-auto pr-2">
                {moodEntries.map(entry => (
                  <div key={entry.id} className="border border-amber-100 rounded-lg p-3">
                    <div className="flex justify-between items-start">
                      <div>
                        <div className="flex items-center">
                          <span className="text-2xl mr-2">{entry.mood.emoji}</span>
                          <span className="font-medium">{entry.mood.label}</span>
                        </div>
                        <span className="text-xs text-gray-500">{entry.date}</span>
                      </div>
                      <Button 
                        variant="ghost" 
                        size="sm" 
                        className="h-6 w-6 p-0 text-gray-400 hover:text-red-500"
                        onClick={() => handleDeleteEntry(entry.id)}
                      >
                        ×
                      </Button>
                    </div>
                    {entry.note && (
                      <p className="text-sm mt-2 text-gray-600">{entry.note}</p>
                    )}
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </TabsContent>
        
        <TabsContent value="insights" className="pt-2">
          <CardContent>
            <div className="mb-4">
              <h3 className="font-medium text-gray-700 mb-1">Your Mood Trend</h3>
              <p className="text-sm text-gray-600 mb-3">{getMoodTrend()}</p>
              
              <div className="bg-amber-50 p-3 rounded-lg">
                <div className="flex items-end h-40 gap-1">
                  {chartData.map((day, index) => (
                    <div key={index} className="flex-1 flex flex-col items-center">
                      <div 
                        className="w-full bg-amber-200 rounded-t-sm"
                        style={{ 
                          height: `${day.average * 20}%`,
                          backgroundColor: day.average > 3 
                            ? 'rgb(245, 158, 11)' 
                            : day.average > 2 
                              ? 'rgb(251, 191, 36)'
                              : 'rgb(209, 213, 219)'
                        }}
                      ></div>
                      <div className="text-xs mt-1 text-gray-600">{day.date}</div>
                    </div>
                  ))}
                </div>
              </div>
              <div className="flex justify-between text-xs text-gray-500 mt-1">
                <span>😢 Sad</span>
                <span>😄 Happy</span>
              </div>
            </div>
            
            {moodEntries.length > 0 && (
              <div>
                <h3 className="font-medium text-gray-700 mb-2">Mood Stats</h3>
                <div className="grid grid-cols-2 gap-2">
                  <div className="bg-amber-50 p-2 rounded-lg">
                    <p className="text-xs text-gray-600">Total Check-ins</p>
                    <p className="text-lg font-medium">{moodEntries.length}</p>
                  </div>
                  <div className="bg-amber-50 p-2 rounded-lg">
                    <p className="text-xs text-gray-600">Most Common Mood</p>
                    <p className="text-lg font-medium">
                      {(() => {
                        const counts: Record<string, number> = {};
                        moodEntries.forEach(entry => {
                          counts[entry.mood.label] = (counts[entry.mood.label] || 0) + 1;
                        });
                        const mostCommon = Object.entries(counts).sort((a, b) => b[1] - a[1])[0];
                        const mood = moods.find(m => m.label === mostCommon[0]);
                        return mood ? `${mood.emoji} ${mood.label}` : 'None';
                      })()}
                    </p>
                  </div>
                </div>
              </div>
            )}
          </CardContent>
        </TabsContent>
      </Tabs>
    </Card>
  );
};

export default MoodCheck;
