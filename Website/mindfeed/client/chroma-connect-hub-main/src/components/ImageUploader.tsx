import React, { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Image, X } from 'lucide-react';
import { useToast } from '@/components/ui/use-toast';

interface ImageUploaderProps {
  onImageChange?: (imageUrl: string) => void;
  storageKey?: string;
  title?: string;
  buttonText?: string;
  className?: string;
}

const ImageUploader = ({
  onImageChange,
  storageKey = 'wellsta-user-image',
  title = 'Upload Image',
  buttonText = 'Choose Image',
  className = ''
}: ImageUploaderProps) => {
  const [image, setImage] = useState<string | null>(null);
  const { toast } = useToast();

  // Load image from localStorage on mount
  useEffect(() => {
    const storedImage = localStorage.getItem(storageKey);
    if (storedImage) {
      setImage(storedImage);
      if (onImageChange) {
        onImageChange(storedImage);
      }
    }
  }, [storageKey, onImageChange]);

  // Handle file upload and convert to base64
  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader();
      reader.onloadend = () => {
        const result = reader.result as string;
        if (typeof result === 'string') {
          setImage(result);
          localStorage.setItem(storageKey, result);
          
          if (onImageChange) {
            onImageChange(result);
          }
          
          toast({
            title: 'Image uploaded',
            description: 'Your image has been uploaded successfully',
            duration: 2000,
          });
        }
      };
      reader.readAsDataURL(file);
    } else {
      toast({
        title: 'Invalid file',
        description: 'Please select a valid image file',
        variant: 'destructive',
      });
    }
  };

  const removeImage = () => {
    setImage(null);
    localStorage.removeItem(storageKey);
    if (onImageChange) {
      onImageChange('');
    }
    toast({
      title: 'Image removed',
      description: 'Your image has been removed',
      duration: 2000,
    });
  };

  return (
    <Card className={`overflow-hidden ${className}`}>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {image ? (
          <div className="relative">
            <img 
              src={image} 
              alt="Uploaded" 
              className="w-full h-auto max-h-64 object-cover rounded-md" 
            />
            <Button
              variant="destructive"
              size="icon"
              className="absolute top-2 right-2 h-8 w-8 rounded-full"
              onClick={removeImage}
            >
              <X className="h-4 w-4" />
            </Button>
          </div>
        ) : (
          <div className="flex items-center justify-center h-48 bg-muted rounded-md border-2 border-dashed border-muted-foreground/25">
            <div className="flex flex-col items-center text-center p-4">
              <Image className="h-10 w-10 text-muted-foreground mb-2" />
              <p className="text-sm text-muted-foreground">
                Click the button below to upload an image
              </p>
            </div>
          </div>
        )}
      </CardContent>
      <CardFooter>
        <div className="w-full flex justify-between">
          <label className="w-full">
            <input
              type="file"
              accept="image/*"
              onChange={handleImageChange}
              className="hidden"
            />
            <Button 
              variant="default" 
              className="w-full"
            >
              {buttonText}
            </Button>
          </label>
          {image && (
            <Button 
              variant="outline" 
              className="ml-2"
              onClick={removeImage}
            >
              Remove
            </Button>
          )}
        </div>
      </CardFooter>
    </Card>
  );
};

export default ImageUploader;
