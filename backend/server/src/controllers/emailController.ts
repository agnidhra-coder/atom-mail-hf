import { Request, Response } from 'express';
import { insertMetadata, Metadata } from '../models/metadataModel';
import { insertEmail } from '../models/emailModel';

export const uploadEmail = async (req: Request, res: Response) => {
  try {
    const { content, embedding, metadata }: { content: string; embedding: number[]; metadata: Metadata } = req.body;
    console.log('metadata:', metadata);
    console.log('content:', content);
    console.log('embedding:', embedding);
    const metadataId = await insertMetadata(metadata);
    await insertEmail(content, embedding, metadataId);
    res.status(201).json({ message: 'Email saved successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};
