import React, { useEffect, useState } from "react";

const MentalHealthNudge = ({ breakAfterMinutes = 30 }) => {
  const [secondsSpent, setSecondsSpent] = useState(0);
  const [showNudge, setShowNudge] = useState(false);
  const [breatheTimer, setBreatheTimer] = useState(30);
  const [breathePhase, setBreathePhase] = useState<'inhale' | 'hold' | 'exhale'>('inhale');

  useEffect(() => {
    const timer = setInterval(() => {
      setSecondsSpent(prev => prev + 1);
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    if (secondsSpent >= breakAfterMinutes * 60 && !showNudge) {
      setShowNudge(true);
    }
  }, [secondsSpent, breakAfterMinutes, showNudge]);

  useEffect(() => {
    let breatheInterval;
    if (showNudge && breatheTimer > 0) {
      breatheInterval = setInterval(() => {
        setBreatheTimer(prev => {
          // Change breathing phase
          if (prev % 10 === 0) {
            setBreathePhase(current => {
              if (current === 'inhale') return 'hold';
              if (current === 'hold') return 'exhale';
              return 'inhale';
            });
          }
          return prev - 1;
        });
      }, 1000);
    }
    return () => clearInterval(breatheInterval);
  }, [showNudge, breatheTimer]);

  const resetNudge = () => {
    setShowNudge(false);
    setBreatheTimer(30);
    setSecondsSpent(0); // Or keep it going if you want to repeat nudges
    setBreathePhase('inhale');
  };

  const getBreathingInstruction = () => {
    switch (breathePhase) {
      case 'inhale': return 'Inhale slowly...';
      case 'hold': return 'Hold your breath...';
      case 'exhale': return 'Exhale gently...';
      default: return '';
    }
  };

  const getBreathingAnimation = () => {
    switch (breathePhase) {
      case 'inhale': return 'scale-110 transition-transform duration-3000';
      case 'hold': return 'scale-110 transition-transform duration-1000';
      case 'exhale': return 'scale-100 transition-transform duration-3000';
      default: return '';
    }
  };

  return (
    <>
      {showNudge && (
        <div className="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-xl shadow-lg text-center w-96 relative overflow-hidden">
            <div className="absolute inset-0 bg-gradient-to-br from-blue-50 to-purple-50 opacity-50"></div>
            <div className="relative z-10">
              <h2 className="text-2xl font-bold mb-2 text-blue-800">🧘‍♂ Mindful Break</h2>
              <p className="mb-4 text-gray-700">You've been scrolling for {Math.floor(secondsSpent / 60)} minutes.</p>
              
              <div className="mb-6">
                <div className={`w-40 h-40 rounded-full bg-blue-100 mx-auto flex items-center justify-center ${getBreathingAnimation()}`}>
                  <div className="text-blue-800 font-medium">{getBreathingInstruction()}</div>
                </div>
                <p className="text-blue-700 font-semibold mt-4">
                  Time remaining: {breatheTimer} seconds
                </p>
              </div>
              
              <div className="text-sm text-gray-600 mb-4">
                <p>Taking regular breaks improves mental focus and reduces stress.</p>
              </div>
              
              <button
                onClick={resetNudge}
                className="bg-gradient-to-r from-blue-500 to-purple-600 text-white px-6 py-2 rounded-full hover:from-blue-600 hover:to-purple-700 transition-all shadow-md"
              >
                I feel refreshed
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default MentalHealthNudge;
