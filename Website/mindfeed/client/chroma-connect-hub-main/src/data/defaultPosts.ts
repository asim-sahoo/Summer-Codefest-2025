export interface DefaultPost {
  id: string;
  author: {
    name: string;
    username: string;
    avatar: string;
  };
  createdAt: string;
  content: string;
  image?: string;
  likes: number;
  comments: number;
  shares: number;
  type: 'quote' | 'article' | 'tip';
}

export const defaultPosts: DefaultPost[] = [
  {
    id: 'default-1',
    author: {
      name: 'WellSta Team',
      username: 'wellsta',
      avatar: '/logo.png'
    },
    createdAt: '2 days ago',
    content: '"The greatest glory in living lies not in never falling, but in rising every time we fall." — Nelson Mandela',
    image: '/images/quotes/quote-1.jpg',
    likes: 245,
    comments: 18,
    shares: 32,
    type: 'quote'
  },
  {
    id: 'default-2',
    author: {
      name: 'Mindfulness Expert',
      username: 'mindful_living',
      avatar: '/images/avatars/mindfulness.jpg'
    },
    createdAt: '3 days ago',
    content: 'Take a moment today to practice deep breathing. Inhale for 4 counts, hold for 4, exhale for 6. This simple practice can reduce stress and bring your mind back to the present moment.',
    image: '/images/wellness/breathing.jpg',
    likes: 189,
    comments: 24,
    shares: 45,
    type: 'tip'
  },
  {
    id: 'default-3',
    author: {
      name: 'Mental Health Today',
      username: 'mental_health',
      avatar: '/images/avatars/mental-health.jpg'
    },
    createdAt: '1 week ago',
    content: 'New research shows that spending just 20 minutes in nature can significantly lower stress hormone levels. Try taking a short walk in a park or garden during your lunch break!',
    image: '/images/wellness/nature.jpg',
    likes: 312,
    comments: 42,
    shares: 87,
    type: 'article'
  },
  {
    id: 'default-4',
    author: {
      name: 'WellSta Team',
      username: 'wellsta',
      avatar: '/logo.png'
    },
    createdAt: '5 days ago',
    content: '"Your time is limited, so don\'t waste it living someone else\'s life." — Steve Jobs',
    likes: 276,
    comments: 14,
    shares: 56,
    type: 'quote'
  },
  {
    id: 'default-5',
    author: {
      name: 'Digital Wellness',
      username: 'digital_wellness',
      avatar: '/images/avatars/digital-wellness.jpg'
    },
    createdAt: '4 days ago',
    content: 'Try the 20-20-20 rule when using screens: Every 20 minutes, look at something 20 feet away for 20 seconds. This reduces eye strain and helps maintain healthy screen habits.',
    image: '/images/wellness/screen-time.jpg',
    likes: 156,
    comments: 23,
    shares: 41,
    type: 'tip'
  }
];
