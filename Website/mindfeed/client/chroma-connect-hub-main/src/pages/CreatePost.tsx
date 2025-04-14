import { useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Image, MapPin, X, Mic, Smile, StopCircle } from "lucide-react";
import { useToast } from "@/components/ui/use-toast";
import { useAuth } from "@/lib/AuthContext";
import { createPost, uploadImage, uploadMultipleFiles, uploadVoiceNote } from "@/lib/api";
import EmojiPicker, { EmojiClickData } from "emoji-picker-react";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export default function CreatePost() {
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
  const navigate = useNavigate();
  const { user } = useAuth();

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      setIsUploading(true);
      
      const files = Array.from(e.target.files);
      const newImages: string[] = [];
      const newImageFiles: File[] = [];
      
      let processed = 0;
      
      files.forEach((file) => {
        const reader = new FileReader();
        
        reader.onloadend = () => {
          if (typeof reader.result === 'string') {
            newImages.push(reader.result);
            newImageFiles.push(file);
          }
          
          processed++;
          if (processed === files.length) {
            setImages([...images, ...newImages]);
            setImageFiles([...imageFiles, ...newImageFiles]);
            setIsUploading(false);
          }
        };
        
        reader.readAsDataURL(file);
      });
    }
  };

  const removeImage = (index: number) => {
    setImages(images.filter((_, i) => i !== index));
    setImageFiles(imageFiles.filter((_, i) => i !== index));
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

  const handleSubmit = async () => {
    if (!content.trim() && images.length === 0 && !audioURL && !selectedEmoji) return;
    if (!user) return;
    
    setIsSubmitting(true);
    
    try {
      // Upload images first if any
      const uploadedImagePaths: string[] = [];
      
      if (imageFiles.length > 0) {
        if (imageFiles.length === 1) {
          // Single image upload
          const formData = new FormData();
          const fileName = Date.now() + imageFiles[0].name;
          formData.append("name", fileName);
          formData.append("file", imageFiles[0]);
          
          try {
            const response = await uploadImage(formData);
            uploadedImagePaths.push(response.fileName);
          } catch (error) {
            console.error("Error uploading image:", error);
            toast({
              title: "Upload failed",
              description: "There was an error uploading one or more images.",
              variant: "destructive",
            });
          }
        } else {
          // Multiple images upload
          const formData = new FormData();
          
          imageFiles.forEach((file, index) => {
            const fileName = Date.now() + index + file.name;
            formData.append("name", fileName);
            formData.append("files", file);
          });
          
          try {
            const response = await uploadMultipleFiles(formData);
            uploadedImagePaths.push(...response.fileNames);
          } catch (error) {
            console.error("Error uploading multiple images:", error);
            toast({
              title: "Upload failed",
              description: "There was an error uploading one or more images.",
              variant: "destructive",
            });
          }
        }
      }
      
      // Upload voice note if any
      let voiceNotePath = "";
      if (audioBlob) {
        const formData = new FormData();
        const fileName = Date.now() + "voice.wav";
        formData.append("name", fileName);
        formData.append("file", audioBlob);
        
        try {
          const response = await uploadVoiceNote(formData);
          voiceNotePath = response.fileName;
        } catch (error) {
          console.error("Error uploading voice note:", error);
          toast({
            title: "Upload failed",
            description: "There was an error uploading your voice note.",
            variant: "destructive",
          });
        }
      }
      
      // Create post with all uploaded content
      const newPost = {
        userId: user._id,
        desc: content,
        image: uploadedImagePaths.length > 0 ? uploadedImagePaths[0] : "", // For backward compatibility
        images: uploadedImagePaths,
        voiceNote: voiceNotePath,
        location: location,
        emoji: selectedEmoji
      };
      
      await createPost(newPost);
      
      toast({
        title: "Post created",
        description: "Your post has been published successfully!",
      });
      
      navigate("/");
    } catch (error) {
      console.error("Error creating post:", error);
      toast({
        title: "Post creation failed",
        description: "There was an error creating your post. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const isDisabled = (!content.trim() && images.length === 0 && !audioURL && !selectedEmoji) || isUploading || isSubmitting;

  return (
    <div className="max-w-2xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold mb-2">Create Post</h1>
        <p className="text-muted-foreground">Share something with your followers</p>
      </div>
      
      <Card className="mb-6 animate-scale-in">
        <CardContent className="p-4">
          <textarea
            placeholder="What's on your mind?"
            value={content}
            onChange={(e) => setContent(e.target.value)}
            className="w-full resize-none border-none bg-transparent p-2 text-lg focus:outline-none focus:ring-0 min-h-[150px]"
            rows={6}
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
          
          {/* Images Display */}
          {images.length > 0 && (
            <div className={`grid gap-2 mt-4 ${images.length === 1 ? '' : 'grid-cols-2'}`}>
              {images.map((image, index) => (
                <div key={index} className="relative rounded-lg overflow-hidden">
                  <img src={image} alt="" className="w-full h-auto object-cover max-h-80" />
                  <Button
                    size="icon"
                    variant="secondary"
                    className="absolute top-2 right-2 h-8 w-8 rounded-full opacity-90"
                    onClick={() => removeImage(index)}
                  >
                    <X className="h-4 w-4" />
                  </Button>
                </div>
              ))}
            </div>
          )}
          
          {isUploading && (
            <div className="flex items-center justify-center bg-muted/50 p-6 rounded-lg mt-4">
              <span className="text-muted-foreground">Uploading...</span>
            </div>
          )}
          
          {isRecording && (
            <div className="flex items-center justify-between bg-red-100 dark:bg-red-900/30 p-3 rounded-lg mt-4">
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
        </CardContent>
      </Card>
      
      <div className="flex items-center justify-between">
        <div className="flex gap-2">
          {/* Image Upload Button */}
          <label>
            <input
              type="file"
              accept="image/*"
              className="hidden"
              multiple
              onChange={handleImageUpload}
              disabled={isUploading || isSubmitting}
            />
            <Button variant="outline" type="button" disabled={isUploading || isSubmitting} className="gap-2">
              <Image className="h-5 w-5 text-social-primary" />
              {images.length > 0 ? `Images (${images.length})` : "Add Images"}
            </Button>
          </label>
          
          {/* Voice Note Button */}
          <Button 
            variant="outline" 
            className="gap-2" 
            disabled={isSubmitting || isRecording || !!audioURL}
            onClick={startRecording}
          >
            <Mic className="h-5 w-5 text-social-highlight" />
            {audioURL ? "Voice Added" : "Voice Note"}
          </Button>
          
          {/* Location Button */}
          <Button 
            variant="outline" 
            className="gap-2" 
            disabled={isSubmitting}
            onClick={() => setLocationDialogOpen(true)}
          >
            <MapPin className="h-5 w-5 text-social-accent" />
            {location ? "Location Added" : "Add Location"}
          </Button>
          
          {/* Emoji Button */}
          <div className="relative">
            <Button 
              variant="outline" 
              className="gap-2" 
              disabled={isSubmitting}
              onClick={() => setShowEmojiPicker(!showEmojiPicker)}
            >
              <Smile className="h-5 w-5 text-social-highlight" />
              {selectedEmoji ? "Emoji Added" : "Add Emoji"}
            </Button>
            
            {showEmojiPicker && (
              <div className="absolute top-full left-0 mt-2 z-50">
                <EmojiPicker onEmojiClick={handleEmojiClick} />
              </div>
            )}
          </div>
        </div>
        
        <Button
          disabled={isDisabled}
          onClick={handleSubmit}
          className="bg-social-primary hover:bg-social-primary/90"
        >
          {isSubmitting ? "Publishing..." : "Publish"}
        </Button>
      </div>
      
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
    </div>
  );
}
