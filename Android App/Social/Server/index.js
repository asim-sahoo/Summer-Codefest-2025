import express from 'express';
import mongoose from 'mongoose';
import bodyParser from 'body-parser';
import cors from 'cors';
import dotenv from 'dotenv';
import AuthRoute from './Routes/AuthRoute.js';
import UserRoute from './Routes/UserRoute.js';
import PostRoute from './Routes/PostRoute.js';
import UploadRoute from './Routes/UploadRoute.js';
import EngagementRoute from './Routes/EngagementRoute.js';
import path from 'path';
import { fileURLToPath } from 'url';

// For ES module __dirname equivalent
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Routes
const app = express();

// To serve images for public (public folder)
app.use(express.static('public'));
app.use('/images', express.static(path.join(__dirname, 'public/images')));

// MiddleWare
app.use(bodyParser.json({ limit: "30mb", extended: true }));
app.use(bodyParser.urlencoded({ limit: "30mb", extended: true }));
app.use(cors());

dotenv.config();

mongoose.connect
    (process.env.MONGO_DB, { useNewUrlParser: true, useUnifiedTopology: true }
    ).then(() =>
        app.listen(process.env.PORT, () => console.log(`listening at ${process.env.PORT}`))
    ).catch((error) =>
        console.log('error')
    )

// uses of routes

app.use('/api/auth', AuthRoute);
app.use('/api/user', UserRoute);
app.use('/api/post', PostRoute);
app.use('/api/upload', UploadRoute);
app.use('/api/engagement', EngagementRoute);