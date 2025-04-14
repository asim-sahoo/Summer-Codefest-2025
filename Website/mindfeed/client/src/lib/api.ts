import axios from 'axios';
import { useLoading } from './LoadingContext';

// Use environment variables for API URL with fallback to the deployed backend URL
const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://mindfeed-backend.onrender.com';

let loadingController: { setIsLoading: (loading: boolean) => void } | null = null;

export const setLoadingController = (controller: { setIsLoading: (loading: boolean) => void }) => {
  loadingController = controller;
};

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add request interceptor
api.interceptors.request.use(
  (config) => {
    // Show loading screen on request
    if (loadingController) {
      loadingController.setIsLoading(true);
    }
    
    // Get token from localStorage
    const token = localStorage.getItem('token');
    
    // If token exists, add to headers
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    // Hide loading screen on request error
    if (loadingController) {
      loadingController.setIsLoading(false);
    }
    return Promise.reject(error);
  }
);

// Add response interceptor
api.interceptors.response.use(
  (response) => {
    // Hide loading screen on response
    if (loadingController) {
      loadingController.setIsLoading(false);
    }
    return response;
  },
  (error) => {
    // Hide loading screen on response error
    if (loadingController) {
      loadingController.setIsLoading(false);
    }
    return Promise.reject(error);
  }
);

// Auth API
export const loginUser = async (email: string, password: string) => {
  try {
    const response = await api.post('/auth/login', { email, password });
    return response.data;
  } catch (error) {
    console.error("Error logging in user:", error);
    throw error;
  }
};

export const registerUser = async (userData: any) => {
  try {
    const response = await api.post('/auth/register', userData);
    return response.data;
  } catch (error) {
    console.error("Error registering user:", error);
    throw error;
  }
};

// User API
export const getUser = async (userId: string) => {
  try {
    const response = await api.get(`/user/${userId}`);
    return response.data;
  } catch (error) {
    console.error("Error getting user:", error);
    throw error;
  }
};

export const updateUser = async (userId: string, userData: any) => {
  try {
    const response = await api.put(`/user/${userId}`, userData);
    return response.data;
  } catch (error) {
    console.error("Error updating user:", error);
    throw error;
  }
};

export const followUser = async (userId: string, currentUserId: string) => {
  try {
    const response = await api.put(`/user/${userId}/follow`, { _id: currentUserId });
    return response.data;
  } catch (error) {
    console.error("Error following user:", error);
    throw error;
  }
};

export const unfollowUser = async (userId: string, currentUserId: string) => {
  try {
    const response = await api.put(`/user/${userId}/unfollow`, { _id: currentUserId });
    return response.data;
  } catch (error) {
    console.error("Error unfollowing user:", error);
    throw error;
  }
};

export const getAllUsers = async () => {
  try {
    const response = await api.get('/user');
    return response.data;
  } catch (error) {
    console.error("Error getting all users:", error);
    throw error;
  }
};

// Post API
export const createPost = async (postData: any) => {
  try {
    console.log("Sending post data to server:", postData);
    const response = await api.post('/post', postData);
    console.log("Server response:", response.data);
    return response.data;
  } catch (error) {
    console.error("Error in createPost:", error);
    throw error;
  }
};

export const getPost = async (postId: string) => {
  try {
    const response = await api.get(`/post/${postId}`);
    return response.data;
  } catch (error) {
    console.error("Error getting post:", error);
    throw error;
  }
};

export const updatePost = async (postId: string, postData: any) => {
  try {
    const response = await api.put(`/post/${postId}`, postData);
    return response.data;
  } catch (error) {
    console.error("Error updating post:", error);
    throw error;
  }
};

export const deletePost = async (postId: string) => {
  try {
    const response = await api.delete(`/post/${postId}`);
    return response.data;
  } catch (error) {
    console.error("Error deleting post:", error);
    throw error;
  }
};

export const likePost = async (postId: string, userId: string) => {
  try {
    const response = await api.put(`/post/${postId}/like_dislike`, { userId });
    return response.data;
  } catch (error) {
    console.error("Error liking post:", error);
    throw error;
  }
};

export const getTimelinePosts = async (userId: string) => {
  try {
    console.log("Fetching timeline posts for user:", userId);
    const response = await api.get(`/post/${userId}/timeline`);
    console.log("Timeline posts received:", response.data.length);
    return response.data;
  } catch (error) {
    console.error("Error fetching timeline posts:", error);
    throw error;
  }
};

// Save Post API
export const savePost = async (postId: string, userId: string) => {
  try {
    const response = await api.put(`/user/${userId}/save-post`, { postId });
    return response.data;
  } catch (error) {
    console.error("Error saving post:", error);
    throw error;
  }
};

export const unsavePost = async (postId: string, userId: string) => {
  try {
    const response = await api.put(`/user/${userId}/unsave-post`, { postId });
    return response.data;
  } catch (error) {
    console.error("Error unsaving post:", error);
    throw error;
  }
};

export const getSavedPosts = async (userId: string) => {
  try {
    const response = await api.get(`/user/${userId}/saved-posts`);
    return response.data;
  } catch (error) {
    console.error("Error getting saved posts:", error);
    throw error;
  }
};

// Upload API
export const uploadImage = async (formData: FormData) => {
  try {
    console.log("Uploading single image");
    
    // Extract the file from formData
    const file = formData.get('file') as File;
    
    if (!file) {
      throw new Error("No file found in form data");
    }
    
    // Create a local URL for the file
    const localUrl = URL.createObjectURL(file);
    
    // In a real app, we would upload to server here
    // For now, we'll simulate a successful upload with local storage
    console.log("Image uploaded locally:", localUrl);
    
    // Return a simulated server response
    return {
      success: true,
      filename: localUrl
    };
  } catch (error) {
    console.error("Error uploading image:", error);
    throw error;
  }
};

export const uploadMultipleFiles = async (formData: FormData) => {
  try {
    console.log("Uploading multiple files");
    
    // Extract files from formData
    const files = formData.getAll('files') as File[];
    
    if (!files || files.length === 0) {
      throw new Error("No files found in form data");
    }
    
    // Create local URLs for all files
    const localUrls = files.map(file => URL.createObjectURL(file));
    
    // In a real app, we would upload to server here
    // For now, we'll simulate a successful upload with local storage
    console.log("Multiple files uploaded locally:", localUrls);
    
    // Return a simulated server response
    return {
      success: true,
      filenames: localUrls
    };
  } catch (error) {
    console.error("Error uploading multiple files:", error);
    throw error;
  }
};

export const uploadVoiceNote = async (formData: FormData) => {
  try {
    console.log("Uploading voice note");
    
    // Extract the file from formData
    const file = formData.get('file') as File;
    
    if (!file) {
      throw new Error("No file found in form data");
    }
    
    // Create a local URL for the file
    const localUrl = URL.createObjectURL(file);
    
    // In a real app, we would upload to server here
    // For now, we'll simulate a successful upload with local storage
    console.log("Voice note uploaded locally:", localUrl);
    
    // Return a simulated server response
    return {
      success: true,
      filename: localUrl
    };
  } catch (error) {
    console.error("Error uploading voice note:", error);
    throw error;
  }
};

// News API
export const fetchTechNews = async () => {
  try {
    const response = await axios.get(
      'https://newsapi.org/v2/top-headlines?country=us&category=technology&apiKey=effe00071aa549998ed23ac9c420f4bb'
    );
    return response.data.articles;
  } catch (error) {
    console.error("Error fetching tech news:", error);
    throw error;
  }
};

export default api;
