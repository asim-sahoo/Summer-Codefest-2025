import React, { useEffect, useState } from 'react';
import { PieChart, Pie, Cell, Legend } from 'recharts';
import { FaClock, FaEye, FaHandPointer, FaSpa, FaDownload } from 'react-icons/fa';
import { Home, Plus, User, BarChart2 } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useTimeTracking } from '@/lib/TimeTrackingContext';
import { useAuth } from '@/lib/AuthContext';
import { useTheme } from '@/components/ThemeProvider';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';

const Insights = () => {
  const { user } = useAuth();
  const { timeSpent, formatTime } = useTimeTracking();
  const { theme } = useTheme();
  const isDarkMode = theme === 'dark';
  
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
  
  // Format time for display (e.g., "9h 50m")
  const formatTimeForDisplay = (totalSeconds: number) => {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    return `${hours}h ${minutes}m`;
  };
  
  // Generate random but consistent data based on user ID
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
  
  // Update screen time value when timeSpent changes
  useEffect(() => {
    setUsageStats(prev => 
      prev.map(stat => 
        stat.label === 'Screen Time' 
          ? { ...stat, value: formatTimeForDisplay(timeSpent) } 
          : stat
      )
    );
  }, [timeSpent]);
  
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
    <div className={`min-h-screen ${isDarkMode ? 'bg-gray-900 text-gray-100' : 'bg-white text-gray-800'} p-4 flex flex-col justify-between`}>
      <div>
        <div className="flex justify-between items-center mb-4">
          <h1 className={`text-xl font-bold ${isDarkMode ? 'text-purple-400' : 'text-purple-700'}`}>Insights</h1>
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

        <Card className={`p-4 mb-6 ${isDarkMode ? 'bg-gray-800 border-gray-700' : ''}`}>
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

        <Card className={`p-4 mb-6 ${isDarkMode ? 'bg-gray-800 border-gray-700' : ''}`}>
          <h2 className={`text-lg font-semibold mb-2 ${isDarkMode ? 'text-gray-200' : ''}`}>Activity Distribution</h2>
          <div className="flex justify-center">
            <PieChart width={300} height={300}>
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
      </div>

      <nav className={`${isDarkMode ? 'bg-gray-800 shadow-lg' : 'bg-white shadow-inner'} rounded-t-xl px-6 py-2 flex justify-between items-center mt-6`}>
        <Link to="/" className={`flex flex-col items-center ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>
          <Home size={24} />
          <span className="text-xs">Feed</span>
        </Link>
        <Link to="/create" className={`flex flex-col items-center ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>
          <Plus size={24} />
          <span className="text-xs">Create</span>
        </Link>
        <Link to="/profile" className={`flex flex-col items-center ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>
          <User size={24} />
          <span className="text-xs">Profile</span>
        </Link>
        <div className={`flex flex-col items-center ${isDarkMode ? 'text-purple-400' : 'text-purple-600'}`}>
          <BarChart2 size={24} />
          <span className="text-xs font-semibold">Insights</span>
        </div>
      </nav>
    </div>
  );
};

export default Insights;
