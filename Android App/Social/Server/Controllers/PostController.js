import postModel from '../Models/postModel.js';
import mongoose from 'mongoose';
import UserModel from "../Models/userModel.js";


// Create new post
export const createPost = async (req, res) => {
    const newPost = new postModel(req.body);

    try {
        await newPost.save();
        res.status(200).json(newPost)
    } catch (error) {
        res.status(500).json(error)
    }
}


// get a post
export const getPost = async (req, res) => {
    const id = req.params.id

    try {
        const post = await postModel.findById(id)
        res.status(200).json(post)
    } catch (error) {
        res.status(500).json(error)
    }
}


//Update a Post
export const updatePost = async (req, res) => {
    const postId = req.params.id

    const { userId } = req.body

    try {
        const post = await postModel.findById(postId)
        if (post.userId === userId) {
            await post.updateOne({ $set: req.body })
            res.status(200).json("Post Updated Successfully!")
        } else {
            res.status(403).json("Action forbidden")
        }
    } catch (error) {
        res.status(500).json(error)
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
            res.status(200).json("Post deleted Successfully!")
        } else {
            res.status(403).json("Action forbidden")
        }

    } catch (error) {
        res.status(500).json(error)
    }
}


// Like/Dislike a Post

export const like_dislike_Post = async (req, res) => {
    const id = req.params.id;

    const { userId } = req.body;

    try {
        const post = await postModel.findById(id);
        if (!post.likes.includes(userId)) {
            await post.updateOne({ $push: { likes: userId } })
            res.status(200).json("Post liked.")
        } else {
            await post.updateOne({ $pull: { likes: userId } })
            res.status(200).json("Post unliked.")
        }
    } catch (error) {
        res.status(500).json(error)
    }
}


// Get timeline a Posts
export const timeline = async (req, res) => {
    const userId = req.params.userId;

    try {
        // Get current user's posts
        const currenUserPosts = await postModel.find({ userId: userId });

        // Get posts from followed users
        const followingUserPosts = await UserModel.aggregate(
            [
                {
                    $match: {
                        _id: new mongoose.Types.ObjectId(userId)
                    }
                },
                {
                    $lookup: {
                        from: "posts",
                        localField: "following",
                        foreignField: "userId",
                        as: "followingUserPosts"
                    }
                },
                {
                    $project: {
                        followingUserPosts: 1,
                        _id: 0
                    }
                }
            ]
        );

        // Get all posts (including from users not followed)
        const allPosts = await postModel.find({ userId: { $ne: userId } });

        // Combine current user posts and posts from followed users
        const followedPosts = currenUserPosts.concat(
            followingUserPosts[0]?.followingUserPosts || []
        );

        // To include all posts, merge followedPosts with allPosts
        // For a mixed feed, you can use this approach to show all posts while prioritizing followed users
        const mergedPosts = [...followedPosts, ...allPosts.filter(post =>
            !followedPosts.some(fp => fp._id.toString() === post._id.toString())
        )];

        // Sort all posts by creation date (newest first)
        const sortedPosts = mergedPosts.sort((a, b) => {
            return b.createdAt - a.createdAt;
        });

        res.status(200).json(sortedPosts);
    } catch (error) {
        res.status(500).json(error)
    }
}

// Get a user's posts
export const getUserPosts = async (req, res) => {
    const userId = req.params.userId;

    try {
        const posts = await postModel.find({ userId: userId }).sort({ createdAt: -1 });
        res.status(200).json(posts);
    } catch (error) {
        res.status(500).json(error);
    }
}