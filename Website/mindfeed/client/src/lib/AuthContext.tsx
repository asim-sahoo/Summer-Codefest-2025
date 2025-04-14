import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { loginUser, registerUser } from './api';

interface User {
  _id: string;
  username: string;
  firstname: string;
  lastname: string;
  email: string;
  profilePicture?: string;
  coverPicture?: string;
  followers: string[];
  following: string[];
  isAdmin: boolean;
  createdAt: string;
  updatedAt: string;
}

interface AuthContextType {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<{ success: boolean, user: User | null, error?: string }>;
  register: (userData: any) => Promise<void>;
  logout: () => void;
  updateUserData: (userData: User) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    // Check if user is already logged in
    const storedToken = localStorage.getItem('token');
    const storedUser = localStorage.getItem('user');
    
    if (storedToken && storedUser) {
      setToken(storedToken);
      setUser(JSON.parse(storedUser));
    }
    
    setIsLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    try {
      setIsLoading(true);
      
      // Try to login with API
      let userData: User;
      try {
        const response = await loginUser(email, password);
        userData = response.user;
        localStorage.setItem('token', response.token);
      } catch (error) {
        console.error("API login failed, using local fallback:", error);
        
        // Fallback to local login for development
        // Generate a random user ID for local storage
        const randomUserId = `local-user-${Date.now()}`;
        
        // Generate random user data
        userData = {
          _id: randomUserId,
          firstname: email.split('@')[0],
          lastname: 'User',
          username: email.split('@')[0].toLowerCase(),
          email: email,
          // No default profile picture - user will upload their own
          profilePicture: '',
          coverPicture: '',
          followers: [],
          following: [],
          isAdmin: false,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        };
        
        // Store token in localStorage
        localStorage.setItem('token', `local-token-${randomUserId}`);
      }
      
      // Clear any previous user-specific data
      localStorage.removeItem(`wellsta-profile-image-${userData._id}`);
      localStorage.removeItem(`wellsta-cover-image-${userData._id}`);
      
      // Set user in state
      setUser(userData);
      setIsAuthenticated(true);
      
      // Reset time tracking for the new user
      localStorage.removeItem(`wellsta_time_spent_${userData._id}`);
      localStorage.removeItem(`wellsta_last_active_${userData._id}`);
      
      return { success: true, user: userData };
    } catch (error) {
      console.error("Login error:", error);
      return { success: false, user: null, error: "Invalid credentials" };
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (userData: any) => {
    setIsLoading(true);
    try {
      // Ensure username field is set if not provided
      if (!userData.username && userData.email) {
        userData.username = userData.email.split('@')[0];
      }
      
      console.log("Sending registration data:", userData);
      const response = await registerUser(userData);
      console.log("Registration response:", response);
      
      const { user, token } = response;
      
      setUser(user);
      setToken(token);
      
      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(user));
    } catch (error) {
      console.error('Registration failed:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    // Store the current user ID before clearing it
    const currentUserId = user?._id;
    
    // Clear user data
    setUser(null);
    setToken(null);
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    
    // Only clear the current user ID from tracking system
    // but preserve individual user time data
    localStorage.removeItem('mindfeed_user_id');
  };

  const updateUserData = (userData: User) => {
    setUser(userData);
    localStorage.setItem('user', JSON.stringify(userData));
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isAuthenticated,
        isLoading,
        login,
        register,
        logout,
        updateUserData,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
