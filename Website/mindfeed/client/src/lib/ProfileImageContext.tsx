import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useAuth } from './AuthContext';

interface ProfileImageContextType {
  profileImage: string | null;
  coverImage: string | null;
  updateProfileImage: (imageUrl: string) => void;
  updateCoverImage: (imageUrl: string) => void;
}

const ProfileImageContext = createContext<ProfileImageContextType | undefined>(undefined);

export const ProfileImageProvider = ({ children }: { children: ReactNode }) => {
  const { user } = useAuth();
  const [profileImage, setProfileImage] = useState<string | null>(null);
  const [coverImage, setCoverImage] = useState<string | null>(null);

  // Load images when user changes
  useEffect(() => {
    if (!user) {
      setProfileImage(null);
      setCoverImage(null);
      return;
    }

    // Load profile image
    const storedProfileImage = localStorage.getItem(`wellsta-profile-image-${user._id}`);
    if (storedProfileImage) {
      setProfileImage(storedProfileImage);
    } else if (user.profilePicture && user.profilePicture.startsWith('data:')) {
      setProfileImage(user.profilePicture);
    } else if (user.profilePicture && user.profilePicture.trim() !== '') {
      setProfileImage(`http://localhost:4000/images/${user.profilePicture}`);
    } else {
      setProfileImage(null);
    }

    // Load cover image
    const storedCoverImage = localStorage.getItem(`wellsta-cover-image-${user._id}`);
    if (storedCoverImage) {
      setCoverImage(storedCoverImage);
    } else if (user.coverPicture && user.coverPicture.startsWith('data:')) {
      setCoverImage(user.coverPicture);
    } else if (user.coverPicture && user.coverPicture.trim() !== '') {
      setCoverImage(`http://localhost:4000/images/${user.coverPicture}`);
    } else {
      setCoverImage(null);
    }
  }, [user]);

  // Update profile image
  const updateProfileImage = (imageUrl: string) => {
    if (!user) return;
    
    // Update state
    setProfileImage(imageUrl);
    
    // Save to localStorage
    localStorage.setItem(`wellsta-profile-image-${user._id}`, imageUrl);
    
    // For backward compatibility
    localStorage.setItem('wellsta-profile-image', imageUrl);
  };

  // Update cover image
  const updateCoverImage = (imageUrl: string) => {
    if (!user) return;
    
    // Update state
    setCoverImage(imageUrl);
    
    // Save to localStorage
    localStorage.setItem(`wellsta-cover-image-${user._id}`, imageUrl);
    
    // For backward compatibility
    localStorage.setItem('wellsta-cover-image', imageUrl);
  };

  return (
    <ProfileImageContext.Provider
      value={{
        profileImage,
        coverImage,
        updateProfileImage,
        updateCoverImage,
      }}
    >
      {children}
    </ProfileImageContext.Provider>
  );
};

export const useProfileImage = () => {
  const context = useContext(ProfileImageContext);
  if (context === undefined) {
    throw new Error('useProfileImage must be used within a ProfileImageProvider');
  }
  return context;
};
