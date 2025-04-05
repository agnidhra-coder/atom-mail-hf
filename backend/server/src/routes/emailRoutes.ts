import express from 'express';
import { uploadEmail } from '../controllers/emailController';

const router = express.Router();

router.post('/upload', uploadEmail);

export default router;