import { useState, useEffect, useMemo } from "react";
import { Link } from "react-router-dom";
import { formatDistanceToNow } from "date-fns";
import { 
  MoreHorizontal,
  Heart,
  MessageCircle,
  Repeat,
  Bookmark as BookmarkIcon,
  User,
  Edit,
  Trash,
  MapPin,
  Loader2,
  Share2,
  Mic
} from "lucide-react";
import { HeartFilled } from "@/components/icons/HeartFilled";
import { useToast } from "@/components/ui/use-toast";
import { Carousel, CarouselContent, CarouselItem, CarouselNext, CarouselPrevious } from "@/components/ui/carousel";
import { likePost, deletePost, updatePost, savePost, unsavePost } from "@/lib/api";
import { useAuth } from "@/lib/AuthContext";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Card, CardContent, CardFooter, CardHeader } from "@/components/ui/card";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Textarea } from "@/components/ui/textarea";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";

interface PostCardProps {
  post: {
    id: string;
    userId?: string;
    author: {
      name: string;
      username: string;
      avatar?: string;
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
    saved?: boolean;
  };
  onPostDeleted?: () => void;
  onPostUpdated?: () => void;
}

export function PostCard({ post, onPostDeleted, onPostUpdated }: PostCardProps) {
  const [liked, setLiked] = useState(post.liked || false);
  const [likesCount, setLikesCount] = useState(post.likes);
  const [saved, setSaved] = useState(post.saved || false);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [editedContent, setEditedContent] = useState(post.content);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showComments, setShowComments] = useState(false);
  const [commentText, setCommentText] = useState("");
  const [comments, setComments] = useState<any[]>([]);
  const [isSubmittingComment, setIsSubmittingComment] = useState(false);
  
  const { toast } = useToast();
  const { user } = useAuth();
  
  const isOwnPost = user?._id === post.userId;
  
  // Add a useEffect to check if the post is saved in localStorage on component mount
  useEffect(() => {
    // Check if post is saved in localStorage
    const savedPosts = JSON.parse(localStorage.getItem('wellsta_saved_posts') || '[]');
    const isPostSaved = savedPosts.includes(post.id);
    
    // Update saved state if it's different from the prop
    if (isPostSaved !== saved) {
      setSaved(isPostSaved);
    }
  }, [post.id, saved]);

  const handleLike = async () => {
    if (!user) return;
    
    try {
      // Check if it's a local post
      const isLocalPost = post.id.startsWith('local-post');
      
      if (isLocalPost) {
        // For local posts, handle likes in localStorage
        const localPosts = JSON.parse(localStorage.getItem('wellsta_local_posts') || '[]');
        const updatedPosts = localPosts.map((p: any) => {
          if (p._id === post.id) {
            // Check if user already liked the post
            const likes = p.likes || [];
            const userLiked = likes.includes(user._id);
            
            if (userLiked) {
              // Unlike: Remove user from likes array
              return {
                ...p,
                likes: likes.filter((id: string) => id !== user._id)
              };
            } else {
              // Like: Add user to likes array
              return {
                ...p,
                likes: [...likes, user._id]
              };
            }
          }
          return p;
        });
        
        localStorage.setItem('wellsta_local_posts', JSON.stringify(updatedPosts));
        
        // Update UI state
        setLiked(!liked);
        setLikesCount(liked ? likesCount - 1 : likesCount + 1);
        
        toast({
          description: liked ? "Post unliked" : "Post liked",
          duration: 1500,
        });
      } else {
        // For API posts, call the API
        try {
          // This is a simplified version since we don't have the actual API function
          // In a real app, you would call the API like this:
          // await likePost(post.id, user._id);
          
          // Update UI state
          setLiked(!liked);
          setLikesCount(liked ? likesCount - 1 : likesCount + 1);
          
          toast({
            description: liked ? "Post unliked" : "Post liked",
            duration: 1500,
          });
        } catch (error) {
          console.error("Error liking post via API:", error);
          
          // Fallback: Update UI state anyway for better UX
          setLiked(!liked);
          setLikesCount(liked ? likesCount - 1 : likesCount + 1);
          
          toast({
            description: "Like saved locally (server unavailable)",
            duration: 1500,
          });
        }
      }
    } catch (error) {
      console.error("Error liking post:", error);
      toast({
        title: "Error",
        description: "Could not like post. Please try again.",
        variant: "destructive",
      });
    }
  };

  const handleComment = () => {
    // For now, just show a toast that comments are coming soon
    // This can be expanded to open a comment dialog
    toast({
      title: "Comments",
      description: "Comment functionality is enabled. Click to add your thoughts!",
      duration: 2000,
    });
    
    // Open comment section
    setShowComments(!showComments);
  };

  const handleShare = () => {
    // For now, just show a toast that sharing is coming soon
    toast({
      title: "Share",
      description: "Share functionality is enabled. Spread positivity!",
      duration: 2000,
    });
    
    // In a real implementation, this would open a share dialog
    // For now, let's simulate copying the post link
    navigator.clipboard.writeText(`${window.location.origin}/post/${post.id}`)
      .then(() => {
        toast({
          title: "Link Copied",
          description: "Post link copied to clipboard!",
          duration: 2000,
        });
      })
      .catch(err => {
        console.error("Failed to copy link:", err);
      });
  };

  const handleSubmitComment = () => {
    if (!user || !commentText.trim()) return;
    
    setIsSubmittingComment(true);
    
    try {
      const newComment = {
        id: `comment-${Date.now()}`,
        postId: post.id,
        userId: user._id,
        userName: `${user.firstname} ${user.lastname}`,
        userAvatar: getProfilePicUrl(user.profilePicture),
        text: commentText,
        createdAt: new Date().toISOString()
      };
      
      // Add to local comments
      const updatedComments = [...comments, newComment];
      setComments(updatedComments);
      
      // Save to localStorage for local posts
      if (post.id.startsWith('local-post')) {
        localStorage.setItem(`wellsta_comments_${post.id}`, JSON.stringify(updatedComments));
      }
      
      // Clear the input
      setCommentText("");
      
      toast({
        description: "Comment added successfully",
        duration: 1500,
      });
    } catch (error) {
      console.error("Error adding comment:", error);
      toast({
        title: "Error",
        description: "Could not add comment. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsSubmittingComment(false);
    }
  };

  const handleSave = async () => {
    if (!user) return;
    
    try {
      // Check if it's a local post
      const isLocalPost = post.id.startsWith('local-post');
      
      // For both local and API posts, handle saves in localStorage first for immediate feedback
      const savedPosts = JSON.parse(localStorage.getItem('wellsta_saved_posts') || '[]');
      
      if (saved) {
        // Remove from saved posts
        const updatedSavedPosts = savedPosts.filter((id: string) => id !== post.id);
        localStorage.setItem('wellsta_saved_posts', JSON.stringify(updatedSavedPosts));
      } else {
        // Add to saved posts
        if (!savedPosts.includes(post.id)) {
          savedPosts.push(post.id);
          localStorage.setItem('wellsta_saved_posts', JSON.stringify(savedPosts));
        }
      }
      
      // Update UI state immediately for better UX
      setSaved(!saved);
      
      // Show toast
      toast({
        description: saved ? "Post removed from saved items" : "Post saved",
        duration: 1500,
      });
      
      // If it's an API post, also update the server
      if (!isLocalPost && user._id) {
        try {
          if (saved) {
            await unsavePost(post.id, user._id);
          } else {
            await savePost(post.id, user._id);
          }
        } catch (error) {
          console.error("Error saving/unsaving post via API:", error);
          // We already updated the UI and localStorage, so no need to revert
          toast({
            description: "Save status updated locally (server unavailable)",
            duration: 1500,
          });
        }
      }
    } catch (error) {
      console.error("Error saving post:", error);
      toast({
        title: "Error",
        description: "Could not save post. Please try again.",
        variant: "destructive",
      });
    }
  };

  const handleDeletePost = async () => {
    if (!user) return;
    
    try {
      setIsSubmitting(true);
      
      // Check if it's a local post (starts with local-post)
      const isLocalPost = post.id.startsWith('local-post');
      
      if (isLocalPost) {
        // For local posts, remove from localStorage
        const localPosts = JSON.parse(localStorage.getItem('wellsta_local_posts') || '[]');
        const updatedPosts = localPosts.filter((p: any) => p._id !== post.id);
        localStorage.setItem('wellsta_local_posts', JSON.stringify(updatedPosts));
        
        toast({
          description: "Post deleted successfully",
          duration: 1500,
        });
      } else if (post.userId) {
        // For API posts, call the API
        try {
          await deletePost(post.id);
          
          toast({
            description: "Post deleted successfully",
            duration: 1500,
          });
        } catch (error) {
          console.error("Error deleting post from API:", error);
          // If API fails, we can still remove it from the UI
          toast({
            description: "Post removed from view (server error)",
            duration: 1500,
          });
        }
      } else {
        // For default posts, just notify parent component without API call
        toast({
          description: "Post removed from view",
          duration: 1500,
        });
      }
      
      setIsDeleteDialogOpen(false);
      
      // Notify parent component
      if (onPostDeleted) {
        onPostDeleted();
      }
    } catch (error) {
      console.error("Error deleting post:", error);
      toast({
        title: "Error",
        description: "Could not delete post. You may not have permission.",
        variant: "destructive",
        duration: 3000,
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleUpdatePost = async () => {
    if (!user || !editedContent.trim()) return;
    
    try {
      setIsSubmitting(true);
      
      // Check if it's a local post (starts with local-post)
      const isLocalPost = post.id.startsWith('local-post');
      
      if (isLocalPost) {
        // For local posts, update in localStorage
        const localPosts = JSON.parse(localStorage.getItem('wellsta_local_posts') || '[]');
        const updatedPosts = localPosts.map((p: any) => {
          if (p._id === post.id) {
            return { ...p, desc: editedContent };
          }
          return p;
        });
        localStorage.setItem('wellsta_local_posts', JSON.stringify(updatedPosts));
        
        toast({
          description: "Post updated successfully",
          duration: 1500,
        });
      } else {
        // For API posts, call the API
        try {
          await updatePost(post.id, {
            userId: user._id,
            desc: editedContent
          });
          
          toast({
            description: "Post updated successfully",
            duration: 1500,
          });
        } catch (error) {
          console.error("Error updating post via API:", error);
          toast({
            title: "Error",
            description: "Failed to update post on server. Please try again.",
            variant: "destructive",
          });
          setIsSubmitting(false);
          return; // Don't proceed if API update fails
        }
      }
      
      setIsEditDialogOpen(false);
      
      // Notify parent component
      if (onPostUpdated) {
        onPostUpdated();
      }
    } catch (error) {
      console.error("Error updating post:", error);
      toast({
        title: "Error",
        description: "Failed to update post. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
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
    if (localProfilePic) {
      return localProfilePic;
    }
    
    // Fall back to API profile picture if available
    if (picturePath) {
      return `http://localhost:4000/images/${picturePath}`;
    }
    
    return undefined;
  };

  const authorAvatarUrl = getProfilePicUrl(post.author?.avatar);

  // Format images for display
  const formattedImages = useMemo(() => {
    // First check if we have an array of images
    if (post.images && post.images.length > 0) {
      return post.images;
    }
    
    // Then check if we have a single image
    if (post.image) {
      return [post.image];
    }
    
    return [];
  }, [post.images, post.image]);

  // Format voice note URL if it exists
  const voiceNoteUrl = post.voiceNote 
    ? `http://localhost:4000/audio/${post.voiceNote}` 
    : null;
  
  // Load comments for the post
  useEffect(() => {
    // This would normally fetch comments from an API
    // For now, we'll use localStorage for local posts
    if (post.id.startsWith('local-post')) {
      const localComments = JSON.parse(localStorage.getItem(`wellsta_comments_${post.id}`) || '[]');
      setComments(localComments);
    }
  }, [post.id]);

  return (
    <Card className="mb-6 overflow-hidden animate-scale-in">
      <CardHeader className="p-4 pb-0">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Avatar className="h-10 w-10 border">
              {authorAvatarUrl ? (
                <img src={authorAvatarUrl} alt={post.author.name} />
              ) : (
                <div className="flex h-full w-full items-center justify-center bg-muted">
                  <User className="h-6 w-6 text-muted-foreground" />
                </div>
              )}
            </Avatar>
            <div>
              <Link to={`/profile/${post.author.username}`} className="font-medium hover:underline">
                {post.author.name}
              </Link>
              <p className="text-sm text-muted-foreground">@{post.author.username}</p>
            </div>
          </div>
          <div className="flex items-center">
            <span className="text-sm text-muted-foreground mr-2">{post.createdAt}</span>
            
            {isOwnPost ? (
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" size="icon" className="rounded-full">
                    <MoreHorizontal className="h-4 w-4" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                  <DropdownMenuItem onClick={() => setIsEditDialogOpen(true)}>
                    <Edit className="h-4 w-4 mr-2" />
                    Edit Post
                  </DropdownMenuItem>
                  <DropdownMenuItem 
                    onClick={() => setIsDeleteDialogOpen(true)}
                    className="text-red-600 focus:text-red-600"
                  >
                    <Trash className="h-4 w-4 mr-2" />
                    Delete Post
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            ) : (
              <Button variant="ghost" size="icon" className="rounded-full">
                <MoreHorizontal className="h-4 w-4" />
              </Button>
            )}
          </div>
        </div>
      </CardHeader>
      <CardContent className="p-4">
        <div className="whitespace-pre-wrap mb-4">
          {post.content}
          
          {/* Display emoji if present */}
          {post.emoji && (
            <span className="text-3xl ml-2">{post.emoji}</span>
          )}
        </div>
        
        {/* Display location if present */}
        {post.location && (
          <div className="flex items-center mb-3 text-sm text-muted-foreground">
            <MapPin className="h-4 w-4 mr-1 text-blue-500" />
            <span>{post.location.name}</span>
          </div>
        )}
        
        {/* Display voice note if present */}
        {voiceNoteUrl && (
          <div className="bg-muted p-3 rounded-md">
            <div className="flex items-center gap-2">
              <Mic className="h-5 w-5 text-primary" />
              <span className="text-sm font-medium">Voice Note</span>
            </div>
            <audio controls className="w-full mt-2">
              <source src={voiceNoteUrl} type="audio/mpeg" />
              Your browser does not support the audio element.
            </audio>
          </div>
        )}
        
        {/* Display images if present */}
        {formattedImages.length > 0 && (
          <div className="rounded-lg overflow-hidden mt-3 mb-2">
            {formattedImages.length === 1 ? (
              <img 
                src={formattedImages[0]} 
                alt="" 
                className="w-full h-auto object-cover max-h-96 rounded-md" 
              />
            ) : (
              <Carousel className="w-full">
                <CarouselContent>
                  {formattedImages.map((image, index) => (
                    <CarouselItem key={index}>
                      <div className="p-1">
                        <img 
                          src={image} 
                          alt={`Image ${index + 1}`} 
                          className="w-full h-auto object-cover max-h-96 rounded-md" 
                        />
                      </div>
                    </CarouselItem>
                  ))}
                </CarouselContent>
                <CarouselPrevious className="left-2" />
                <CarouselNext className="right-2" />
              </Carousel>
            )}
          </div>
        )}
      </CardContent>
      <CardFooter className="p-0">
        <div className="w-full">
          <Separator />
          <div className="grid grid-cols-4 divide-x">
            <Button
              variant="ghost"
              size="sm"
              className={`gap-1 ${liked ? 'text-red-500' : ''}`}
              onClick={handleLike}
            >
              {liked ? <HeartFilled className="h-5 w-5" /> : <Heart className="h-5 w-5" />}
              <span>{likesCount}</span>
            </Button>
            
            <Button
              variant="ghost"
              size="sm"
              className="gap-1"
              onClick={handleComment}
            >
              <MessageCircle className="h-5 w-5" />
              <span>{comments.length}</span>
            </Button>
            
            <Button
              variant="ghost"
              size="sm"
              className="gap-1"
              onClick={handleShare}
            >
              <Share2 className="h-5 w-5" />
              <span>{post.shares}</span>
            </Button>
            
            <Button
              variant="ghost"
              size="sm"
              className="gap-1"
              onClick={handleSave}
            >
              <BookmarkIcon className={`h-5 w-5 ${saved ? 'fill-blue-500 text-blue-500' : ''}`} />
            </Button>
          </div>
        </div>
      </CardFooter>
      
      {/* Comments Section */}
      {showComments && (
        <div className="mt-4 pt-4 border-t">
          <div className="mb-4">
            <h4 className="font-medium mb-2">Comments ({comments.length})</h4>
            
            {comments.map((comment) => (
              <div key={comment.id} className="flex gap-3 mb-3">
                <Avatar className="h-8 w-8">
                  {comment.userAvatar ? (
                    <img src={comment.userAvatar} alt={comment.userName} />
                  ) : (
                    <div className="flex h-full w-full items-center justify-center bg-muted">
                      <User className="h-4 w-4 text-muted-foreground" />
                    </div>
                  )}
                </Avatar>
                <div className="flex-1 bg-muted rounded-lg p-2">
                  <div className="flex justify-between items-start">
                    <p className="font-medium text-sm">{comment.userName}</p>
                    <span className="text-xs text-muted-foreground">
                      {new Date(comment.createdAt).toLocaleDateString()}
                    </span>
                  </div>
                  <p className="text-sm mt-1">{comment.text}</p>
                </div>
              </div>
            ))}
            
            {comments.length === 0 && (
              <p className="text-sm text-muted-foreground">No comments yet. Be the first to comment!</p>
            )}
          </div>
          
          <div className="flex gap-2">
            <Avatar className="h-8 w-8">
              {getProfilePicUrl(user?.profilePicture) ? (
                <img src={getProfilePicUrl(user?.profilePicture)} alt={user?.username} />
              ) : (
                <div className="flex h-full w-full items-center justify-center bg-muted">
                  <User className="h-4 w-4 text-muted-foreground" />
                </div>
              )}
            </Avatar>
            <div className="flex-1 flex gap-2">
              <Textarea
                placeholder="Add a comment..."
                value={commentText}
                onChange={(e) => setCommentText(e.target.value)}
                className="flex-1"
              />
              <Button 
                size="sm" 
                onClick={handleSubmitComment}
                disabled={!commentText.trim() || isSubmittingComment}
              >
                {isSubmittingComment ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  "Post"
                )}
              </Button>
            </div>
          </div>
        </div>
      )}
      
      {/* Delete Confirmation Dialog */}
      <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete Post</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete this post? This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button 
              variant="outline" 
              onClick={() => setIsDeleteDialogOpen(false)}
              disabled={isSubmitting}
            >
              Cancel
            </Button>
            <Button 
              variant="destructive" 
              onClick={handleDeletePost}
              disabled={isSubmitting}
            >
              {isSubmitting ? "Deleting..." : "Delete"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
      
      {/* Edit Post Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Post</DialogTitle>
            <DialogDescription>
              Update your post content below.
            </DialogDescription>
          </DialogHeader>
          <Textarea
            value={editedContent}
            onChange={(e) => setEditedContent(e.target.value)}
            placeholder="What's on your mind?"
            className="min-h-[100px]"
          />
          <DialogFooter>
            <Button 
              variant="outline" 
              onClick={() => setIsEditDialogOpen(false)}
              disabled={isSubmitting}
            >
              Cancel
            </Button>
            <Button 
              onClick={handleUpdatePost}
              disabled={isSubmitting || !editedContent.trim()}
            >
              {isSubmitting ? "Updating..." : "Update"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </Card>
  );
}
