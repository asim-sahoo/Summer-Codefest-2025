import EngagementModel from "../Models/engagementModel.js";
import UserModel from "../Models/userModel.js";
import mongoose from "mongoose";

// Record a like received by a user
export const recordLikeReceived = async (req, res) => {
    const { userId, likedByUserId } = req.body;

    try {
        // Get today's date with time set to midnight for consistent daily records
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Find or create today's engagement record
        let engagement = await EngagementModel.findOne({
            userId: userId,
            date: {
                $gte: today,
                $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000)
            }
        });

        if (!engagement) {
            engagement = new EngagementModel({
                userId: userId,
                date: today,
                likesReceived: 0,
                engagingUsers: []
            });
        }

        // Increment likes and add the user to engaging users if not already there
        engagement.likesReceived += 1;
        if (!engagement.engagingUsers.includes(likedByUserId)) {
            engagement.engagingUsers.push(likedByUserId);
        }

        await engagement.save();

        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Record a comment received by a user
export const recordCommentReceived = async (req, res) => {
    const { userId, commentedByUserId } = req.body;

    try {
        // Get today's date with time set to midnight
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Find or create today's engagement record
        let engagement = await EngagementModel.findOne({
            userId: userId,
            date: {
                $gte: today,
                $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000)
            }
        });

        if (!engagement) {
            engagement = new EngagementModel({
                userId: userId,
                date: today,
                commentsReceived: 0,
                engagingUsers: []
            });
        }

        // Increment comments and add the user to engaging users if not already there
        engagement.commentsReceived += 1;
        if (!engagement.engagingUsers.includes(commentedByUserId)) {
            engagement.engagingUsers.push(commentedByUserId);
        }

        await engagement.save();

        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Record a reaction received by a user
export const recordReactionReceived = async (req, res) => {
    const { userId, reactedByUserId, reactionType, postId } = req.body;

    if (!['like', 'heart', 'smile', 'fire'].includes(reactionType)) {
        return res.status(400).json({ message: "Invalid reaction type" });
    }

    try {
        // Get today's date with time set to midnight for consistent daily records
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Find or create today's engagement record
        let engagement = await EngagementModel.findOne({
            userId: userId,
            date: {
                $gte: today,
                $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000)
            }
        });

        if (!engagement) {
            engagement = new EngagementModel({
                userId: userId,
                date: today,
                likesReceived: 0,
                reactionsReceived: {
                    like: 0,
                    heart: 0,
                    smile: 0,
                    fire: 0
                },
                engagingUsers: [],
                engagementMessages: []
            });
        }

        // Initialize reactionsReceived if it doesn't exist
        if (!engagement.reactionsReceived) {
            engagement.reactionsReceived = {
                like: 0,
                heart: 0,
                smile: 0,
                fire: 0
            };
        }

        // Increment specific reaction type
        engagement.reactionsReceived[reactionType] += 1;

        // For backward compatibility, also increment likesReceived for 'like' reactions
        if (reactionType === 'like') {
            engagement.likesReceived += 1;
        }

        // Add the user to engaging users if not already there
        if (!engagement.engagingUsers.includes(reactedByUserId)) {
            engagement.engagingUsers.push(reactedByUserId);
        }

        // Generate and store an engagement message
        let messageType = 'general';
        let message = '';

        switch (reactionType) {
            case 'like':
                messageType = 'appreciation';
                message = 'Someone appreciated your post';
                break;
            case 'heart':
                messageType = 'appreciation';
                message = 'Someone loved what you shared';
                break;
            case 'smile':
                messageType = 'smile';
                message = 'You made someone smile today 🙃';
                break;
            case 'fire':
                messageType = 'connection';
                message = 'Your content resonated strongly with someone';
                break;
        }

        if (!engagement.engagementMessages) {
            engagement.engagementMessages = [];
        }

        engagement.engagementMessages.push({
            content: message, // Changed from "type" to "content"
            messageType: messageType
        });

        await engagement.save();

        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get the daily digest for a user
export const getDailyDigest = async (req, res) => {
    const { userId } = req.params;

    try {
        // For testing purposes: Get today's and yesterday's engagements combined
        // Instead of just yesterday's data
        const twoDaysAgo = new Date();
        twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);
        twoDaysAgo.setHours(0, 0, 0, 0);

        // Get today's date - end of day
        const endOfToday = new Date();
        endOfToday.setHours(23, 59, 59, 999);

        // Find recent engagement records (today and yesterday)
        const engagement = await EngagementModel.findOne({
            userId: userId,
            date: {
                $gte: twoDaysAgo,
                $lte: endOfToday
            }
        }).sort({ date: -1 }); // Get the most recent one

        if (!engagement) {
            return res.status(200).json({
                message: "No recent engagement recorded.",
                engagementData: {
                    likesReceived: 0,
                    commentsReceived: 0,
                    reactionsReceived: {
                        like: 0,
                        heart: 0,
                        smile: 0,
                        fire: 0
                    },
                    uniqueEngagers: 0,
                    messages: ["Take a moment to share something today!"]
                }
            });
        }

        // Update lastDigestAccessed
        engagement.lastDigestAccessed = new Date();
        await engagement.save();

        // Generate messages
        const messages = [];

        // Get total reactions (all types)
        const totalReactions = engagement.reactionsReceived ?
            Object.values(engagement.reactionsReceived).reduce((sum, val) => sum + val, 0) :
            engagement.likesReceived;

        // Add reaction messages
        if (totalReactions > 0) {
            messages.push(`${totalReactions} ${totalReactions === 1 ? 'person' : 'people'} appreciated your posts.`);
        }

        // Add smile reactions specific message if any
        if (engagement.reactionsReceived && engagement.reactionsReceived.smile > 0) {
            messages.push(`You made ${engagement.reactionsReceived.smile > 1 ? 'people' : 'someone'} smile today 🙃`);
        }

        // Add heart reactions specific message if any
        if (engagement.reactionsReceived && engagement.reactionsReceived.heart > 0) {
            messages.push(`Someone connected with your thoughts ❤️`);
        }

        // Add comment messages
        if (engagement.commentsReceived > 0) {
            messages.push(`You received ${engagement.commentsReceived} ${engagement.commentsReceived === 1 ? 'comment' : 'comments'} on your posts.`);
        }

        // If we have stored engagement messages, include some of them
        if (engagement.engagementMessages && engagement.engagementMessages.length > 0) {
            // Get 1-3 random messages from stored messages (without duplicates)
            const uniqueMessageTypes = [...new Set(engagement.engagementMessages.map(msg => msg.content))];
            const selectedMessages = uniqueMessageTypes.slice(0, 3);

            messages.push(...selectedMessages);
        }

        // If still no messages, add a default one
        if (messages.length === 0) {
            messages.push("No new activity. Ready to engage today?");
        }

        // Add debugging information to help troubleshoot
        messages.push(`Debug info: Engagement from ${new Date(engagement.date).toLocaleDateString()}`);

        // Return the digest data
        res.status(200).json({
            message: "Daily digest retrieved successfully",
            engagementData: {
                likesReceived: engagement.likesReceived,
                commentsReceived: engagement.commentsReceived,
                reactionsReceived: engagement.reactionsReceived || {
                    like: engagement.likesReceived,
                    heart: 0,
                    smile: 0,
                    fire: 0
                },
                uniqueEngagers: engagement.engagingUsers.length,
                messages: messages
            }
        });
    } catch (error) {
        console.error("Error in getDailyDigest:", error);
        res.status(500).json({ message: error.message });
    }
};

// Generate messages for the daily digest
export const generateDigestMessages = async (req, res) => {
    const { userId } = req.params;

    try {
        // Get yesterday's date
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        yesterday.setHours(0, 0, 0, 0);

        // Get today's date
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Find yesterday's engagement record
        const engagement = await EngagementModel.findOne({
            userId: userId,
            date: {
                $gte: yesterday,
                $lt: today
            }
        });

        if (!engagement || (engagement.likesReceived === 0 && engagement.commentsReceived === 0)) {
            return res.status(200).json({
                messages: ["Take a moment to share something today!"]
            });
        }

        const messages = [];

        // Generate messages based on engagement
        if (engagement.likesReceived > 0) {
            messages.push(`${engagement.likesReceived} ${engagement.likesReceived === 1 ? 'person' : 'people'} appreciated your posts yesterday.`);
        }

        if (engagement.commentsReceived > 0) {
            messages.push(`You received ${engagement.commentsReceived} ${engagement.commentsReceived === 1 ? 'comment' : 'comments'} on your posts.`);
        }

        if (engagement.engagingUsers.length > 0) {
            const randomMessages = [
                "You made someone smile 🙃",
                "Someone connected with your thoughts",
                "Your posts resonated with others yesterday",
                "You brightened someone's day"
            ];

            // Add a random positive message
            messages.push(randomMessages[Math.floor(Math.random() * randomMessages.length)]);
        }

        res.status(200).json({ messages });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Send daily digest to all users
export const sendDailyDigestToAllUsers = async (req, res) => {
    try {
        // Get yesterday's date
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        yesterday.setHours(0, 0, 0, 0);

        // Get today's date
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Find all users
        const users = await UserModel.find({}, '_id');
        let successful = 0;
        let skipped = 0;

        // Process each user
        for (const user of users) {
            // Find yesterday's engagement record
            const engagement = await EngagementModel.findOne({
                userId: user._id,
                date: {
                    $gte: yesterday,
                    $lt: today
                }
            });

            // Skip if no engagement or digest already sent
            if (!engagement || engagement.digestSent) {
                skipped++;
                continue;
            }

            // Generate messages
            const messages = [];

            // Get total reactions (all types)
            const totalReactions = engagement.reactionsReceived ?
                Object.values(engagement.reactionsReceived).reduce((sum, val) => sum + val, 0) :
                engagement.likesReceived;

            // Check if there's any engagement
            const hasEngagement = totalReactions > 0 || engagement.commentsReceived > 0;

            if (hasEngagement) {
                // Add reaction messages
                if (totalReactions > 0) {
                    messages.push(`${totalReactions} ${totalReactions === 1 ? 'person' : 'people'} appreciated your posts.`);
                }

                // Add smile reactions specific message if any
                if (engagement.reactionsReceived && engagement.reactionsReceived.smile > 0) {
                    messages.push(`You made ${engagement.reactionsReceived.smile > 1 ? 'people' : 'someone'} smile today 🙃`);
                }

                // Add heart reactions specific message if any
                if (engagement.reactionsReceived && engagement.reactionsReceived.heart > 0) {
                    messages.push(`Someone connected with your thoughts ❤️`);
                }

                // Add comment messages
                if (engagement.commentsReceived > 0) {
                    messages.push(`You received ${engagement.commentsReceived} ${engagement.commentsReceived === 1 ? 'comment' : 'comments'} on your posts.`);
                }

                // If we have stored engagement messages, include some of them
                if (engagement.engagementMessages && engagement.engagementMessages.length > 0) {
                    // Get 1-3 random messages from stored messages (without duplicates)
                    const uniqueMessageTypes = [...new Set(engagement.engagementMessages.map(msg => msg.content))];
                    const selectedMessages = uniqueMessageTypes.slice(0, 3);

                    // Add these messages if not already included
                    for (const message of selectedMessages) {
                        if (!messages.includes(message)) {
                            messages.push(message);
                        }
                    }
                }

                // If still no messages, add a default one
                if (messages.length === 0) {
                    messages.push("No new activity yesterday. Ready to engage today?");
                }

                try {
                    // Store digest messages in the user model
                    await UserModel.findByIdAndUpdate(
                        user._id,
                        {
                            $push: { digestMessages: { date: new Date(), messages } },
                            $set: { lastDigestDate: new Date() }
                        }
                    );

                    // Mark the engagement record as having had a digest sent
                    engagement.digestSent = true;
                    await engagement.save();

                    successful++;

                    // Log for monitoring purposes
                    console.log(`Stored digest for user ${user._id}:`, messages);
                } catch (updateError) {
                    console.error(`Failed to store digest for user ${user._id}:`, updateError);
                    // We don't want to fail the entire process if one update fails
                }
            } else {
                skipped++;
            }
        }

        if (res) { // Check if this is being called from a route or automated job
            res.status(200).json({
                message: "Daily digest process completed",
                stats: {
                    successful,
                    skipped,
                    total: users.length
                }
            });
        }

        return {
            successful,
            skipped,
            total: users.length
        };
    } catch (error) {
        console.error("Error in sendDailyDigestToAllUsers:", error);
        if (res) {
            res.status(500).json({ message: error.message });
        }
        throw error;
    }
};