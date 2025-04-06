import express from 'express';
import { uploadEmail } from '../controllers/emailController';
import { Request, Response } from 'express';
import pool from '../db';

const router = express.Router();

router.post('/upload', uploadEmail);

router.get('/download', async (req: Request, res: Response) => {
    try {
      const emailQuery = `
        SELECT id, content, embedding, metadata_id 
        FROM emails
      `;
      const metadataQuery = `
        SELECT id, from_email, to_email, timestamp, tags, thread_id
        FROM metadata
      `;
  
      const [emailResults, metadataResults] = await Promise.all([
        pool.query(emailQuery),
        pool.query(metadataQuery),
      ]);
  
      const metadataMap: Record<number, any> = {};
      metadataResults.rows.forEach((metadata) => {
        metadataMap[metadata.id] = {
          from_email: metadata.from_email,
          to_email: metadata.to_email,
          timestamp: metadata.timestamp,
          tags: metadata.tags,
          thread_id: metadata.thread_id,
        };
      });
  
      const combinedData = emailResults.rows.map((email) => ({
        id: email.id,
        content: email.content,
        embedding: email.embedding,
        metadata: metadataMap[email.metadata_id],
      }));
  
      res.json(combinedData);
    } catch (error) {
      console.error('Error fetching data:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

export default router;