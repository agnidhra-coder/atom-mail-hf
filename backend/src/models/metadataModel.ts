import pool from '../db';

export interface Metadata {
  from_email: string;
  to_email: string;
  timestamp: number;
  tags: string[];
}

export const insertMetadata = async (metadata: Metadata): Promise<number> => {
  const query = `
    INSERT INTO metadata (from_email, to_email, timestamp, tags)
    VALUES ($1, $2, $3, $4)
    RETURNING id;
  `;
  const values = [
    metadata.from_email,
    metadata.to_email,
    metadata.timestamp,
    metadata.tags,
  ];
  console.log('Inserting metadata:', values);
  
  const result = await pool.query(query, values);
  return result.rows[0].id;
};
