import mongoose from "mongoose";

const commentSchema = mongoose.Schema(
    {
        userId: { type: String, required: true },
        text: { type: String, required: true },
        userName: String,
        userProfilePicture: String
    },
    {
        timestamps: true
    }
);

const postSchema = mongoose.Schema(
    {
        userId: { type: String, required: true },
        desc: String,
        likes: [],
        image: String,
        comments: [commentSchema],
        shares: { type: Number, default: 0 },
        contentType: { type: String, enum: ['uplifting', 'neutral', 'sensitive'], default: 'neutral' }
    },
    {
        timestamps: true,
    }
);

const postModel = mongoose.model("Posts", postSchema);

export default postModel;