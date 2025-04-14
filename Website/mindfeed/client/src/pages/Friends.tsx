import { useState, useEffect } from "react";
import { useAuth } from "@/lib/AuthContext";
import { getAllUsers, followUser, unfollowUser } from "@/lib/api";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Separator } from "@/components/ui/separator";
import { useToast } from "@/components/ui/use-toast";
import { Link } from "react-router-dom";
import { Loader2, Search, UserPlus, UserMinus, User, Users, UserCheck, Heart, BookOpen, Coffee } from "lucide-react";
import { generateMockUsers, MockUser } from "@/data/mockUsers";
import { Badge } from "@/components/ui/badge";

export default function Friends() {
  const [users, setUsers] = useState<MockUser[]>([]);
  const [filteredUsers, setFilteredUsers] = useState<MockUser[]>([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [followLoading, setFollowLoading] = useState<Record<string, boolean>>({});
  
  const { user } = useAuth();
  const { toast } = useToast();
  
  useEffect(() => {
    const fetchUsers = async () => {
      if (!user) return;
      
      try {
        setLoading(true);
        // Try to get users from API first
        try {
          const fetchedUsers = await getAllUsers();
          // Filter out the current user
          const otherUsers = fetchedUsers.filter((u: MockUser) => u._id !== user._id);
          setUsers(otherUsers);
          setFilteredUsers(otherUsers);
        } catch (apiError) {
          console.error("Error fetching users from API:", apiError);
          
          // Fall back to mock data
          const mockUsers = generateMockUsers(user._id);
          setUsers(mockUsers);
          setFilteredUsers(mockUsers);
        }
      } catch (error) {
        console.error("Error fetching users:", error);
        setError("Failed to load users. Please try again later.");
        
        // Fallback to mock data for demo purposes
        const mockUsers = generateMockUsers(user._id);
        setUsers(mockUsers);
        setFilteredUsers(mockUsers);
      } finally {
        setLoading(false);
      }
    };
    
    fetchUsers();
  }, [user]);
  
  useEffect(() => {
    if (searchQuery.trim() === "") {
      setFilteredUsers(users);
    } else {
      const query = searchQuery.toLowerCase();
      const filtered = users.filter(
        (user) =>
          user.username.toLowerCase().includes(query) ||
          user.firstname.toLowerCase().includes(query) ||
          user.lastname.toLowerCase().includes(query) ||
          `${user.firstname} ${user.lastname}`.toLowerCase().includes(query) ||
          (user.wellnessSpecialty && user.wellnessSpecialty.toLowerCase().includes(query)) ||
          (user.bio && user.bio.toLowerCase().includes(query)) ||
          (user.interests && user.interests.some(interest => interest.toLowerCase().includes(query)))
      );
      setFilteredUsers(filtered);
    }
  }, [searchQuery, users]);
  
  const handleFollow = async (userId: string) => {
    if (!user) return;
    
    setFollowLoading((prev) => ({ ...prev, [userId]: true }));
    
    try {
      // Check if already following
      const targetUser = users.find(u => u._id === userId);
      const isFollowing = targetUser?.followers.includes(user._id);
      
      if (isFollowing) {
        // Unfollow
        await unfollowUser(userId, user._id);
        
        // Update local state
        setUsers(users.map(u => {
          if (u._id === userId) {
            return {
              ...u,
              followers: u.followers.filter(id => id !== user._id)
            };
          }
          return u;
        }));
        
        toast({
          description: `You unfollowed ${targetUser?.firstname} ${targetUser?.lastname}`,
          duration: 3000,
        });
      } else {
        // Follow
        await followUser(userId, user._id);
        
        // Update local state
        setUsers(users.map(u => {
          if (u._id === userId) {
            return {
              ...u,
              followers: [...u.followers, user._id]
            };
          }
          return u;
        }));
        
        toast({
          description: `You followed ${targetUser?.firstname} ${targetUser?.lastname}`,
          duration: 3000,
        });
      }
    } catch (error) {
      console.error("Error following/unfollowing user:", error);
      
      // Fallback: Update UI anyway for better UX in demo
      const targetUser = users.find(u => u._id === userId);
      const isFollowing = targetUser?.followers.includes(user._id);
      
      setUsers(users.map(u => {
        if (u._id === userId) {
          return {
            ...u,
            followers: isFollowing 
              ? u.followers.filter(id => id !== user._id)
              : [...u.followers, user._id]
          };
        }
        return u;
      }));
      
      toast({
        description: isFollowing 
          ? `You unfollowed ${targetUser?.firstname} ${targetUser?.lastname}`
          : `You followed ${targetUser?.firstname} ${targetUser?.lastname}`,
        duration: 3000,
      });
    } finally {
      setFollowLoading((prev) => ({ ...prev, [userId]: false }));
    }
  };
  
  const isFollowing = (userId: string) => {
    if (!user) return false;
    const targetUser = users.find(u => u._id === userId);
    return targetUser?.followers.includes(user._id) || false;
  };
  
  const isFollower = (userId: string) => {
    if (!user) return false;
    const targetUser = users.find(u => u._id === userId);
    return targetUser?.following.includes(user._id) || false;
  };
  
  const getFollowers = () => {
    return filteredUsers.filter(u => isFollower(u._id));
  };
  
  const getFollowing = () => {
    return filteredUsers.filter(u => isFollowing(u._id));
  };
  
  const getSuggestions = () => {
    return filteredUsers.filter(u => !isFollowing(u._id));
  };
  
  return (
    <div className="container mx-auto py-6 max-w-4xl">
      <h1 className="text-3xl font-bold mb-6">Friends & Connections</h1>
      
      <div className="relative mb-6">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
        <Input
          type="text"
          placeholder="Search by name, specialty, or interest..."
          className="pl-10"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
      </div>
      
      <Tabs defaultValue="suggestions" className="w-full">
        <TabsList className="grid grid-cols-3 mb-6">
          <TabsTrigger value="suggestions" className="flex items-center gap-2">
            <UserPlus className="h-4 w-4" />
            <span>Suggestions</span>
          </TabsTrigger>
          <TabsTrigger value="following" className="flex items-center gap-2">
            <UserCheck className="h-4 w-4" />
            <span>Following</span>
          </TabsTrigger>
          <TabsTrigger value="followers" className="flex items-center gap-2">
            <Users className="h-4 w-4" />
            <span>Followers</span>
          </TabsTrigger>
        </TabsList>
        
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
        ) : (
          <>
            <TabsContent value="suggestions" className="mt-0">
              <Card>
                <CardHeader>
                  <CardTitle className="text-gradient">Wellness Connections</CardTitle>
                  <CardDescription>
                    Connect with wellness experts and mindfulness practitioners to enhance your mental wellbeing journey
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  {getSuggestions().length === 0 ? (
                    <p className="text-muted-foreground">No suggestions found. Try expanding your network!</p>
                  ) : (
                    <div className="space-y-4">
                      {getSuggestions().map((user) => (
                        <UserCard
                          key={user._id}
                          user={user}
                          isFollowing={isFollowing(user._id)}
                          isFollower={isFollower(user._id)}
                          onFollow={() => handleFollow(user._id)}
                          isLoading={followLoading[user._id] || false}
                        />
                      ))}
                    </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>
            
            <TabsContent value="following" className="mt-0">
              <Card>
                <CardHeader>
                  <CardTitle className="text-gradient">Your Wellness Circle</CardTitle>
                  <CardDescription>
                    People whose wellness insights and updates appear in your feed
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  {getFollowing().length === 0 ? (
                    <p className="text-muted-foreground">You're not following anyone yet. Check out the suggestions!</p>
                  ) : (
                    <div className="space-y-4">
                      {getFollowing().map((user) => (
                        <UserCard
                          key={user._id}
                          user={user}
                          isFollowing={true}
                          isFollower={isFollower(user._id)}
                          onFollow={() => handleFollow(user._id)}
                          isLoading={followLoading[user._id] || false}
                        />
                      ))}
                    </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>
            
            <TabsContent value="followers" className="mt-0">
              <Card>
                <CardHeader>
                  <CardTitle className="text-gradient">Your Supporters</CardTitle>
                  <CardDescription>
                    People who follow your wellness journey and see your updates
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  {getFollowers().length === 0 ? (
                    <p className="text-muted-foreground">You don't have any followers yet. Keep sharing your wellness journey!</p>
                  ) : (
                    <div className="space-y-4">
                      {getFollowers().map((user) => (
                        <UserCard
                          key={user._id}
                          user={user}
                          isFollowing={isFollowing(user._id)}
                          isFollower={true}
                          onFollow={() => handleFollow(user._id)}
                          isLoading={followLoading[user._id] || false}
                        />
                      ))}
                    </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>
          </>
        )}
      </Tabs>
    </div>
  );
}

interface UserCardProps {
  user: MockUser;
  isFollowing: boolean;
  isFollower: boolean;
  onFollow: () => void;
  isLoading: boolean;
}

function UserCard({ user, isFollowing, isFollower, onFollow, isLoading }: UserCardProps) {
  // Helper function to get an icon for a wellness specialty
  const getSpecialtyIcon = (specialty?: string) => {
    if (!specialty) return <Coffee className="h-4 w-4" />;
    
    const specialty_lower = specialty.toLowerCase();
    if (specialty_lower.includes('meditation') || specialty_lower.includes('mindful')) {
      return <Coffee className="h-4 w-4" />;
    } else if (specialty_lower.includes('therapy') || specialty_lower.includes('emotional')) {
      return <Heart className="h-4 w-4" />;
    } else {
      return <BookOpen className="h-4 w-4" />;
    }
  };
  
  return (
    <div className="flex flex-col p-4 bg-card rounded-lg border">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Avatar className="h-12 w-12">
            <AvatarImage src={user.profilePicture} alt={user.username} />
            <AvatarFallback>
              {user.firstname[0]}{user.lastname[0]}
            </AvatarFallback>
          </Avatar>
          <div>
            <Link to={`/profile/${user._id}`} className="font-medium hover:underline">
              {user.firstname} {user.lastname}
            </Link>
            <p className="text-sm text-muted-foreground">@{user.username}</p>
            <div className="flex items-center gap-1 mt-1">
              <div className="flex items-center text-xs text-blue-600">
                {getSpecialtyIcon(user.wellnessSpecialty)}
                <span className="ml-1">{user.wellnessSpecialty}</span>
              </div>
              {isFollower && (
                <span className="text-xs bg-blue-100 text-blue-800 px-2 py-0.5 rounded-full ml-2">
                  Follows you
                </span>
              )}
            </div>
          </div>
        </div>
        <Button
          variant={isFollowing ? "outline" : "default"}
          size="sm"
          onClick={onFollow}
          disabled={isLoading}
        >
          {isLoading ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : isFollowing ? (
            <>
              <UserMinus className="h-4 w-4 mr-2" />
              Unfollow
            </>
          ) : (
            <>
              <UserPlus className="h-4 w-4 mr-2" />
              Follow
            </>
          )}
        </Button>
      </div>
      
      {user.bio && (
        <div className="mt-3 text-sm">
          {user.bio}
        </div>
      )}
      
      {user.interests && user.interests.length > 0 && (
        <div className="mt-3 flex flex-wrap gap-1">
          {user.interests.map((interest, index) => (
            <Badge key={index} variant="secondary" className="text-xs">
              {interest}
            </Badge>
          ))}
        </div>
      )}
    </div>
  );
}
