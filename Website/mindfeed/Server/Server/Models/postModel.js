import mongoose from "mongoose";

const postSchema = mongoose.Schema(
    {
        userId: { type: String, required: true },
        desc: String,
        likes: [],
        images: [String],
        image: String, // Keep for backward compatibility
        voiceNote: String,
        location: {
            name: String,
            coordinates: {
                latitude: Number,
                longitude: Number
            }
        },
        emoji: String
    },
    {
        timestamps: true,
    }
)

const postModel = mongoose.model("Posts", postSchema);

export default postModel