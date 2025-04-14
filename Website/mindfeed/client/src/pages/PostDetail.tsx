
import { useParams } from "react-router-dom";
import { PostCard } from "@/components/post/PostCard";
import { CommentSection } from "@/components/post/CommentSection";
import { Button } from "@/components/ui/button";
import { ArrowLeft } from "lucide-react";

// Mock data
const post = {
  id: "1",
  author: {
    name: "Sarah Johnson",
    username: "sarahj",
    avatar: "https://i.pravatar.cc/150?img=1",
  },
  createdAt: "2h ago",
  content: "Just finished designing the new interface for our app! So excited to share it with everyone soon! 🎨 #UXDesign #ProductDesign",
  image: "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&q=80",
  likes: 42,
  comments: 12,
  shares: 5,
};

const comments = [
  {
    id: "c1",
    author: {
      name: "Marcus Lee",
      username: "marcuslee",
      avatar: "https://i.pravatar.cc/150?img=11",
    },
    content: "This looks amazing! Can't wait to see the final product.",
    createdAt: "1h ago",
    likes: 5,
    liked: false,
  },
  {
    id: "c2",
    author: {
      name: "Emily Chen",
      username: "emilychen",
      avatar: "https://i.pravatar.cc/150?img=5",
    },
    content: "Love the color scheme! What tools did you use for the design?",
    createdAt: "1h ago",
    likes: 3,
    liked: false,
  },
  {
    id: "c3",
    author: {
      name: "Alex Thompson",
      username: "alexthompson",
      avatar: "https://i.pravatar.cc/150?img=9",
    },
    content: "Great work as always! The attention to detail is impressive.",
    createdAt: "2h ago",
    likes: 8,
    liked: true,
  },
];

export default function PostDetail() {
  const { id } = useParams();
  
  // In a real app, fetch the post using the ID
  
  return (
    <div className="max-w-2xl mx-auto">
      <div className="mb-6 flex items-center">
        <Button variant="ghost" size="icon" onClick={() => window.history.back()} className="mr-2">
          <ArrowLeft className="h-5 w-5" />
        </Button>
        <h1 className="text-2xl font-bold">Post</h1>
      </div>
      
      <PostCard post={post} />
      
      <div className="mt-6">
        <h2 className="text-xl font-bold mb-4">Comments ({comments.length})</h2>
        <CommentSection comments={comments} postId={post.id} />
      </div>
    </div>
  );
}
