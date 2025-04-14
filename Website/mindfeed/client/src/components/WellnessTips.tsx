import React, { useState, useEffect } from 'react';

const wellnessTips = [
  {
    title: "Practice Mindfulness",
    content: "Take 5 minutes to focus on your breathing and be present in the moment.",
    icon: "🧘"
  },
  {
    title: "Digital Detox",
    content: "Try to disconnect from all screens for at least 1 hour before bedtime.",
    icon: "📵"
  },
  {
    title: "Stay Hydrated",
    content: "Drink water regularly throughout the day to maintain focus and energy.",
    icon: "💧"
  },
  {
    title: "Stretch Break",
    content: "Stand up and stretch every 30 minutes to improve circulation and reduce strain.",
    icon: "🤸"
  },
  {
    title: "Gratitude Practice",
    content: "Write down three things you're grateful for to boost your mood.",
    icon: "🙏"
  },
  {
    title: "Nature Connection",
    content: "Spend at least 20 minutes outdoors each day to reduce stress levels.",
    icon: "🌳"
  },
  {
    title: "Digital Boundaries",
    content: "Set specific times to check social media rather than constant scrolling.",
    icon: "⏰"
  },
  {
    title: "Eye Care",
    content: "Follow the 20-20-20 rule: Every 20 minutes, look at something 20 feet away for 20 seconds.",
    icon: "👁️"
  }
];

const WellnessTips = () => {
  const [currentTip, setCurrentTip] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentTip(prev => (prev + 1) % wellnessTips.length);
    }, 60000); // Change tip every minute
    
    return () => clearInterval(interval);
  }, []);

  const tip = wellnessTips[currentTip];

  return (
    <div className="bg-gradient-to-r from-green-50 to-blue-50 p-4 rounded-lg shadow-md border border-green-100">
      <h2 className="text-xl font-semibold text-green-800 flex items-center">
        <span className="mr-2 text-2xl">{tip.icon}</span>
        <span>Wellness Tip</span>
      </h2>
      <div className="mt-3 bg-white bg-opacity-60 p-3 rounded-md">
        <h3 className="font-medium text-lg text-green-700">{tip.title}</h3>
        <p className="mt-1 text-gray-700">{tip.content}</p>
      </div>
      <div className="mt-3 flex justify-between">
        <button 
          onClick={() => setCurrentTip(prev => (prev - 1 + wellnessTips.length) % wellnessTips.length)}
          className="text-blue-600 hover:text-blue-800"
        >
          Previous
        </button>
        <div className="text-xs text-gray-500">
          {currentTip + 1}/{wellnessTips.length}
        </div>
        <button 
          onClick={() => setCurrentTip(prev => (prev + 1) % wellnessTips.length)}
          className="text-blue-600 hover:text-blue-800"
        >
          Next
        </button>
      </div>
    </div>
  );
};

export default WellnessTips;
