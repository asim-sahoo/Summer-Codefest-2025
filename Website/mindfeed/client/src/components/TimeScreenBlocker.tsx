import React, { useState, useEffect } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { PieChart, Pie, Cell, Legend } from 'recharts';
import { FaClock, FaEye, FaHandPointer, FaSpa, FaDownload } from 'react-icons/fa';
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useAuth } from "@/lib/AuthContext";
import { useTheme } from "@/components/ThemeProvider";
import { Card } from "@/components/ui/card";

interface TimeScreenBlockerProps {
  isOpen: boolean;
  onContinue: () => void;
  timeSpent: number;
  timeLimit: number;
}

const TimeScreenBlocker: React.FC<TimeScreenBlockerProps> = ({ 
  isOpen, 
  onContinue, 
  timeSpent,
  timeLimit 
}) => {
  const { user } = useAuth();
  const { theme } = useTheme();
  const isDarkMode = theme === 'dark';
  const [inputValue, setInputValue] = useState("");
  const [showOvertime, setShowOvertime] = useState(false);
  const [activeTab, setActiveTab] = useState("insights");
  
  const [data, setData] = useState([
    { name: 'Screen Time', value: 63.7, color: '#3B82F6' },
    { name: 'Posts Viewed', value: 31.9, color: '#22C55E' },
    { name: 'Interactions', value: 4.4, color: '#F59E0B' },
  ]);
  
  const [usageStats, setUsageStats] = useState([
    { icon: <FaClock className="text-blue-500 text-2xl" />, label: 'Screen Time', value: '0h 0m' },
    { icon: <FaEye className="text-green-500 text-2xl" />, label: 'Posts Viewed', value: '0' },
    { icon: <FaHandPointer className="text-yellow-500 text-2xl" />, label: 'Interactions', value: '0' },
    { icon: <FaSpa className="text-purple-400 text-2xl" />, label: 'Breathers', value: '0' },
  ]);
  
  const formatTime = (totalSeconds: number) => {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    return `${hours > 0 ? `${hours} hour${hours !== 1 ? 's' : ''} and ` : ''}${minutes} minute${minutes !== 1 ? 's' : ''}`;
  };
  
  const formatTimeForDisplay = (totalSeconds: number) => {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    return `${hours}h ${minutes}m`;
  };
  
  // Generate user-specific data
  useEffect(() => {
    if (user) {
      // Use user ID to seed random data that's consistent for the same user
      const seed = user._id.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
      const randomFactor = (seed % 10) / 10 + 0.5; // Between 0.5 and 1.5
      
      // Generate posts viewed count (150-350)
      const postsViewed = Math.floor(150 + (seed % 200));
      
      // Generate interactions count (20-60)
      const interactions = Math.floor(20 + (seed % 40));
      
      // Generate breathers count (50-100)
      const breathers = Math.floor(50 + (seed % 50));
      
      // Update usage stats
      setUsageStats([
        { icon: <FaClock className="text-blue-500 text-2xl" />, label: 'Screen Time', value: formatTimeForDisplay(timeSpent) },
        { icon: <FaEye className="text-green-500 text-2xl" />, label: 'Posts Viewed', value: postsViewed.toString() },
        { icon: <FaHandPointer className="text-yellow-500 text-2xl" />, label: 'Interactions', value: interactions.toString() },
        { icon: <FaSpa className="text-purple-400 text-2xl" />, label: 'Breathers', value: breathers.toString() },
      ]);
      
      // Calculate percentages for pie chart
      const total = timeSpent + postsViewed + interactions;
      const screenTimePercent = (timeSpent / total) * 100 * randomFactor;
      const postsViewedPercent = (postsViewed / total) * 100 * randomFactor;
      const interactionsPercent = 100 - screenTimePercent - postsViewedPercent;
      
      setData([
        { name: 'Screen Time', value: parseFloat(screenTimePercent.toFixed(1)), color: isDarkMode ? '#60A5FA' : '#3B82F6' },
        { name: 'Posts Viewed', value: parseFloat(postsViewedPercent.toFixed(1)), color: isDarkMode ? '#4ADE80' : '#22C55E' },
        { name: 'Interactions', value: parseFloat(interactionsPercent.toFixed(1)), color: isDarkMode ? '#FBBF24' : '#F59E0B' },
      ]);
    }
  }, [user, timeSpent, isDarkMode]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (inputValue.toLowerCase() === "continue") {
      setShowOvertime(true);
      setTimeout(() => {
        onContinue();
        setShowOvertime(false);
        setInputValue("");
      }, 3000);
    }
  };
  
  // Function to generate and download CSV report
  const downloadCSVReport = () => {
    // Create CSV content
    const headers = ['Metric', 'Value'];
    const rows = [
      ['Date', new Date().toLocaleDateString()],
      ['User', user?.username || 'Anonymous'],
      ...usageStats.map(stat => [stat.label, stat.value]),
      ...data.map(item => [`${item.name} (%)`, item.value.toString()])
    ];
    
    // Format as CSV
    const csvContent = [
      headers.join(','),
      ...rows.map(row => row.join(','))
    ].join('\n');
    
    // Create download link
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `wellsta-insights-${new Date().toISOString().split('T')[0]}.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <Dialog open={isOpen} onOpenChange={() => {}}>
      <DialogContent 
        className={`sm:max-w-xl max-h-[90vh] overflow-y-auto ${isDarkMode ? 'bg-gray-900 text-gray-100 border-gray-700' : ''}`} 
        onInteractOutside={(e) => e.preventDefault()}
      >
        <DialogHeader>
          <div className="flex justify-between items-center">
            <DialogTitle className={`text-xl ${isDarkMode ? 'text-purple-400' : 'text-purple-700'}`}>
              {showOvertime ? "⚠️ Overtime Usage" : "⏰ Mindfulness Break"}
            </DialogTitle>
            <Button 
              onClick={downloadCSVReport} 
              variant="outline" 
              size="sm"
              className={`flex items-center gap-2 ${isDarkMode ? 'border-gray-700 hover:bg-gray-800' : ''}`}
            >
              <FaDownload className="h-4 w-4" />
              <span>Download Report</span>
            </Button>
          </div>
        </DialogHeader>
        
        <Tabs defaultValue="insights" className="w-full">
          <TabsList className={`grid w-full grid-cols-2 ${isDarkMode ? 'bg-gray-800' : ''}`}>
            <TabsTrigger 
              value="insights" 
              onClick={() => setActiveTab("insights")}
              className={isDarkMode ? 'data-[state=active]:bg-gray-700 data-[state=active]:text-white' : ''}
            >
              Insights
            </TabsTrigger>
            <TabsTrigger 
              value="message" 
              onClick={() => setActiveTab("message")}
              className={isDarkMode ? 'data-[state=active]:bg-gray-700 data-[state=active]:text-white' : ''}
            >
              Message
            </TabsTrigger>
          </TabsList>
          
          <TabsContent value="insights" className="space-y-4 py-4">
            <Card className={`p-4 ${isDarkMode ? 'bg-gray-800 border-gray-700' : ''}`}>
              <h2 className={`text-lg font-semibold mb-2 ${isDarkMode ? 'text-gray-200' : ''}`}>Usage Statistics</h2>
              <div className="grid grid-cols-2 gap-4">
                {usageStats.map((stat, index) => (
                  <div 
                    key={index} 
                    className={`${isDarkMode ? 'bg-gray-700' : 'bg-gray-50'} p-4 rounded-lg shadow-sm flex items-center space-x-4`}
                  >
                    <div>{stat.icon}</div>
                    <div>
                      <p className="text-xl font-bold">{stat.value}</p>
                      <p className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>{stat.label}</p>
                    </div>
                  </div>
                ))}
              </div>
            </Card>

            <Card className={`p-4 ${isDarkMode ? 'bg-gray-800 border-gray-700' : ''}`}>
              <h2 className={`text-lg font-semibold mb-2 ${isDarkMode ? 'text-gray-200' : ''}`}>Activity Distribution</h2>
              <div className="flex justify-center">
                <PieChart width={300} height={250}>
                  <Pie
                    data={data}
                    dataKey="value"
                    nameKey="name"
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={90}
                    label={({ percent }) => `${(percent * 100).toFixed(1)}%`}
                    labelLine={false}
                  >
                    {data.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Legend 
                    formatter={(value) => <span className={isDarkMode ? 'text-gray-300' : ''}>{value}</span>}
                  />
                </PieChart>
              </div>
            </Card>
              
            <Card className={`p-4 ${isDarkMode ? 'bg-gray-800 border-gray-700' : ''}`}>
              <h2 className={`text-lg font-semibold mb-2 ${isDarkMode ? 'text-gray-200' : ''}`}>Wellness Recommendations</h2>
              <div className={`${isDarkMode ? 'bg-gray-700 border-gray-600' : 'bg-blue-50 border-blue-100'} p-4 rounded-lg border`}>
                <h3 className={`font-medium ${isDarkMode ? 'text-blue-300' : 'text-blue-800'}`}>Based on your activity:</h3>
                <ul className="mt-2 space-y-2">
                  <li className="flex items-start">
                    <span className={`${isDarkMode ? 'text-green-400' : 'text-green-500'} mr-2`}>•</span>
                    <span>Try to take a 5-minute break every 25 minutes of screen time</span>
                  </li>
                  <li className="flex items-start">
                    <span className={`${isDarkMode ? 'text-green-400' : 'text-green-500'} mr-2`}>•</span>
                    <span>Consider reducing your session length by 15% tomorrow</span>
                  </li>
                  <li className="flex items-start">
                    <span className={`${isDarkMode ? 'text-green-400' : 'text-green-500'} mr-2`}>•</span>
                    <span>Your interaction rate is healthy - keep engaging meaningfully!</span>
                  </li>
                </ul>
              </div>
            </Card>
          </TabsContent>
          
          <TabsContent value="message" className="space-y-4 py-4">
            <Card className={`p-4 ${isDarkMode ? 'bg-gray-800 border-gray-700' : ''}`}>
              {showOvertime ? (
                <div className="space-y-2">
                  <p>You are now using <span className={`font-bold ${isDarkMode ? 'text-red-400' : 'text-red-500'}`}>additional time</span> beyond your daily limit.</p>
                  <p>Remember to take breaks for your mental wellbeing.</p>
                </div>
              ) : (
                <div className="space-y-2">
                  <p>You've spent <span className="font-bold">{formatTime(timeSpent)}</span> on WellSta today.</p>
                  <p>Your daily limit of <span className="font-bold">{formatTime(timeLimit)}</span> has been reached.</p>
                  <p className="pt-2">Taking regular breaks from social media is important for your mental health.</p>
                  <p className="pt-2">Type <span className="font-bold">"continue"</span> below if you need to continue using WellSta.</p>
                </div>
              )}
            </Card>
          </TabsContent>
        </Tabs>

        {!showOvertime && (
          <form onSubmit={handleSubmit} className="space-y-4 pt-4">
            <Input
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              placeholder="Type 'continue' to proceed"
              className={`w-full ${isDarkMode ? 'bg-gray-800 border-gray-700 text-white' : ''}`}
              autoFocus
            />
            <DialogFooter>
              <Button 
                type="submit" 
                disabled={inputValue.toLowerCase() !== "continue"}
                className={isDarkMode ? 'bg-purple-700 hover:bg-purple-600' : ''}
              >
                Continue Session
              </Button>
            </DialogFooter>
          </form>
        )}
      </DialogContent>
    </Dialog>
  );
};

export default TimeScreenBlocker;
