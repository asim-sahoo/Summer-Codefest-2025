
import { useState } from "react";
import { Avatar } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Heart, Reply, User } from "lucide-react";
import { useToast } from "@/components/ui/use-toast";

interface Comment {
  id: string;
  author: {
    name: string;
    username: string;
    avatar?: string;
  };
  content: string;
  createdAt: string;
  likes: number;
  liked?: boolean;
}

interface CommentSectionProps {
  comments: Comment[];
  postId: string;
}

export function CommentSection({ comments, postId }: CommentSectionProps) {
  const [commentText, setCommentText] = useState("");
  const [commentsList, setCommentsList] = useState(comments);
  const { toast } = useToast();

  const handleSubmitComment = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!commentText.trim()) return;

    // Add new comment
    const newComment: Comment = {
      id: Date.now().toString(),
      author: {
        name: "Current User",
        username: "currentuser",
      },
      content: commentText,
      createdAt: "Just now",
      likes: 0,
      liked: false,
    };

    setCommentsList([newComment, ...commentsList]);
    setCommentText("");

    toast({
      description: "Comment added",
      duration: 1500,
    });
  };

  const handleLikeComment = (commentId: string) => {
    setCommentsList(
      commentsList.map((comment) => {
        if (comment.id === commentId) {
          return {
            ...comment,
            liked: !comment.liked,
            likes: comment.liked ? comment.likes - 1 : comment.likes + 1,
          };
        }
        return comment;
      })
    );
  };

  return (
    <div className="space-y-4">
      <form onSubmit={handleSubmitComment} className="flex gap-3 mb-6">
        <Avatar className="h-8 w-8 border">
          <div className="flex h-full w-full items-center justify-center bg-muted">
            <User className="h-4 w-4 text-muted-foreground" />
          </div>
        </Avatar>
        <div className="flex-1 relative">
          <textarea
            placeholder="Write a comment..."
            value={commentText}
            onChange={(e) => setCommentText(e.target.value)}
            className="w-full resize-none rounded-lg border p-2 min-h-[80px] pr-20"
            rows={3}
          />
          <Button 
            type="submit" 
            disabled={!commentText.trim()} 
            className="absolute bottom-2 right-2 bg-social-primary hover:bg-social-primary/90"
            size="sm"
          >
            Comment
          </Button>
        </div>
      </form>
      
      <div className="space-y-6">
        {commentsList.map((comment) => (
          <div key={comment.id} className="flex gap-3">
            <Avatar className="h-8 w-8 border">
              {comment.author.avatar ? (
                <img src={comment.author.avatar} alt={comment.author.name} />
              ) : (
                <div className="flex h-full w-full items-center justify-center bg-muted">
                  <User className="h-4 w-4 text-muted-foreground" />
                </div>
              )}
            </Avatar>
            <div className="flex-1">
              <div className="bg-muted rounded-lg p-3">
                <div className="flex items-center gap-2 mb-1">
                  <span className="font-medium">{comment.author.name}</span>
                  <span className="text-xs text-muted-foreground">@{comment.author.username}</span>
                </div>
                <p className="text-sm whitespace-pre-wrap">{comment.content}</p>
              </div>
              <div className="flex items-center gap-4 mt-1 ml-2">
                <button
                  className="text-xs flex items-center gap-1 text-muted-foreground hover:text-social-primary"
                  onClick={() => handleLikeComment(comment.id)}
                >
                  <Heart className={`h-3 w-3 ${comment.liked ? 'fill-red-500 text-red-500' : ''}`} />
                  {comment.likes > 0 && <span>{comment.likes}</span>}
                </button>
                <button className="text-xs flex items-center gap-1 text-muted-foreground hover:text-social-primary">
                  <Reply className="h-3 w-3" />
                  Reply
                </button>
                <span className="text-xs text-muted-foreground">{comment.createdAt}</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
