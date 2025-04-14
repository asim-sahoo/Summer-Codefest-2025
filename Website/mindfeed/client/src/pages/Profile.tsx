import { useState, useEffect } from "react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { PostCard } from "@/components/post/PostCard";
import { Button } from "@/components/ui/button";
import { Calendar, Edit, Link2, MapPin, Settings, Upload, User, Loader2 } from "lucide-react";
import { useAuth } from "@/lib/AuthContext";
import { getUser, updateUser, uploadImage } from "@/lib/api";
import { useToast } from "@/components/ui/use-toast";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { getTimelinePosts } from "@/lib/api";
import { useParams } from "react-router-dom";
import { Avatar } from "@/components/ui/avatar";

export default function Profile() {
  const { user, updateUserData } = useAuth();
  const { userId } = useParams();
  const [profileData, setProfileData] = useState<any>(null);
  const [posts, setPosts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isUploading, setIsUploading] = useState(false);
  const [openEditDialog, setOpenEditDialog] = useState(false);
  const [editFormData, setEditFormData] = useState({
    firstname: "",
    lastname: "",
    username: "",
    bio: "",
    location: "",
    website: ""
  });
  const { toast } = useToast();

  useEffect(() => {
    const fetchProfileData = async () => {
      try {
        // Determine which user ID to use
        const targetUserId = userId || (user ? user._id : null);
        
        if (!targetUserId) {
          setLoading(false);
          return;
        }
        
        // Check if we're looking at the current user's profile
        const isOwnProfile = !userId || (user && userId === user._id);
        
        // Try to get user data from API
        let userData;
        try {
          userData = await getUser(targetUserId);
        } catch (error) {
          console.error("Error fetching user data from API:", error);
          
          // If it's the current user and API fails, use local data
          if (isOwnProfile && user) {
            userData = { ...user };
            
            // Add local profile picture if available
            const localProfilePic = localStorage.getItem(`wellsta-profile-image-${user._id}`);
            if (localProfilePic) {
              userData.profilePicture = localProfilePic;
            }
            
            // Add local cover photo if available
            const localCoverPhoto = localStorage.getItem(`wellsta-cover-image-${user._id}`);
            if (localCoverPhoto) {
              userData.coverPicture = localCoverPhoto;
            }
          } else {
            throw error; // Re-throw if not own profile
          }
        }
        
        setProfileData(userData);
        setEditFormData({
          firstname: userData.firstname || "",
          lastname: userData.lastname || "",
          username: userData.username || "",
          bio: userData.about || "",
          location: userData.livesIn || "",
          website: userData.worksAt || ""
        });
        
        // Fetch user's posts
        try {
          const postsData = await getTimelinePosts(targetUserId);
          setPosts(postsData);
        } catch (error) {
          console.error("Error fetching posts:", error);
          // If API fails, try to get local posts
          if (isOwnProfile) {
            const localPosts = JSON.parse(localStorage.getItem('wellsta_local_posts') || '[]');
            setPosts(localPosts);
          }
        }
      } catch (error) {
        console.error("Error fetching profile data:", error);
        toast({
          title: "Error",
          description: "Could not load profile data. Please try again later.",
          variant: "destructive",
        });
      } finally {
        setLoading(false);
      }
    };
    
    fetchProfileData();
  }, [user, userId, toast]);

  const handleProfilePictureUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!user || !e.target.files || e.target.files.length === 0) return;
    
    setIsUploading(true);
    
    try {
      const file = e.target.files[0];
      
      // Read file as data URL
      const reader = new FileReader();
      reader.onload = async (event) => {
        if (!event.target || typeof event.target.result !== 'string') {
          throw new Error("Failed to read file");
        }
        
        const imageDataUrl = event.target.result;
        
        // Save to localStorage with user-specific key
        localStorage.setItem(`wellsta-profile-image-${user._id}`, imageDataUrl);
        
        try {
          // Try API upload if available
          const formData = new FormData();
          const fileName = Date.now() + file.name;
          formData.append("name", fileName);
          formData.append("file", file);
          
          await uploadImage(formData);
          
          // Update user profile with new profile picture
          const updatedUser = await updateUser(user._id, {
            _id: user._id,
            profilePicture: fileName
          });
          
          // Update auth context
          updateUserData(updatedUser.user);
        } catch (error) {
          console.error("API upload failed, using local storage only:", error);
          // Update auth context with local image
          if (user) {
            updateUserData({
              ...user,
              profilePicture: imageDataUrl
            });
          }
        }
        
        // Update local state
        setProfileData(prev => ({
          ...prev,
          profilePicture: imageDataUrl
        }));
        
        toast({
          title: "Success",
          description: "Profile picture updated successfully!",
        });
        
        setIsUploading(false);
      };
      
      reader.onerror = () => {
        toast({
          title: "Upload failed",
          description: "There was an error reading the image file.",
          variant: "destructive",
        });
        setIsUploading(false);
      };
      
      reader.readAsDataURL(file);
    } catch (error) {
      console.error("Error uploading profile picture:", error);
      toast({
        title: "Upload failed",
        description: "There was an error updating your profile picture.",
        variant: "destructive",
      });
      setIsUploading(false);
    }
  };

  const handleCoverPhotoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!user || !e.target.files || e.target.files.length === 0) return;
    
    setIsUploading(true);
    
    try {
      const file = e.target.files[0];
      
      // Read file as data URL
      const reader = new FileReader();
      reader.onload = async (event) => {
        if (!event.target || typeof event.target.result !== 'string') {
          throw new Error("Failed to read file");
        }
        
        const imageDataUrl = event.target.result;
        
        // Save to localStorage with user-specific key
        localStorage.setItem(`wellsta-cover-image-${user._id}`, imageDataUrl);
        
        try {
          // Try API upload if available
          const formData = new FormData();
          const fileName = Date.now() + file.name;
          formData.append("name", fileName);
          formData.append("file", file);
          
          await uploadImage(formData);
          
          // Update user profile with new cover photo
          const updatedUser = await updateUser(user._id, {
            _id: user._id,
            coverPicture: fileName
          });
          
          // Update auth context
          updateUserData(updatedUser.user);
        } catch (error) {
          console.error("API upload failed, using local storage only:", error);
          // Update auth context with local image
          if (user) {
            updateUserData({
              ...user,
              coverPicture: imageDataUrl
            });
          }
        }
        
        // Update local state
        setProfileData(prev => ({
          ...prev,
          coverPicture: imageDataUrl
        }));
        
        toast({
          title: "Success",
          description: "Cover photo updated successfully!",
        });
        
        setIsUploading(false);
      };
      
      reader.onerror = () => {
        toast({
          title: "Upload failed",
          description: "There was an error reading the image file.",
          variant: "destructive",
        });
        setIsUploading(false);
      };
      
      reader.readAsDataURL(file);
    } catch (error) {
      console.error("Error uploading cover photo:", error);
      toast({
        title: "Upload failed",
        description: "There was an error updating your cover photo.",
        variant: "destructive",
      });
      setIsUploading(false);
    }
  };

  const handleEditFormChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setEditFormData({
      ...editFormData,
      [e.target.name]: e.target.value
    });
  };

  const handleProfileUpdate = async () => {
    if (!user) return;
    
    try {
      const updatedUser = await updateUser(user._id, {
        _id: user._id,
        firstname: editFormData.firstname,
        lastname: editFormData.lastname,
        username: editFormData.username,
        about: editFormData.bio,
        livesIn: editFormData.location,
        worksAt: editFormData.website
      });
      
      // Update local state
      setProfileData({
        ...profileData,
        firstname: editFormData.firstname,
        lastname: editFormData.lastname,
        username: editFormData.username,
        about: editFormData.bio,
        livesIn: editFormData.location,
        worksAt: editFormData.website
      });
      
      // Update auth context
      updateUserData(updatedUser.user);
      
      toast({
        title: "Success",
        description: "Profile updated successfully!",
      });
      
      setOpenEditDialog(false);
    } catch (error) {
      console.error("Error updating profile:", error);
      toast({
        title: "Update failed",
        description: "There was an error updating your profile.",
        variant: "destructive",
      });
    }
  };

  const getProfilePicUrl = (picturePath?: string) => {
    // First check if it's already a data URL
    if (picturePath && picturePath.startsWith('data:')) {
      return picturePath;
    }
    
    // Check for local storage profile picture
    const localProfilePic = localStorage.getItem(`wellsta-profile-image-${user?._id}`);
    if (localProfilePic && (!userId || (user && userId === user._id))) {
      return localProfilePic;
    }
    
    // Fall back to API profile picture if available
    if (picturePath) {
      return `http://localhost:4000/images/${picturePath}`;
    }
    
    return undefined;
  };

  const getCoverPhotoUrl = (picturePath?: string) => {
    // First check if it's already a data URL
    if (picturePath && picturePath.startsWith('data:')) {
      return picturePath;
    }
    
    // Check for local storage cover photo
    const localCoverPhoto = localStorage.getItem(`wellsta-cover-image-${user?._id}`);
    if (localCoverPhoto && (!userId || (user && userId === user._id))) {
      return localCoverPhoto;
    }
    
    // Fall back to API cover photo if available
    if (picturePath) {
      return `http://localhost:4000/images/${picturePath}`;
    }
    
    return undefined;
  };

  if (loading) {
    return <div className="flex items-center justify-center h-[calc(100vh-4rem)]"><Loader2 className="h-8 w-8 animate-spin" /></div>;
  }

  if (!profileData) {
    return <div className="flex items-center justify-center h-[calc(100vh-4rem)]">User not found</div>;
  }

  const fullName = `${profileData.firstname || ''} ${profileData.lastname || ''}`.trim();
  const profilePicUrl = getProfilePicUrl(profileData.profilePicture);
  const coverPhotoUrl = getCoverPhotoUrl(profileData.coverPicture);
  const isOwnProfile = !userId || (user && userId === user._id);

  return (
    <>
      <div className="relative">
        {/* Cover photo */}
        <div className="h-48 bg-gradient-to-r from-blue-600 to-purple-600 relative">
          {coverPhotoUrl && (
            <img 
              src={coverPhotoUrl} 
              alt="Cover" 
              className="w-full h-full object-cover"
            />
          )}
          
          {isOwnProfile && (
            <label className="absolute bottom-4 right-4 cursor-pointer">
              <input 
                type="file" 
                accept="image/*" 
                className="hidden" 
                onChange={handleCoverPhotoUpload}
                disabled={isUploading}
              />
              <Button size="sm" variant="secondary" className="gap-1">
                <Upload className="h-4 w-4" />
                <span>Change Cover</span>
              </Button>
            </label>
          )}
        </div>
        
        {/* Profile picture and info */}
        <div className="px-4 pb-4 relative">
          <div className="relative -mt-12 mb-4 flex justify-between items-end">
            <div className="relative">
              <Avatar className="h-24 w-24 border-4 border-background">
                {profilePicUrl ? (
                  <img 
                    src={profilePicUrl} 
                    alt={profileData.username} 
                    className="h-full w-full object-cover"
                  />
                ) : (
                  <div className="flex h-full w-full items-center justify-center bg-muted">
                    <User className="h-12 w-12 text-muted-foreground" />
                  </div>
                )}
              </Avatar>
              
              {isOwnProfile && (
                <label className="absolute bottom-0 right-0 cursor-pointer">
                  <input 
                    type="file" 
                    accept="image/*" 
                    className="hidden" 
                    onChange={handleProfilePictureUpload}
                    disabled={isUploading}
                  />
                  <div className="h-8 w-8 rounded-full bg-primary text-primary-foreground flex items-center justify-center">
                    <Edit className="h-4 w-4" />
                  </div>
                </label>
              )}
            </div>
            
            <div className="flex justify-end mb-4">
              <Button variant="outline" size="sm" className="ml-2">
                <Settings className="h-4 w-4 mr-2" />
                Settings
              </Button>
              <Dialog open={openEditDialog} onOpenChange={setOpenEditDialog}>
                <DialogTrigger asChild>
                  <Button variant="outline" size="sm" className="ml-2">
                    <Edit className="h-4 w-4 mr-2" />
                    Edit profile
                  </Button>
                </DialogTrigger>
                <DialogContent>
                  <DialogHeader>
                    <DialogTitle>Edit Profile</DialogTitle>
                  </DialogHeader>
                  <div className="grid gap-4 py-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="firstname">First name</Label>
                        <Input
                          id="firstname"
                          name="firstname"
                          value={editFormData.firstname}
                          onChange={handleEditFormChange}
                        />
                      </div>
                      <div>
                        <Label htmlFor="lastname">Last name</Label>
                        <Input
                          id="lastname"
                          name="lastname"
                          value={editFormData.lastname}
                          onChange={handleEditFormChange}
                        />
                      </div>
                    </div>
                    <div>
                      <Label htmlFor="username">Username</Label>
                      <Input
                        id="username"
                        name="username"
                        value={editFormData.username}
                        onChange={handleEditFormChange}
                      />
                    </div>
                    <div>
                      <Label htmlFor="bio">Bio</Label>
                      <Input
                        id="bio"
                        name="bio"
                        value={editFormData.bio}
                        onChange={handleEditFormChange}
                      />
                    </div>
                    <div>
                      <Label htmlFor="location">Location</Label>
                      <Input
                        id="location"
                        name="location"
                        value={editFormData.location}
                        onChange={handleEditFormChange}
                      />
                    </div>
                    <div>
                      <Label htmlFor="website">Website/Work</Label>
                      <Input
                        id="website"
                        name="website"
                        value={editFormData.website}
                        onChange={handleEditFormChange}
                      />
                    </div>
                  </div>
                  <div className="flex justify-end">
                    <Button onClick={handleProfileUpdate}>Save changes</Button>
                  </div>
                </DialogContent>
              </Dialog>
            </div>
          </div>
        </div>
        
        <div className="px-4">
          <h1 className="text-2xl font-bold mt-4">{fullName}</h1>
          <p className="text-muted-foreground">@{profileData.username}</p>
          
          {profileData.about && <p className="my-4">{profileData.about}</p>}
          
          <div className="flex flex-wrap gap-x-4 gap-y-2 text-sm text-muted-foreground mb-4">
            {profileData.livesIn && (
              <div className="flex items-center">
                <MapPin className="h-4 w-4 mr-1" />
                <span>{profileData.livesIn}</span>
              </div>
            )}
            {profileData.worksAt && (
              <div className="flex items-center">
                <Link2 className="h-4 w-4 mr-1" />
                <a href={`https://${profileData.worksAt}`} target="_blank" rel="noopener noreferrer" className="text-social-primary hover:underline">
                  {profileData.worksAt}
                </a>
              </div>
            )}
            <div className="flex items-center">
              <Calendar className="h-4 w-4 mr-1" />
              <span>Joined {new Date(profileData.createdAt).toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}</span>
            </div>
          </div>
          
          <div className="flex gap-4 mb-6">
            <a href="#" className="hover:underline">
              <span className="font-bold">{profileData.following?.length || 0}</span>
              <span className="text-muted-foreground"> Following</span>
            </a>
            <a href="#" className="hover:underline">
              <span className="font-bold">{profileData.followers?.length || 0}</span>
              <span className="text-muted-foreground"> Followers</span>
            </a>
          </div>
        </div>
        
        <Tabs defaultValue="posts" className="px-4">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="posts">Posts</TabsTrigger>
            <TabsTrigger value="media">Media</TabsTrigger>
            <TabsTrigger value="likes">Likes</TabsTrigger>
          </TabsList>
          <TabsContent value="posts" className="pt-6">
            <div className="space-y-6">
              {posts.length > 0 ? (
                posts.map((post) => (
                  <PostCard key={post._id} post={{
                    id: post._id,
                    author: {
                      name: fullName,
                      username: profileData.username,
                      avatar: profilePicUrl,
                    },
                    createdAt: new Date(post.createdAt).toLocaleDateString(),
                    content: post.desc,
                    image: post.image ? `http://localhost:4000/images/${post.image}` : undefined,
                    likes: post.likes?.length || 0,
                    comments: 0,
                    shares: 0,
                  }} />
                ))
              ) : (
                <div className="text-center py-12 text-muted-foreground">
                  No posts to show
                </div>
              )}
            </div>
          </TabsContent>
          <TabsContent value="media">
            <div className="pt-6 grid grid-cols-2 sm:grid-cols-3 gap-2">
              {posts
                .filter((post) => post.image)
                .map((post) => (
                  <a key={post._id} href={`/post/${post._id}`} className="aspect-square bg-muted rounded-md overflow-hidden">
                    <img 
                      src={`http://localhost:4000/images/${post.image}`} 
                      alt="" 
                      className="w-full h-full object-cover hover:scale-105 transition-transform" 
                    />
                  </a>
                ))}
            </div>
          </TabsContent>
          <TabsContent value="likes">
            <div className="pt-6 text-center py-12 text-muted-foreground">
              No liked posts to show
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </>
  );
}
