import { useEffect, useState } from 'react';
import { fetchTechNews } from '../../lib/api';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '../ui/card';
import { Button } from '../ui/button';
import { ExternalLink } from 'lucide-react';
import { Skeleton } from '../ui/skeleton';

interface NewsItem {
  title: string;
  description: string;
  url: string;
  urlToImage: string;
  publishedAt: string;
  source: {
    name: string;
  };
}

export function TechNews() {
  const [news, setNews] = useState<NewsItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const getNews = async () => {
      try {
        setLoading(true);
        const articles = await fetchTechNews();
        setNews(articles.slice(0, 6)); // Limit to 6 articles
        setLoading(false);
      } catch (err) {
        console.error('Error fetching news:', err);
        setError('Failed to load tech news. Please try again later.');
        setLoading(false);
      }
    };

    getNews();
  }, []);

  if (error) {
    return (
      <Card className="mb-6">
        <CardHeader>
          <CardTitle>Tech News</CardTitle>
          <CardDescription>Stay updated with the latest in technology</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="text-red-500">{error}</div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="mb-6">
      <CardHeader>
        <CardTitle className="text-gradient">Tech News</CardTitle>
        <CardDescription>Stay updated with the latest in technology</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {loading
            ? Array(6)
                .fill(0)
                .map((_, index) => (
                  <Card key={index} className="overflow-hidden h-[300px]">
                    <Skeleton className="h-[150px] w-full" />
                    <CardContent className="p-4">
                      <Skeleton className="h-4 w-full mb-2" />
                      <Skeleton className="h-4 w-3/4 mb-2" />
                      <Skeleton className="h-4 w-1/2" />
                    </CardContent>
                  </Card>
                ))
            : news.map((item, index) => (
                <Card key={index} className="overflow-hidden h-[300px] flex flex-col">
                  <div 
                    className="h-[150px] bg-cover bg-center" 
                    style={{ 
                      backgroundImage: item.urlToImage 
                        ? `url(${item.urlToImage})` 
                        : 'url(/placeholder.svg)' 
                    }}
                  />
                  <CardContent className="p-4 flex-grow">
                    <h3 className="font-semibold text-sm line-clamp-2 mb-2">{item.title}</h3>
                    <p className="text-xs text-muted-foreground line-clamp-2">
                      {item.description || 'No description available'}
                    </p>
                  </CardContent>
                  <CardFooter className="p-4 pt-0 flex justify-between items-center">
                    <span className="text-xs text-muted-foreground">
                      {item.source.name} • {new Date(item.publishedAt).toLocaleDateString()}
                    </span>
                    <Button size="sm" variant="ghost" onClick={() => window.open(item.url, '_blank')}>
                      <ExternalLink className="h-4 w-4 mr-2" />
                      Read
                    </Button>
                  </CardFooter>
                </Card>
              ))}
        </div>
      </CardContent>
    </Card>
  );
}
