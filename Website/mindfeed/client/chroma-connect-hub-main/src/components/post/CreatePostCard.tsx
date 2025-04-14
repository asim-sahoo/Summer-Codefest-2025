import { useState, useRef } from "react";
import { Avatar } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardFooter } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Image, MapPin, Mic, Paperclip, Smile, User, X, StopCircle, Trash } from "lucide-react";
import { useToast } from "@/components/ui/use-toast";
import { useAuth } from "@/lib/AuthContext";
import { useNavigate } from "react-router-dom";
import EmojiPicker, { EmojiClickData } from "emoji-picker-react";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Carousel, CarouselContent, CarouselItem, CarouselPrevious, CarouselNext } from "@/components/ui/carousel";

interface CreatePostCardProps {
  onPostCreated?: () => void;
}

export function CreatePostCard({ onPostCreated }: CreatePostCardProps) {
  const [content, setContent] = useState("");
  const [images, setImages] = useState<string[]>([]);
  const [imageFiles, setImageFiles] = useState<File[]>([]);
  const [isUploading, setIsUploading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showEmojiPicker, setShowEmojiPicker] = useState(false);
  const [selectedEmoji, setSelectedEmoji] = useState<string | null>(null);
  const [isRecording, setIsRecording] = useState(false);
  const [recordingTime, setRecordingTime] = useState(0);
  const [audioURL, setAudioURL] = useState<string | null>(null);
  const [audioBlob, setAudioBlob] = useState<Blob | null>(null);
  const [locationDialogOpen, setLocationDialogOpen] = useState(false);
  const [location, setLocation] = useState<{name: string, coordinates: {latitude: number, longitude: number}} | null>(null);
  const [locationName, setLocationName] = useState("");
  
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);
  const timerRef = useRef<NodeJS.Timeout | null>(null);
  
  const { toast } = useToast();
  const { user } = useAuth();
  const navigate = useNavigate();

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      setIsUploading(true);
      
      const files = Array.from(e.target.files);
      let processed = 0;
      
      files.forEach((file) => {
        // Check if file is an image
        if (file && file.type.startsWith("image/")) {
          const reader = new FileReader();
          
          reader.onload = () => {
            const result = reader.result as string | ArrayBuffer | null;
            if (typeof result === 'string') {
              // Add the new image to the state
              setImages(prevImages => [...prevImages, result]);
              setImageFiles(prevFiles => [...prevFiles, file]);
            }
            
            processed++;
            if (processed === files.length) {
              setIsUploading(false);
              
              // Show success toast
              toast({
                title: "Images added",
                description: `${files.length} ${files.length === 1 ? 'image' : 'images'} added to your post`,
                duration: 2000,
              });
            }
          };
          
          reader.onerror = () => {
            toast({
              title: "Error",
              description: "Failed to read image file",
              variant: "destructive",
            });
            processed++;
            if (processed === files.length) {
              setIsUploading(false);
            }
          };
          
          // Read the file as a data URL (base64)
          reader.readAsDataURL(file);
        } else {
          toast({
            title: "Invalid file",
            description: "Please select a valid image file",
            variant: "destructive",
          });
          processed++;
          if (processed === files.length) {
            setIsUploading(false);
          }
        }
      });
    }
  };

  const handleEmojiClick = (emojiData: EmojiClickData) => {
    setSelectedEmoji(emojiData.emoji);
    setShowEmojiPicker(false);
  };

  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const mediaRecorder = new MediaRecorder(stream);
      mediaRecorderRef.current = mediaRecorder;
      audioChunksRef.current = [];
      
      mediaRecorder.ondataavailable = (e) => {
        if (e.data.size > 0) {
          audioChunksRef.current.push(e.data);
        }
      };
      
      mediaRecorder.onstop = () => {
        const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/wav' });
        const audioUrl = URL.createObjectURL(audioBlob);
        setAudioURL(audioUrl);
        setAudioBlob(audioBlob);
        
        // Stop all tracks in the stream
        stream.getTracks().forEach(track => track.stop());
      };
      
      // Start recording
      mediaRecorder.start();
      setIsRecording(true);
      
      // Start timer
      let seconds = 0;
      timerRef.current = setInterval(() => {
        seconds++;
        setRecordingTime(seconds);
        
        // Limit recording to 60 seconds
        if (seconds >= 60) {
          stopRecording();
        }
      }, 1000);
      
    } catch (error) {
      console.error("Error starting recording:", error);
      toast({
        title: "Recording failed",
        description: "Could not access microphone. Please check your permissions.",
        variant: "destructive",
      });
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stop();
      setIsRecording(false);
      
      // Clear timer
      if (timerRef.current) {
        clearInterval(timerRef.current);
        timerRef.current = null;
      }
    }
  };

  const removeAudio = () => {
    setAudioURL(null);
    setAudioBlob(null);
    setRecordingTime(0);
  };

  const getCurrentLocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setLocation({
            name: locationName || "Current Location",
            coordinates: {
              latitude: position.coords.latitude,
              longitude: position.coords.longitude
            }
          });
          setLocationDialogOpen(false);
          
          toast({
            title: "Location added",
            description: "Your location has been added to the post.",
          });
        },
        (error) => {
          console.error("Error getting location:", error);
          toast({
            title: "Location error",
            description: "Could not get your current location. Please try again.",
            variant: "destructive",
          });
        }
      );
    } else {
      toast({
        title: "Location not supported",
        description: "Geolocation is not supported by your browser.",
        variant: "destructive",
      });
    }
  };

  const removeLocation = () => {
    setLocation(null);
    setLocationName("");
  };

  const removeImage = () => {
    setImages([]);
    setImageFiles([]);
  };

  const handleSubmit = async () => {
    if (!content.trim() && images.length === 0 && !audioURL && !location && !selectedEmoji) {
      toast({
        title: "Empty Post",
        description: "Please add some content to your post.",
        variant: "destructive",
      });
      return;
    }
    
    if (!user) {
      toast({
        title: "Authentication Required",
        description: "Please log in to create a post.",
        variant: "destructive",
      });
      navigate("/login");
      return;
    }
    
    try {
      setIsSubmitting(true);
      
      // Create a new post object with local data
      const newPost = {
        _id: `local-post-${Date.now()}`,
        userId: user._id,
        desc: content,
        images: images,
        voiceNote: audioURL,
        location: location,
        emoji: selectedEmoji,
        createdAt: new Date().toISOString(),
        likes: []
      };
      
      console.log("Creating post with data:", newPost);
      
      // Save post to local storage
      const localPosts = JSON.parse(localStorage.getItem('wellsta_local_posts') || '[]');
      localPosts.unshift(newPost);
      localStorage.setItem('wellsta_local_posts', JSON.stringify(localPosts));
      
      // Reset form
      setContent("");
      setImages([]);
      setImageFiles([]);
      setSelectedEmoji(null);
      setAudioURL(null);
      setAudioBlob(null);
      setLocation(null);
      
      toast({
        title: "Success",
        description: images.length > 0 
          ? `Your post with ${images.length} ${images.length === 1 ? 'image' : 'images'} has been created!` 
          : "Your post has been created!",
        duration: 3000,
      });
      
      // Call the onPostCreated callback if provided
      if (onPostCreated) {
        onPostCreated();
      }
    } catch (error) {
      console.error("Error creating post:", error);
      toast({
        title: "Error",
        description: "Failed to create post. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const isDisabled = (!content.trim() && images.length === 0 && !audioURL && !location && !selectedEmoji) || isUploading || isSubmitting;

  // Get profile picture URL
  const getProfilePicUrl = () => {
    // First check for local storage profile picture
    const localProfilePic = localStorage.getItem('wellsta-profile-image');
    if (localProfilePic) {
      return localProfilePic;
    }
    
    // Fall back to API profile picture if available
    if (user?.profilePicture) {
      // Check if it's already a data URL
      if (user.profilePicture.startsWith('data:')) {
        return user.profilePicture;
      }
      // Otherwise assume it's a filename from the API
      return `http://localhost:4000/images/${user.profilePicture}`;
    }
    
    return undefined;
  };
  
  const profilePicUrl = getProfilePicUrl();

  return (
    <Card className="mb-6 animate-scale-in">
      <CardContent className="p-4">
        <div className="flex gap-3">
          <Avatar className="h-10 w-10 border">
            {profilePicUrl ? (
              <img src={profilePicUrl} alt={user?.username} className="h-full w-full object-cover" />
            ) : (
              <div className="flex h-full w-full items-center justify-center bg-muted">
                <User className="h-6 w-6 text-muted-foreground" />
              </div>
            )}
          </Avatar>
          <div className="flex-1">
            <textarea
              placeholder="What's happening?"
              value={content}
              onChange={(e) => setContent(e.target.value)}
              className="w-full resize-none border-none bg-transparent p-0 focus:outline-none focus:ring-0"
              rows={3}
            />
            
            {/* Selected Emoji Display */}
            {selectedEmoji && (
              <div className="mt-2 p-2 bg-muted/20 rounded-lg inline-block">
                <span className="text-3xl mr-2">{selectedEmoji}</span>
                <Button
                  size="icon"
                  variant="ghost"
                  className="h-6 w-6 rounded-full"
                  onClick={() => setSelectedEmoji(null)}
                >
                  <X className="h-3 w-3" />
                </Button>
              </div>
            )}
            
            {/* Location Display */}
            {location && (
              <div className="mt-2 p-2 bg-muted/20 rounded-lg flex items-center">
                <MapPin className="h-4 w-4 mr-2 text-social-accent" />
                <span className="text-sm">{location.name}</span>
                <Button
                  size="icon"
                  variant="ghost"
                  className="h-6 w-6 rounded-full ml-auto"
                  onClick={removeLocation}
                >
                  <X className="h-3 w-3" />
                </Button>
              </div>
            )}
            
            {/* Voice Note Display */}
            {audioURL && (
              <div className="mt-4 p-2 bg-muted/20 rounded-lg">
                <div className="flex items-center justify-between">
                  <div className="flex items-center">
                    <Mic className="h-4 w-4 mr-2 text-social-highlight" />
                    <span className="text-sm">Voice Note ({recordingTime}s)</span>
                  </div>
                  <Button
                    size="icon"
                    variant="ghost"
                    className="h-6 w-6 rounded-full"
                    onClick={removeAudio}
                  >
                    <X className="h-3 w-3" />
                  </Button>
                </div>
                <audio controls src={audioURL} className="w-full mt-2" />
              </div>
            )}
            
            {/* Image upload preview */}
            {images.length > 0 && (
              <div className="mt-4 mb-2">
                <div className="flex justify-between items-center mb-2">
                  <h3 className="text-sm font-medium">Images ({images.length})</h3>
                  <Button 
                    variant="ghost" 
                    size="sm" 
                    onClick={removeImage}
                    className="h-8 text-red-500 hover:text-red-700"
                  >
                    Remove All
                  </Button>
                </div>
                
                <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                  {images.map((image, index) => (
                    <div key={index} className="relative group aspect-square rounded-md overflow-hidden border">
                      <img 
                        src={image} 
                        alt={`Preview ${index + 1}`} 
                        className="w-full h-full object-cover"
                      />
                      <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                        <Button
                          variant="destructive"
                          size="icon"
                          className="h-8 w-8 rounded-full"
                          onClick={() => {
                            setImages(images.filter((_, i) => i !== index));
                            setImageFiles(imageFiles.filter((_, i) => i !== index));
                          }}
                        >
                          <Trash className="h-4 w-4" />
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
            
            {isUploading && (
              <div className="flex items-center justify-center bg-muted/50 p-4 rounded-lg mt-2">
                <span className="text-sm text-muted-foreground">Uploading...</span>
              </div>
            )}
            
            {isRecording && (
              <div className="flex items-center justify-between bg-red-100 dark:bg-red-900/30 p-3 rounded-lg mt-2">
                <div className="flex items-center">
                  <div className="h-3 w-3 bg-red-500 rounded-full animate-pulse mr-3"></div>
                  <span className="text-sm font-medium">Recording... {recordingTime}s</span>
                </div>
                <Button
                  size="sm"
                  variant="ghost"
                  className="text-red-500"
                  onClick={stopRecording}
                >
                  <StopCircle className="h-5 w-5 mr-1" />
                  Stop
                </Button>
              </div>
            )}
          </div>
        </div>
      </CardContent>
      <CardFooter className="p-0">
        <div className="w-full">
          <Separator />
          <div className="flex items-center justify-between p-2">
            <div className="flex gap-1">
              <label>
                <input
                  type="file"
                  accept="image/*"
                  className="hidden"
                  multiple
                  onChange={handleImageUpload}
                  disabled={isUploading || isSubmitting}
                />
                <Button 
                  variant="ghost" 
                  size="icon" 
                  className="rounded-full relative hover:bg-blue-100 dark:hover:bg-blue-900/30" 
                  type="button" 
                  disabled={isUploading || isSubmitting}
                >
                  <Image className="h-5 w-5 text-blue-500" />
                  <span className="absolute -top-1 -right-1 text-xs bg-blue-500 text-white rounded-full w-4 h-4 flex items-center justify-center">
                    +
                  </span>
                </Button>
              </label>
              
              <Button 
                variant="ghost" 
                size="icon" 
                className="rounded-full" 
                disabled={isSubmitting || isRecording || !!audioURL}
                onClick={startRecording}
              >
                <Mic className="h-5 w-5 text-social-highlight" />
              </Button>
              
              <Button 
                variant="ghost" 
                size="icon" 
                className="rounded-full"
                disabled={isSubmitting}
                onClick={() => setLocationDialogOpen(true)}
              >
                <MapPin className="h-5 w-5 text-social-accent" />
              </Button>
              
              <div className="relative">
                <Button 
                  variant="ghost" 
                  size="icon" 
                  className="rounded-full"
                  disabled={isSubmitting}
                  onClick={() => setShowEmojiPicker(!showEmojiPicker)}
                >
                  <Smile className="h-5 w-5 text-social-highlight" />
                </Button>
                
                {showEmojiPicker && (
                  <div className="absolute top-full left-0 mt-2 z-50">
                    <EmojiPicker onEmojiClick={handleEmojiClick} />
                  </div>
                )}
              </div>
              
              <Button variant="ghost" size="icon" className="rounded-full" disabled={isSubmitting}>
                <Paperclip className="h-5 w-5 text-social-accent" />
              </Button>
            </div>
            <Button
              disabled={isDisabled}
              onClick={handleSubmit}
              className="bg-social-primary hover:bg-social-primary/90"
            >
              {isSubmitting ? "Posting..." : "Post"}
            </Button>
          </div>
        </div>
      </CardFooter>
      
      {/* Location Dialog */}
      <Dialog open={locationDialogOpen} onOpenChange={setLocationDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Add Location</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="locationName">Location Name</Label>
              <Input
                id="locationName"
                placeholder="Enter a location name"
                value={locationName}
                onChange={(e) => setLocationName(e.target.value)}
              />
            </div>
            <div className="flex justify-between">
              <Button variant="outline" onClick={() => setLocationDialogOpen(false)}>
                Cancel
              </Button>
              <Button onClick={getCurrentLocation}>
                Use Current Location
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </Card>
  );
}
