import mongoose from "mongoose";

const engagementSchema = mongoose.Schema(
    {
        userId: {
            type: String,
            required: true
        },
        date: {
            type: Date,
            default: Date.now,
            required: true
        },
        postsLiked: {
            type: Number,
            default: 0
        },
        commentsReceived: {
            type: Number,
            default: 0
        },
        likesReceived: {
            type: Number,
            default: 0
        },
        // Add tracking for different reaction types
        reactionsReceived: {
            like: { type: Number, default: 0 },
            heart: { type: Number, default: 0 },
            smile: { type: Number, default: 0 },
            fire: { type: Number, default: 0 }
        },
        // Store IDs of users who engaged with this user's content
        engagingUsers: [String],
        // Track engagement messages for daily digest
        engagementMessages: [{
            content: { type: String }, // Changed from "type" to "content"
            messageType: {
                type: String,
                enum: ['appreciation', 'smile', 'connection', 'general']
            }
        }],
        // Track if the daily digest was sent
        digestSent: {
            type: Boolean,
            default: false
        },
        // Last time user accessed their digest
        lastDigestAccessed: {
            type: Date,
            default: null
        }
    },
    { timestamps: true }
);

// Compound index to find a user's engagement for a specific date
engagementSchema.index({ userId: 1, date: 1 }, { unique: true });

const EngagementModel = mongoose.model("Engagements", engagementSchema);

export default EngagementModel;