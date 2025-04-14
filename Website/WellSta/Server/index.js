import express from 'express';
import mongoose from 'mongoose';
import bodyParser from 'body-parser';
import cors from 'cors';
import dotenv from 'dotenv';
import AuthRoute from './Routes/AuthRoute.js';
import UserRoute from './Routes/UserRoute.js';
import PostRoute from './Routes/PostRoute.js';
import UploadRoute from './Routes/UploadRoute.js';
import { JWT_KEY, MONGO_DB, PORT } from './config.js';

// Routes
const app = express();

// to serve images for public (public folder)
app.use(express.static('public'));
app.use('/images', express.static('images'));

// MiddleWare
app.use(bodyParser.json({ limit: "30mb", extended: true }));
app.use(bodyParser.urlencoded({ limit: "30mb", extended: true }));
app.use(cors());

// Load environment variables
dotenv.config();

// Set environment variables from config if not available from .env
process.env.JWT_KEY = process.env.JWT_KEY || JWT_KEY;
process.env.MONGO_DB = process.env.MONGO_DB || MONGO_DB;
process.env.PORT = process.env.PORT || PORT;

mongoose.connect
    (process.env.MONGO_DB, { useNewUrlParser: true, useUnifiedTopology: true }
    ).then(() =>
        app.listen(process.env.PORT, () => console.log(`listening at ${process.env.PORT}`))
    ).catch((error) =>
        console.log('MongoDB connection error:', error)
    )

// uses of routes
app.use('/auth', AuthRoute);
app.use('/user', UserRoute);
app.use('/post', PostRoute);
app.use('/upload', UploadRoute);