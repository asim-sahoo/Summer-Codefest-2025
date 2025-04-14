import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import ImageUploader from '@/components/ImageUploader';
import { Button } from '@/components/ui/button';
import { useToast } from '@/components/ui/use-toast';

const ImageUploadExample = () => {
  const [profileImage, setProfileImage] = useState<string>('');
  const [postImage, setPostImage] = useState<string>('');
  const { toast } = useToast();

  const handleCreatePost = () => {
    if (!postImage) {
      toast({
        title: 'No image selected',
        description: 'Please upload an image for your post',
        variant: 'destructive',
      });
      return;
    }

    // Create a new post with the image
    const newPost = {
      _id: `local-post-${Date.now()}`,
      userId: 'current-user', // In a real app, this would be the actual user ID
      desc: 'My new post with an image!',
      images: [postImage],
      createdAt: new Date().toISOString(),
      likes: []
    };

    // Save to local storage
    const localPosts = JSON.parse(localStorage.getItem('wellsta_local_posts') || '[]');
    localPosts.unshift(newPost);
    localStorage.setItem('wellsta_local_posts', JSON.stringify(localPosts));

    toast({
      title: 'Post created',
      description: 'Your post with image has been created successfully!',
      duration: 3000,
    });

    // Reset the post image
    setPostImage('');
    localStorage.removeItem('wellsta-post-image');

    // Redirect to home page
    window.location.href = '/';
  };

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold text-center mb-8 text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600">
        WellSta Image Upload
      </h1>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div>
          <ImageUploader
            title="Profile Picture"
            buttonText="Upload Profile Picture"
            storageKey="wellsta-profile-image"
            onImageChange={setProfileImage}
          />

          {profileImage && (
            <Card className="mt-4">
              <CardHeader>
                <CardTitle>Profile Preview</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="flex items-center space-x-4">
                  <img
                    src={profileImage}
                    alt="Profile"
                    className="w-16 h-16 rounded-full object-cover"
                  />
                  <div>
                    <h3 className="font-medium">Your Name</h3>
                    <p className="text-sm text-muted-foreground">@username</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
        </div>

        <div>
          <ImageUploader
            title="Create Post with Image"
            buttonText="Select Image for Post"
            storageKey="wellsta-post-image"
            onImageChange={setPostImage}
          />

          {postImage && (
            <Card className="mt-4">
              <CardHeader>
                <CardTitle>Post Preview</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center space-x-4">
                  <img
                    src={profileImage || '/logo.png'}
                    alt="Profile"
                    className="w-10 h-10 rounded-full object-cover"
                  />
                  <div>
                    <h3 className="font-medium">Your Name</h3>
                    <p className="text-xs text-muted-foreground">Just now</p>
                  </div>
                </div>
                <p>My new post with an image!</p>
                <img
                  src={postImage}
                  alt="Post"
                  className="w-full h-auto rounded-md"
                />
                <Button onClick={handleCreatePost} className="w-full">
                  Create Post
                </Button>
              </CardContent>
            </Card>
          )}
        </div>
      </div>
    </div>
  );
};

export default ImageUploadExample;
