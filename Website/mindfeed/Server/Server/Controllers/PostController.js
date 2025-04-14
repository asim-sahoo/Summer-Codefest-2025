import postModel from '../Models/postModel.js';
import mongoose from 'mongoose';
import UserModel from "../Models/userModel.js";


// Create new post
export const createPost = async (req, res) => {
    try {
        // Handle backward compatibility for single image
        if (req.body.image && !req.body.images) {
            req.body.images = [req.body.image];
        }
        
        const newPost = new postModel(req.body);
        await newPost.save();
        res.status(200).json(newPost);
    } catch (error) {
        console.error("Error creating post:", error);
        res.status(500).json({ message: "Error creating post", error: error.message });
    }
}


// get a post
export const getPost = async (req, res) => {
    const id = req.params.id;

    try {
        const post = await postModel.findById(id);
        res.status(200).json(post);
    } catch (error) {
        res.status(500).json(error);
    }
}


//Update a Post
export const updatePost = async (req, res) => {
    const postId = req.params.id;
    const { userId } = req.body;

    try {
        const post = await postModel.findById(postId);
        if (post.userId === userId) {
            // Handle backward compatibility for single image
            if (req.body.image && !req.body.images) {
                req.body.images = [req.body.image];
            }
            
            await post.updateOne({ $set: req.body });
            res.status(200).json("Post Updated Successfully!");
        } else {
            res.status(403).json("Action forbidden");
        }
    } catch (error) {
        res.status(500).json(error);
    }
}

// delete a post
export const deletePost = async (req, res) => {
    const id = req.params.id;
    const { userId } = req.body;

    try {
        const post = await postModel.findById(id);
        if (post.userId === userId) {
            await post.deleteOne();
            res.status(200).json("Post deleted successfully!");
        } else {
            res.status(403).json("Action forbidden");
        }
    } catch (error) {
        res.status(500).json(error);
    }
}


// Like/Dislike a Post
export const like_dislike_Post = async (req, res) => {
    const id = req.params.id;
    const { userId } = req.body;

    try {
        const post = await postModel.findById(id);
        if (!post.likes.includes(userId)) {
            await post.updateOne({ $push: { likes: userId } });
            res.status(200).json("Post liked");
        } else {
            await post.updateOne({ $pull: { likes: userId } });
            res.status(200).json("Post Unliked");
        }
    } catch (error) {
        res.status(500).json(error);
    }
}

// Get timeline a Posts
export const timeline = async (req, res) => {
    const userId = req.params.id;

    try {
        const currentUserPosts = await postModel.find({ userId: userId });
        const followingPosts = await UserModel.aggregate([
            {
                $match: {
                    _id: new mongoose.Types.ObjectId(userId),
                },
            },
            {
                $lookup: {
                    from: "posts",
                    localField: "following",
                    foreignField: "userId",
                    as: "followingPosts",
                },
            },
            {
                $project: {
                    followingPosts: 1,
                    _id: 0,
                },
            },
        ]);

        res.status(200).json(
            currentUserPosts
                .concat(...followingPosts[0].followingPosts)
                .sort((a, b) => b.createdAt - a.createdAt)
        );
    } catch (error) {
        res.status(500).json(error);
    }
};