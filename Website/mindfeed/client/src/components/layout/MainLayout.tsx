import { Link, Outlet, useLocation, useNavigate } from "react-router-dom";
import { ThemeToggle } from "../ThemeToggle";
import { Bell, Home, MessageSquare, PlusSquare, Search, User, Sparkles, BrainCircuit, Users, BookmarkIcon, LogOut, Settings, Compass } from "lucide-react";
import { useAuth } from "@/lib/AuthContext";
import { Avatar } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuLabel, 
  DropdownMenuSeparator, 
  DropdownMenuTrigger 
} from "@/components/ui/dropdown-menu";
import { useToast } from "@/components/ui/use-toast";
import { useLoading } from '../../lib/LoadingContext';
import { setLoadingController } from '../../lib/api';
import { useEffect } from 'react';

export function MainLayout() {
  const location = useLocation();
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const { toast } = useToast();
  const { setIsLoading } = useLoading();
  
  const isActive = (path: string) => {
    return location.pathname === path;
  };

  // Get profile picture URL
  const getProfilePicUrl = () => {
    // First check for local storage profile picture with user-specific key
    if (user) {
      const localProfilePic = localStorage.getItem(`wellsta-profile-image-${user._id}`);
      if (localProfilePic) {
        return localProfilePic;
      }
    }
    
    // Check for generic local storage profile picture (backward compatibility)
    const genericLocalProfilePic = localStorage.getItem('wellsta-profile-image');
    if (genericLocalProfilePic) {
      return genericLocalProfilePic;
    }
    
    // Fall back to API profile picture if available
    if (user?.profilePicture) {
      // Check if it's already a data URL
      if (user.profilePicture.startsWith('data:')) {
        return user.profilePicture;
      }
      // Otherwise assume it's a filename from the API
      if (user.profilePicture.trim() !== '') {
        return `http://localhost:4000/images/${user.profilePicture}`;
      }
    }
    
    // Return null if no profile picture is available
    return null;
  };
  
  const profilePicUrl = getProfilePicUrl();
    
  // Handle logout
  const handleLogout = () => {
    logout();
    toast({
      title: "Logged out",
      description: "You have been successfully logged out of WellSta.",
    });
    navigate("/login");
  };
  
  // Connect loading controller to API
  useEffect(() => {
    setLoadingController({ setIsLoading });
  }, [setIsLoading]);
  
  return (
    <div className="min-h-screen flex flex-col">
      {/* Top header - desktop */}
      <header className="sticky top-0 z-40 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="container flex h-14 items-center">
          <div className="mr-4 hidden md:flex">
            <Link to="/" className="flex items-center space-x-2">
              <img src="/logo.png" alt="WellSta Logo" className="h-10 w-10" />
              <span className="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600">WellSta</span>
            </Link>
          </div>
          <div className="hidden md:flex flex-1 items-center justify-center px-4">
            <div className="relative w-full max-w-md">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
              <input
                type="search"
                placeholder="Search for people, topics, or content..."
                className="w-full bg-muted pl-8 pr-3 py-2 text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
          <div className="flex items-center gap-3">
            <ThemeToggle />
            
            <Link to="/insights" className="relative p-2 rounded-full hover:bg-muted">
              <Bell className="h-5 w-5" />
              <span className="absolute top-1 right-1 w-2 h-2 bg-blue-500 rounded-full"></span>
            </Link>
            
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <button className="relative">
                  <Avatar className="h-9 w-9 border">
                    {profilePicUrl ? (
                      <img src={profilePicUrl} alt={user?.username} className="h-full w-full object-cover" />
                    ) : (
                      <div className="flex h-full w-full items-center justify-center bg-muted">
                        <User className="h-5 w-5 text-muted-foreground" />
                      </div>
                    )}
                  </Avatar>
                </button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56">
                <DropdownMenuLabel>
                  <div className="flex flex-col space-y-1">
                    <p className="text-sm font-medium">{user?.firstname} {user?.lastname}</p>
                    <p className="text-xs text-muted-foreground">@{user?.username}</p>
                  </div>
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem asChild>
                  <Link to="/profile" className="cursor-pointer">
                    <User className="mr-2 h-4 w-4" />
                    <span>Profile</span>
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link to="/settings" className="cursor-pointer">
                    <Settings className="mr-2 h-4 w-4" />
                    <span>Settings</span>
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={handleLogout} className="cursor-pointer text-red-500 focus:text-red-500">
                  <LogOut className="mr-2 h-4 w-4" />
                  <span>Logout</span>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </header>
      
      {/* Mobile header */}
      <header className="md:hidden sticky top-0 z-40 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="container flex h-14 items-center justify-between">
          <Link to="/" className="flex items-center space-x-2">
            <img src="/logo.png" alt="WellSta Logo" className="h-8 w-8" />
            <span className="font-bold text-xl">WellSta</span>
          </Link>
          <div className="flex items-center gap-3">
            <ThemeToggle />
            
            <Link to="/insights" className="relative p-2 rounded-full hover:bg-muted">
              <Bell className="h-5 w-5" />
              <span className="absolute top-1 right-1 w-2 h-2 bg-blue-500 rounded-full"></span>
            </Link>
            
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <button className="relative">
                  <Avatar className="h-9 w-9 border">
                    {profilePicUrl ? (
                      <img src={profilePicUrl} alt={user?.username} className="h-full w-full object-cover" />
                    ) : (
                      <div className="flex h-full w-full items-center justify-center bg-muted">
                        <User className="h-5 w-5 text-muted-foreground" />
                      </div>
                    )}
                  </Avatar>
                </button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56">
                <DropdownMenuLabel>
                  <div className="flex flex-col space-y-1">
                    <p className="text-sm font-medium">{user?.firstname} {user?.lastname}</p>
                    <p className="text-xs text-muted-foreground">@{user?.username}</p>
                  </div>
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem asChild>
                  <Link to="/profile" className="cursor-pointer">
                    <User className="mr-2 h-4 w-4" />
                    <span>Profile</span>
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link to="/settings" className="cursor-pointer">
                    <Settings className="mr-2 h-4 w-4" />
                    <span>Settings</span>
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={handleLogout} className="cursor-pointer text-red-500 focus:text-red-500">
                  <LogOut className="mr-2 h-4 w-4" />
                  <span>Logout</span>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </header>
      
      {/* Main content */}
      <main className="flex-1 container py-6">
        <Outlet />
      </main>
      
      {/* Bottom navigation - mobile */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 z-50 border-t bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="flex items-center justify-around h-16">
          <Link to="/" className={`flex flex-col items-center justify-center p-2 ${isActive('/') ? 'text-blue-600' : 'text-muted-foreground'}`}>
            <Home className="h-6 w-6" />
            <span className="text-xs mt-1">Home</span>
          </Link>
          
          <Link to="/explore" className={`flex flex-col items-center justify-center p-2 ${isActive('/explore') ? 'text-blue-600' : 'text-muted-foreground'}`}>
            <Compass className="h-6 w-6" />
            <span className="text-xs mt-1">Explore</span>
          </Link>
          
          <Link to="/create" className={`flex flex-col items-center justify-center p-2 ${isActive('/create') ? 'text-blue-600' : 'text-muted-foreground'}`}>
            <PlusSquare className="h-6 w-6" />
            <span className="text-xs mt-1">Create</span>
          </Link>
          
          <Link to="/friends" className={`flex flex-col items-center justify-center p-2 ${isActive('/friends') ? 'text-blue-600' : 'text-muted-foreground'}`}>
            <Users className="h-6 w-6" />
            <span className="text-xs mt-1">Friends</span>
          </Link>
          
          <Link to="/insights" className={`flex flex-col items-center justify-center p-2 ${isActive('/insights') ? 'text-blue-600' : 'text-muted-foreground'}`}>
            <Bell className="h-6 w-6" />
            <span className="text-xs mt-1">Insights</span>
          </Link>
          
          <Link to="/profile" className={`flex flex-col items-center justify-center p-2 ${isActive('/profile') ? 'text-blue-600' : 'text-muted-foreground'}`}>
            <User className="h-6 w-6" />
            <span className="text-xs mt-1">Profile</span>
          </Link>
        </div>
      </nav>

      {/* Desktop sidebar navigation - optional */}
      <div className="hidden lg:block fixed left-4 top-20 bottom-4 w-14 bg-background rounded-full border shadow-sm">
        <div className="flex flex-col items-center justify-center gap-6 py-6 h-full">
          <Link to="/" className={`p-2.5 rounded-full ${isActive('/') ? 'bg-blue-100 text-blue-600' : 'hover:bg-muted'}`}>
            <Home className="h-6 w-6" />
          </Link>
          <Link to="/explore" className={`p-2.5 rounded-full ${isActive('/explore') ? 'bg-blue-100 text-blue-600' : 'hover:bg-muted'}`}>
            <Compass className="h-6 w-6" />
          </Link>
          <Link to="/friends" className={`p-2.5 rounded-full ${isActive('/friends') ? 'bg-blue-100 text-blue-600' : 'hover:bg-muted'}`}>
            <Users className="h-6 w-6" />
          </Link>
          <Link to="/saved" className={`p-2.5 rounded-full ${isActive('/saved') ? 'bg-blue-100 text-blue-600' : 'hover:bg-muted'}`}>
            <BookmarkIcon className="h-6 w-6" />
          </Link>
          <Link to="/insights" className={`p-2.5 rounded-full ${isActive('/insights') ? 'bg-blue-100 text-blue-600' : 'hover:bg-muted'}`}>
            <Bell className="h-6 w-6" />
          </Link>
          <div className="flex-1"></div>
          <Link to="/settings" className={`p-2.5 rounded-full ${isActive('/settings') ? 'bg-blue-100 text-blue-600' : 'hover:bg-muted'}`}>
            <User className="h-6 w-6" />
          </Link>
        </div>
      </div>
    </div>
  );
}
