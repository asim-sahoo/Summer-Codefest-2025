import express from 'express';
import { recordLikeReceived, recordCommentReceived, recordReactionReceived, getDailyDigest, sendDailyDigestToAllUsers } from '../Controllers/EngagementController.js';
import authMiddleware from '../Middleware/authMiddleWare.js';
import EngagementModel from '../Models/engagementModel.js';

const router = express.Router();

// Routes for recording engagement
router.post("/like", authMiddleware, recordLikeReceived);
router.post("/comment", authMiddleware, recordCommentReceived);
router.post("/reaction", authMiddleware, recordReactionReceived);

// Route for getting daily digest
router.get("/digest/:userId", getDailyDigest); // Removed authMiddleware for testing

// Debug route - Test engagement system (accessible without auth for testing)
router.get("/test-engagement/:userId", async (req, res) => {
    try {
        const { userId } = req.params;
        console.log(`Test engagement requested for user: ${userId}`);

        // Get current date
        const now = new Date();
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Create a test engagement for today
        const testEngagement = {
            userId: userId,
            date: today,
            likesReceived: 1,
            commentsReceived: 0,
            reactionsReceived: {
                like: 1,
                heart: 0,
                smile: 0,
                fire: 0
            },
            engagingUsers: ["test-user-id"],
            engagementMessages: [{
                content: "Test: Someone appreciated your post", // Changed from "type" to "content"
                messageType: "appreciation"
            }]
        };

        // Find or create today's engagement record
        let engagement = await EngagementModel.findOne({
            userId: userId,
            date: {
                $gte: today,
                $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000)
            }
        });

        if (!engagement) {
            // Create new test engagement
            console.log("Creating new test engagement");
            engagement = new EngagementModel(testEngagement);
            await engagement.save();
            res.status(200).json({
                message: "Created test engagement record",
                data: engagement
            });
        } else {
            // Update existing record with test data
            console.log("Updating existing engagement");
            engagement.likesReceived += 1;

            // Initialize reactionsReceived if it doesn't exist
            if (!engagement.reactionsReceived) {
                engagement.reactionsReceived = {
                    like: 0,
                    heart: 0,
                    smile: 0,
                    fire: 0
                };
            }

            engagement.reactionsReceived.like += 1;

            if (!engagement.engagingUsers.includes("test-user-id")) {
                engagement.engagingUsers.push("test-user-id");
            }

            if (!engagement.engagementMessages) {
                engagement.engagementMessages = [];
            }

            engagement.engagementMessages.push({
                content: `Test: Someone appreciated your post at ${now.toLocaleTimeString()}`, // Changed from "type" to "content"
                messageType: "appreciation"
            });

            await engagement.save();
            res.status(200).json({
                message: "Updated existing engagement record with test data",
                data: engagement
            });
        }
    } catch (error) {
        console.error("Test engagement error:", error);
        res.status(500).json({ message: error.message });
    }
});

// Route for manually triggering digest sending to all users (admin only)
router.post("/send-digest", authMiddleware, sendDailyDigestToAllUsers);

export default router;