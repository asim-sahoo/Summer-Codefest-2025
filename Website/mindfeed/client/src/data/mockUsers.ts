// Mock user data for the Friends page
// This simulates users with wellness and mental health focused profiles

export interface MockUser {
  _id: string;
  username: string;
  firstname: string;
  lastname: string;
  email: string;
  profilePicture?: string;
  bio?: string;
  interests?: string[];
  wellnessSpecialty?: string;
  followers: string[];
  following: string[];
}

export const generateMockUsers = (currentUserId?: string): MockUser[] => {
  return [
    {
      _id: 'user-mindfulness-coach',
      username: 'mindfulnesscoach',
      firstname: 'Emma',
      lastname: 'Thompson',
      email: 'emma@mindfulnesscoach.com',
      profilePicture: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
      bio: 'Certified mindfulness coach helping you find peace in the digital age',
      interests: ['meditation', 'yoga', 'digital wellness'],
      wellnessSpecialty: 'Mindfulness Meditation',
      followers: currentUserId ? [currentUserId] : [],
      following: []
    },
    {
      _id: 'user-wellness-writer',
      username: 'wellnesswriter',
      firstname: 'Michael',
      lastname: 'Chen',
      email: 'michael@wellnesswriter.com',
      profilePicture: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
      bio: 'Author and wellness blogger sharing insights on mental health and self-care',
      interests: ['writing', 'mental health', 'self-care'],
      wellnessSpecialty: 'Mental Health Advocacy',
      followers: [],
      following: currentUserId ? [currentUserId] : []
    },
    {
      _id: 'user-yoga-instructor',
      username: 'yogalife',
      firstname: 'Priya',
      lastname: 'Patel',
      email: 'priya@yogalife.com',
      profilePicture: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
      bio: 'Yoga instructor focused on mind-body connection and stress reduction',
      interests: ['yoga', 'breathing techniques', 'stress management'],
      wellnessSpecialty: 'Yoga for Anxiety',
      followers: [],
      following: []
    },
    {
      _id: 'user-nutritionist',
      username: 'nutritionmind',
      firstname: 'David',
      lastname: 'Wilson',
      email: 'david@nutritionmind.com',
      profilePicture: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
      bio: 'Nutritionist exploring the connection between diet and mental wellbeing',
      interests: ['nutrition', 'brain health', 'mood food'],
      wellnessSpecialty: 'Nutritional Psychiatry',
      followers: [],
      following: []
    },
    {
      _id: 'user-sleep-expert',
      username: 'sleepbetter',
      firstname: 'Sophia',
      lastname: 'Garcia',
      email: 'sophia@sleepbetter.com',
      profilePicture: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
      bio: 'Sleep scientist helping you improve your mental health through better sleep',
      interests: ['sleep science', 'circadian rhythms', 'rest'],
      wellnessSpecialty: 'Sleep Optimization',
      followers: [],
      following: []
    },
    {
      _id: 'user-nature-therapist',
      username: 'naturetherapy',
      firstname: 'James',
      lastname: 'Taylor',
      email: 'james@naturetherapy.com',
      profilePicture: 'https://images.unsplash.com/photo-1552058544-f2b08422138a?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
      bio: 'Nature therapy guide helping people reconnect with the outdoors for mental wellness',
      interests: ['ecotherapy', 'hiking', 'forest bathing'],
      wellnessSpecialty: 'Nature Connection',
      followers: [],
      following: []
    },
    {
      _id: 'user-art-therapist',
      username: 'artforhealing',
      firstname: 'Olivia',
      lastname: 'Martinez',
      email: 'olivia@artforhealing.com',
      profilePicture: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
      bio: 'Art therapist using creative expression for emotional healing and mental health',
      interests: ['art therapy', 'creative expression', 'emotional healing'],
      wellnessSpecialty: 'Expressive Arts Therapy',
      followers: [],
      following: []
    },
    {
      _id: 'user-meditation-guide',
      username: 'meditationguide',
      firstname: 'Raj',
      lastname: 'Kumar',
      email: 'raj@meditationguide.com',
      profilePicture: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
      bio: 'Meditation teacher specializing in techniques for anxiety and stress reduction',
      interests: ['meditation', 'mindfulness', 'stress reduction'],
      wellnessSpecialty: 'Anxiety Management',
      followers: [],
      following: []
    },
    {
      _id: 'user-digital-detox',
      username: 'digitaldetox',
      firstname: 'Hannah',
      lastname: 'Johnson',
      email: 'hannah@digitaldetox.com',
      profilePicture: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
      bio: 'Digital wellness coach helping you create healthier relationships with technology',
      interests: ['digital minimalism', 'screen time management', 'tech-life balance'],
      wellnessSpecialty: 'Digital Wellness',
      followers: [],
      following: []
    },
    {
      _id: 'user-positive-psych',
      username: 'positivepsych',
      firstname: 'Marcus',
      lastname: 'Robinson',
      email: 'marcus@positivepsych.com',
      profilePicture: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
      bio: 'Positive psychology practitioner focusing on strengths, gratitude and resilience',
      interests: ['positive psychology', 'gratitude practice', 'resilience'],
      wellnessSpecialty: 'Strengths-Based Approaches',
      followers: [],
      following: []
    },
    {
      _id: 'user-breathwork',
      username: 'breathedeep',
      firstname: 'Aisha',
      lastname: 'Ahmed',
      email: 'aisha@breathedeep.com',
      profilePicture: 'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
      bio: 'Breathwork facilitator teaching techniques for anxiety, focus and emotional regulation',
      interests: ['breathwork', 'anxiety management', 'emotional regulation'],
      wellnessSpecialty: 'Therapeutic Breathing',
      followers: [],
      following: []
    },
    {
      _id: 'user-journaling',
      username: 'journalingjourney',
      firstname: 'Thomas',
      lastname: 'Wright',
      email: 'thomas@journalingjourney.com',
      profilePicture: 'https://images.unsplash.com/photo-1463453091185-61582044d556?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
      bio: 'Journaling coach helping you process emotions and gain clarity through writing',
      interests: ['therapeutic writing', 'reflection', 'emotional processing'],
      wellnessSpecialty: 'Expressive Writing',
      followers: [],
      following: []
    }
  ];
};
