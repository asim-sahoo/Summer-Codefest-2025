import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { ThemeProvider } from "./components/ThemeProvider";
import { MainLayout } from "./components/layout/MainLayout";
import Home from "./pages/Home";
import Login from "./pages/Login";
import Signup from "./pages/Signup";
import Profile from "./pages/Profile";
import PostDetail from "./pages/PostDetail";
import CreatePost from "./pages/CreatePost";
import NotFound from "./pages/NotFound";
import Insights from "./pages/Insights";
import Explore from "./pages/Explore";
import SavedPosts from "./pages/SavedPosts";
import Friends from "./pages/Friends";
import ImageUploadExample from "./pages/ImageUploadExample";
import { AuthProvider, useAuth } from "./lib/AuthContext";
import { TimeTrackingProvider } from "./lib/TimeTrackingContext";
import { LoadingProvider } from "./lib/LoadingContext";
import TimeScreenBlocker from "./components/TimeScreenBlocker";
import LoadingScreen from "./components/LoadingScreen";
import { useTimeTracking } from "./lib/TimeTrackingContext";

const queryClient = new QueryClient();

// Time limit wrapper component
const TimeLimitWrapper = ({ children }: { children: React.ReactNode }) => {
  const { timeSpent, isTimeBlocked, timeLimit, continueAfterBlock } = useTimeTracking();
  
  return (
    <>
      {children}
      <TimeScreenBlocker 
        isOpen={isTimeBlocked} 
        onContinue={continueAfterBlock} 
        timeSpent={timeSpent}
        timeLimit={timeLimit}
      />
    </>
  );
};

// Protected route component
const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return <div className="flex items-center justify-center h-screen">Loading...</div>;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }

  return <>{children}</>;
};

// Public route component (redirects to home if already logged in)
const PublicRoute = ({ children }: { children: React.ReactNode }) => {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return <div className="flex items-center justify-center h-screen">Loading...</div>;
  }

  if (isAuthenticated) {
    return <Navigate to="/" />;
  }

  return <>{children}</>;
};

const AppRoutes = () => {
  return (
    <Routes>
      <Route path="/login" element={<PublicRoute><Login /></PublicRoute>} />
      <Route path="/signup" element={<PublicRoute><Signup /></PublicRoute>} />
      <Route path="/" element={
        <ProtectedRoute>
          <TimeLimitWrapper>
            <MainLayout />
          </TimeLimitWrapper>
        </ProtectedRoute>
      }>
        <Route index element={<Home />} />
        <Route path="profile" element={<Profile />} />
        <Route path="profile/:userId" element={<Profile />} />
        <Route path="post/:id" element={<PostDetail />} />
        <Route path="create" element={<CreatePost />} />
        <Route path="insights" element={<Insights />} />
        <Route path="explore" element={<Explore />} />
        <Route path="saved" element={<SavedPosts />} />
        <Route path="friends" element={<Friends />} />
        <Route path="image-upload" element={<ImageUploadExample />} />
      </Route>
      <Route path="*" element={<NotFound />} />
    </Routes>
  );
};

const App = () => (
  <QueryClientProvider client={queryClient}>
    <AuthProvider>
      <TimeTrackingProvider>
        <LoadingProvider>
          <LoadingScreen />
          <ThemeProvider defaultTheme="light">
            <TooltipProvider>
              <Toaster />
              <Sonner />
              <BrowserRouter>
                <AppRoutes />
              </BrowserRouter>
            </TooltipProvider>
          </ThemeProvider>
        </LoadingProvider>
      </TimeTrackingProvider>
    </AuthProvider>
  </QueryClientProvider>
);

export default App;
