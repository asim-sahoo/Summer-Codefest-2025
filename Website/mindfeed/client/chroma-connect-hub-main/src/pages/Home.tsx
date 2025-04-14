import { useState, useEffect } from "react";
import { CreatePostCard } from "@/components/post/CreatePostCard";
import { PostCard } from "@/components/post/PostCard";
import { useAuth } from "@/lib/AuthContext";
import { getTimelinePosts, getUser } from "@/lib/api";
import { useToast } from "@/components/ui/use-toast";
import TimeSpentTracker from "@/components/TimeSpentTracker";
import WellnessTips from "@/components/WellnessTips";
import MentalHealthNudge from "@/components/MentalHealthNudge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Sparkles, BrainCircuit, Users, BookmarkIcon } from "lucide-react";
import WellnessDashboard from "@/components/wellness/WellnessDashboard";
import MindfulnessExercise from "@/components/wellness/MindfulnessExercise";
import JournalingTool from "@/components/wellness/JournalingTool";
import BreathingExercise from "@/components/wellness/BreathingExercise";
import MoodCheck from "@/components/wellness/MoodCheck";
import { defaultPosts, DefaultPost } from "@/data/defaultPosts";
import { staticCodingPosts } from "@/data/staticPosts";

interface Post {
  _id: string;
  userId: string;
  desc: string;
  image?: string;
  images?: string[];
  voiceNote?: string;
  location?: {
    name: string;
    coordinates: {
      latitude: number;
      longitude: number;
    };
  };
  emoji?: string;
  likes: string[];
  createdAt: string;
}

interface UserProfile {
  firstname?: string;
  lastname?: string;
  username?: string;
  profilePicture?: string;
}

interface FormattedPost {
  id: string;
  userId: string;
  author: {
    name: string;
    username: string;
    avatar: string;
  };
  createdAt: string;
  content: string;
  image?: string;
  images?: string[];
  voiceNote?: string;
  location?: {
    name: string;
    coordinates: {
      latitude: number;
      longitude: number;
    };
  };
  emoji?: string;
  likes: number;
  comments: number;
  shares: number;
  liked?: boolean;
}

export default function Home() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [userProfiles, setUserProfiles] = useState<Record<string, UserProfile>>({});
  const [activeWellnessFeature, setActiveWellnessFeature] = useState<string | null>(null);
  const { user } = useAuth();
  const { toast } = useToast();

  const fetchPosts = async () => {
    if (!user) return;
    
    try {
      setLoading(true);
      
      // Get posts from local storage
      const localPosts = JSON.parse(localStorage.getItem('wellsta_local_posts') || '[]');
      
      // Try to get posts from API (this might fail, but we'll still have local posts)
      let apiPosts: Post[] = [];
      try {
        apiPosts = await getTimelinePosts(user._id) as Post[];
      } catch (error) {
        console.error("Error fetching posts from API:", error);
        // Continue with local posts only
      }
      
      // Combine local and API posts
      const allPosts = [...localPosts, ...apiPosts];
      setPosts(allPosts);
      
      // Fetch user profiles for each post
      const userIds = [...new Set(allPosts.map((post: Post) => post.userId))];
      const profiles: Record<string, UserProfile> = {};
      
      for (const userId of userIds) {
        try {
          // For local posts, we might not have real user IDs
          if (userId && !userId.startsWith('local-')) {
            const userData = await getUser(userId) as UserProfile;
            profiles[userId] = userData;
          }
        } catch (error) {
          console.error(`Error fetching user ${userId}:`, error);
        }
      }
      
      // Add current user to profiles
      if (user) {
        profiles[user._id] = {
          firstname: user.firstname,
          lastname: user.lastname,
          username: user.username,
          profilePicture: user.profilePicture
        };
      }
      
      setUserProfiles(profiles);
    } catch (error) {
      console.error("Error fetching posts:", error);
      toast({
        title: "Error",
        description: "Could not load posts. Please try again later.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  // Get profile picture URL
  const getProfilePicUrl = (picturePath?: string) => {
    // First check if it's already a data URL
    if (picturePath && picturePath.startsWith('data:')) {
      return picturePath;
    }
    
    // Check for local storage profile picture
    const localProfilePic = localStorage.getItem('wellsta-profile-image');
    if (localProfilePic && user) {
      return localProfilePic;
    }
    
    // Fall back to API profile picture if available
    if (picturePath) {
      return `http://localhost:4000/images/${picturePath}`;
    }
    
    return undefined;
  };

  const formatPost = (post: any): FormattedPost => {
    // Handle static posts differently
    if (post.isStatic) {
      // Find the matching static post to get additional details
      const staticPost = staticCodingPosts.find(sp => sp._id === post._id);
      
      if (staticPost) {
        return {
          id: post._id,
          author: {
            name: `${staticPost.firstname} ${staticPost.lastname}`,
            username: staticPost.username,
            avatar: staticPost.profilePicture,
          },
          createdAt: new Date(post.createdAt).toLocaleDateString(),
          content: post.desc,
          images: post.images,
          likes: post.likes?.length || 0,
          comments: 0,
          shares: 0,
          userId: post.userId,
        };
      }
    }
    
    // For regular posts (API or local)
    const postAuthor = userProfiles[post.userId] || {};
    
    // For local posts, use the current user's info
    const isLocalPost = post._id && post._id.startsWith('local-post');
    const authorName = isLocalPost 
      ? (user ? `${user.firstname} ${user.lastname}` : 'Anonymous')
      : (postAuthor.firstname ? `${postAuthor.firstname} ${postAuthor.lastname}` : 'Unknown User');
    
    const hasLocalImage = post.image && post.image.startsWith('data:');
    
    // For profile pictures, use a default if not available
    const profilePic = getProfilePicUrl(postAuthor.profilePicture) 
      ? getProfilePicUrl(postAuthor.profilePicture)
      : "/logo.png";
    
    return {
      id: post._id,
      author: {
        name: authorName,
        username: isLocalPost ? (user?.username || 'user') : (postAuthor.username || 'user'),
        avatar: isLocalPost ? getProfilePicUrl(user?.profilePicture) : profilePic,
      },
      createdAt: new Date(post.createdAt).toLocaleDateString(),
      content: post.desc,
      image: hasLocalImage ? post.image : (post.image ? `http://localhost:4000/images/${post.image}` : undefined),
      images: post.images || [],
      voiceNote: post.voiceNote,
      location: post.location,
      emoji: post.emoji,
      likes: post.likes?.length || 0,
      comments: 0,
      shares: 0,
      userId: post.userId,
    };
  };

  const handlePostDeleted = (postId?: string) => {
    if (postId && postId.startsWith('local-')) {
      // Remove the post from local storage
      const localPosts = JSON.parse(localStorage.getItem('wellsta_local_posts') || '[]');
      const updatedPosts = localPosts.filter((post: Post) => post._id !== postId);
      localStorage.setItem('wellsta_local_posts', JSON.stringify(updatedPosts));
    }
    
    // Refresh posts
    fetchPosts();
  };

  const handlePostUpdated = () => {
    // Refresh posts
    fetchPosts();
  };

  useEffect(() => {
    fetchPosts();
  }, [user, toast]);

  const renderWellnessFeature = () => {
    switch (activeWellnessFeature) {
      case 'mindfulness':
        return <MindfulnessExercise />;
      case 'journaling':
        return <JournalingTool />;
      case 'breathing':
        return <BreathingExercise />;
      case 'mood':
        return <MoodCheck />;
      default:
        return null;
    }
  };

  const renderPosts = () => {
    if (loading) {
      return (
        <div className="space-y-4">
          {[1, 2, 3].map((i) => (
            <Card key={i} className="p-4 space-y-4">
              <div className="flex items-center space-x-2">
                <div className="h-10 w-10 rounded-full bg-gray-200"></div>
                <div className="space-y-2">
                  <div className="h-4 bg-gray-200 rounded w-24"></div>
                  <div className="h-3 bg-gray-200 rounded w-16"></div>
                </div>
              </div>
              <div className="space-y-2">
                <div className="h-4 bg-gray-200 rounded w-3/4"></div>
                <div className="h-4 bg-gray-200 rounded w-full"></div>
                <div className="h-4 bg-gray-200 rounded w-2/3"></div>
              </div>
              <div className="h-48 bg-gray-200 rounded mt-4"></div>
            </Card>
          ))}
        </div>
      );
    }

    // Local posts are already included in the posts state from the fetchPosts function
    const userPosts = posts;
    
    // Format static posts
    const formattedStaticPosts = staticCodingPosts.map(post => {
      return {
        _id: post._id,
        userId: post.userId,
        desc: post.desc,
        images: post.images,
        createdAt: post.createdAt,
        likes: post.likes,
        isStatic: true
      };
    });
    
    // Combine user posts and static posts
    // User posts go at the top, static posts at the bottom
    const allPosts = [...userPosts, ...formattedStaticPosts];
    
    if (allPosts.length === 0) {
      return (
        <div className="space-y-4">
          {defaultPosts.map((post: DefaultPost) => (
            <PostCard
              key={post.id}
              post={post as any}
              onPostDeleted={() => {}}
              onPostUpdated={() => {}}
            />
          ))}
        </div>
      );
    }

    return (
      <div className="space-y-4">
        {allPosts.map((post) => (
          <PostCard
            key={post._id}
            post={formatPost(post)}
            onPostDeleted={() => handlePostDeleted(post._id)}
            onPostUpdated={handlePostUpdated}
          />
        ))}
      </div>
    );
  };

  return (
    <div className="container mx-auto px-4 py-6">
      {/* Mental Health Nudge (will appear after specified time) */}
      <MentalHealthNudge breakAfterMinutes={30} />
      
      {/* App Header with new name */}
      <div className="mb-8 text-center">
        <div className="flex justify-center items-center">
          
          <h1 className="text-4xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600">
            WellSta
          </h1>
        </div>
        <p className="text-gray-600 mt-2">Nourish your mind, connect with purpose</p>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Left Sidebar */}
        <div className="hidden md:block space-y-6">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-lg flex items-center">
                <BrainCircuit className="h-5 w-5 mr-2 text-blue-500" />
                Mental Wellness
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <TimeSpentTracker />
              
              <div className="mt-4">
                <h3 className="font-medium text-gray-700 mb-2">Quick Actions</h3>
                <div className="grid grid-cols-2 gap-2">
                  <button 
                    className="p-2 bg-blue-50 hover:bg-blue-100 rounded-md text-blue-700 text-sm transition-colors"
                    onClick={() => setActiveWellnessFeature('mindfulness')}
                  >
                    Focus
                  </button>
                  <button 
                    className="p-2 bg-purple-50 hover:bg-purple-100 rounded-md text-purple-700 text-sm transition-colors"
                    onClick={() => setActiveWellnessFeature('journaling')}
                  >
                    Journaling
                  </button>
                  <button 
                    className="p-2 bg-green-50 hover:bg-green-100 rounded-md text-green-700 text-sm transition-colors"
                    onClick={() => setActiveWellnessFeature('breathing')}
                  >
                    Breathing
                  </button>
                  <button 
                    className="p-2 bg-amber-50 hover:bg-amber-100 rounded-md text-amber-700 text-sm transition-colors"
                    onClick={() => setActiveWellnessFeature('mood')}
                  >
                    Mood Check
                  </button>
                </div>
              </div>
            </CardContent>
          </Card>
          
          {activeWellnessFeature && (
            <Card className="overflow-hidden">
              <CardContent className="p-0">
                {renderWellnessFeature()}
              </CardContent>
            </Card>
          )}
          
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-lg flex items-center">
                <Users className="h-5 w-5 mr-2 text-blue-500" />
                Connections
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Friends</span>
                  <span className="text-sm text-gray-500">24</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Groups</span>
                  <span className="text-sm text-gray-500">8</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">Events</span>
                  <span className="text-sm text-gray-500">3</span>
                </div>
                <button className="w-full mt-2 text-sm text-blue-600 hover:text-blue-800">
                  Find more connections
                </button>
              </div>
            </CardContent>
          </Card>
        </div>
        
        {/* Main Content */}
        <div className="md:col-span-2 lg:col-span-1 space-y-6">
          <CreatePostCard onPostCreated={fetchPosts} />
          
          {renderPosts()}
        </div>
        
        {/* Right Sidebar */}
        <div className="hidden lg:block space-y-6">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-lg flex items-center">
                <Sparkles className="h-5 w-5 mr-2 text-blue-500" />
                Your WellBeing
              </CardTitle>
            </CardHeader>
            <CardContent>
              <WellnessTips />
              
              <div className="mt-6 p-3 bg-blue-50 rounded-lg">
                <h3 className="font-medium text-blue-700">Daily Challenge</h3>
                <p className="text-sm text-gray-600 mt-1">
                  Share one thing that made you smile today
                </p>
                <button className="mt-2 text-xs text-blue-600 hover:text-blue-800">
                  Accept Challenge
                </button>
              </div>
            </CardContent>
          </Card>
          
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-lg flex items-center">
                <BookmarkIcon className="h-5 w-5 mr-2 text-blue-500" />
                Saved Content
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="text-sm text-gray-600">
                  You have 5 saved posts
                </div>
                <button className="w-full text-sm text-blue-600 hover:text-blue-800">
                  View all saved content
                </button>
              </div>
            </CardContent>
          </Card>
          
          <div className="bg-gradient-to-r from-blue-500 to-purple-600 p-4 rounded-lg text-white shadow-md">
            <h3 className="font-medium">Premium Features</h3>
            <p className="text-sm mt-1 text-blue-100">
              Unlock advanced wellness tools and ad-free experience
            </p>
            <button className="mt-3 bg-white text-blue-600 px-3 py-1 rounded-full text-sm font-medium hover:bg-blue-50">
              Learn More
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
