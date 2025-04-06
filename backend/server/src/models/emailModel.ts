import pool from '../db';

export const insertEmail = async (
  content: string,
  embedding: number[],
  metadata_id: number
): Promise<void> => {
  const query = `
    INSERT INTO emails (content, embedding, metadata_id)
    VALUES ($1, $2, $3);
  `;
  await pool.query(query, [content, embedding, metadata_id]);
};
