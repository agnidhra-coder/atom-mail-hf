import pool from '../db';

export interface Metadata {
  from_email: string;
  to_email: string;
  timestamp: number;
  tags: string[];
  thread_id: string;
  category?: string;
  is_urgent?: boolean;
}

export const insertMetadata = async (metadata: Metadata): Promise<number> => {
  const query = `
    INSERT INTO metadata (from_email, to_email, timestamp, tags, thread_id, category, is_urgent)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING id;
  `;
  const values = [
    metadata.from_email,
    metadata.to_email,
    metadata.timestamp,
    metadata.tags,
    metadata.thread_id,
    metadata.category ?? 'Updates',
    metadata.is_urgent ?? false,
  ];
  console.log('Inserting metadata:', values);
  
  const result = await pool.query(query, values);
  return result.rows[0].id;
};
