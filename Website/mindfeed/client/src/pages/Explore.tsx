import { TechNews } from "../components/explore/TechNews";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "../components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";
import { Newspaper, Lightbulb, Users, Compass } from "lucide-react";

export default function Explore() {
  return (
    <div className="container mx-auto py-6 max-w-7xl">
      <h1 className="text-3xl font-bold mb-6">Explore</h1>
      
      <Tabs defaultValue="news" className="w-full mb-8">
        <TabsList className="grid grid-cols-4 mb-6">
          <TabsTrigger value="news" className="flex items-center gap-2">
            <Newspaper className="h-4 w-4" />
            <span className="hidden sm:inline">News</span>
          </TabsTrigger>
          <TabsTrigger value="wellness" className="flex items-center gap-2">
            <Lightbulb className="h-4 w-4" />
            <span className="hidden sm:inline">Wellness</span>
          </TabsTrigger>
          <TabsTrigger value="people" className="flex items-center gap-2">
            <Users className="h-4 w-4" />
            <span className="hidden sm:inline">People</span>
          </TabsTrigger>
          <TabsTrigger value="discover" className="flex items-center gap-2">
            <Compass className="h-4 w-4" />
            <span className="hidden sm:inline">Discover</span>
          </TabsTrigger>
        </TabsList>
        
        <TabsContent value="news" className="space-y-6">
          <TechNews />
          
          <Card>
            <CardHeader>
              <CardTitle className="text-gradient">More Categories</CardTitle>
              <CardDescription>Explore news from different categories</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                {["Business", "Health", "Science", "Sports", "Entertainment", "General", "Politics", "Environment"].map((category) => (
                  <Card key={category} className="cursor-pointer hover:bg-accent transition-colors">
                    <CardContent className="p-4 text-center">
                      <p className="font-medium">{category}</p>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        
        <TabsContent value="wellness" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="text-gradient">Wellness Resources</CardTitle>
              <CardDescription>Discover content to support your mental wellbeing</CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground mb-4">
                Explore curated wellness content to help you maintain balance and mindfulness in your digital life.
              </p>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <Card>
                  <CardContent className="p-4 text-center">
                    <h3 className="font-semibold mb-2">Meditation Guides</h3>
                    <p className="text-sm text-muted-foreground">Find guided meditations for stress relief</p>
                  </CardContent>
                </Card>
                <Card>
                  <CardContent className="p-4 text-center">
                    <h3 className="font-semibold mb-2">Mental Health Articles</h3>
                    <p className="text-sm text-muted-foreground">Read the latest research on mental wellbeing</p>
                  </CardContent>
                </Card>
                <Card>
                  <CardContent className="p-4 text-center">
                    <h3 className="font-semibold mb-2">Digital Wellness Tips</h3>
                    <p className="text-sm text-muted-foreground">Learn how to create healthy digital habits</p>
                  </CardContent>
                </Card>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        
        <TabsContent value="people" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="text-gradient">Connect with Others</CardTitle>
              <CardDescription>Find people with similar interests</CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground mb-4">
                This feature is coming soon! You'll be able to discover and connect with people who share your interests.
              </p>
            </CardContent>
          </Card>
        </TabsContent>
        
        <TabsContent value="discover" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="text-gradient">Discover New Content</CardTitle>
              <CardDescription>Explore content tailored to your interests</CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground mb-4">
                This feature is coming soon! You'll be able to discover content based on your interests and browsing habits.
              </p>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
