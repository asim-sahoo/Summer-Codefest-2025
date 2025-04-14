import express from 'express';
import { createPost, deletePost, getPost, getUserPosts, like_dislike_Post, timeline, updatePost } from '../Controllers/PostController.js';

const router = express.Router();

router.post('/', createPost);
// Move specific routes above the generic /:id route
router.get('/timeline/:userId', timeline);
router.get('/user/:userId', getUserPosts);
// Generic routes should come after specific routes
router.get('/:id', getPost);
router.put('/:id', updatePost);
router.delete('/:id', deletePost);
router.put('/:id/like', like_dislike_Post);

export default router;