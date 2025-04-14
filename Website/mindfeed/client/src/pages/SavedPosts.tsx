import { useState, useEffect } from "react";
import { getSavedPosts } from "@/lib/api";
import { useAuth } from "@/lib/AuthContext";
import { PostCard } from "@/components/post/PostCard";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Loader2 } from "lucide-react";

export default function SavedPosts() {
  const [savedPosts, setSavedPosts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { user } = useAuth();

  useEffect(() => {
    const fetchSavedPosts = async () => {
      if (!user) return;
      
      try {
        setLoading(true);
        
        // Get saved post IDs from localStorage
        const savedPostIds = JSON.parse(localStorage.getItem('wellsta_saved_posts') || '[]');
        
        // If we have local saved posts, try to get their details
        if (savedPostIds.length > 0) {
          // For local posts, we can get them from localStorage
          const localPosts = JSON.parse(localStorage.getItem('wellsta_local_posts') || '[]');
          
          // Filter local posts to only include saved ones
          const filteredLocalPosts = localPosts.filter((post: any) => 
            savedPostIds.includes(post._id)
          );
          
          // Transform local posts to match the PostCard format
          const formattedLocalPosts = filteredLocalPosts.map((post: any) => ({
            id: post._id,
            userId: post.userId,
            author: {
              name: post.author?.name || 'Unknown User',
              username: post.author?.username || 'unknown',
              avatar: post.author?.avatar
            },
            createdAt: post.createdAt,
            content: post.content,
            images: post.images,
            voiceNote: post.voiceNote,
            location: post.location,
            emoji: post.emoji,
            likes: post.likes?.length || 0,
            comments: post.comments?.length || 0,
            shares: 0,
            liked: post.likes?.includes(user._id) || false,
            saved: true // Since this is in saved posts
          }));
          
          // Try to get API posts as well
          try {
            const apiPosts = await getSavedPosts(user._id);
            
            // Combine local and API posts
            const combinedPosts = [...formattedLocalPosts, ...apiPosts];
            setSavedPosts(combinedPosts);
          } catch (apiError) {
            console.error("Error fetching saved posts from API:", apiError);
            // If API fails, just use local posts
            setSavedPosts(formattedLocalPosts);
          }
        } else {
          // If no local saved posts, try API
          try {
            const apiPosts = await getSavedPosts(user._id);
            setSavedPosts(apiPosts);
          } catch (apiError) {
            console.error("Error fetching saved posts from API:", apiError);
            setSavedPosts([]);
          }
        }
      } catch (error) {
        console.error("Error fetching saved posts:", error);
        setError("Failed to load saved posts. Please try again later.");
      } finally {
        setLoading(false);
      }
    };

    fetchSavedPosts();
  }, [user]);

  const handlePostDeleted = (postId: string) => {
    setSavedPosts(savedPosts.filter(post => post.id !== postId));
  };

  const handlePostUpdated = () => {
    // Refresh saved posts when a post is updated
    if (user) {
      getSavedPosts(user._id)
        .then(posts => setSavedPosts(posts))
        .catch(error => console.error("Error refreshing saved posts:", error));
    }
  };

  // Function to handle when a post is unsaved from the saved posts page
  const handlePostUnsaved = (postId: string) => {
    setSavedPosts(savedPosts.filter(post => post.id !== postId));
  };

  return (
    <div className="container mx-auto py-6 max-w-3xl">
      <h1 className="text-3xl font-bold mb-6">Saved Posts</h1>
      
      {loading ? (
        <Card className="w-full flex items-center justify-center p-8">
          <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
        </Card>
      ) : error ? (
        <Card className="w-full">
          <CardContent className="p-6">
            <p className="text-red-500">{error}</p>
          </CardContent>
        </Card>
      ) : savedPosts.length === 0 ? (
        <Card className="w-full">
          <CardHeader>
            <CardTitle>No Saved Posts</CardTitle>
            <CardDescription>
              You haven't saved any posts yet. When you find content you want to revisit later, tap the bookmark icon to save it here.
            </CardDescription>
          </CardHeader>
        </Card>
      ) : (
        <div className="space-y-6">
          {savedPosts.map((post) => (
            <PostCard 
              key={post.id} 
              post={{...post, saved: true}} 
              onPostDeleted={() => handlePostDeleted(post.id)}
              onPostUpdated={handlePostUpdated}
            />
          ))}
        </div>
      )}
    </div>
  );
}
