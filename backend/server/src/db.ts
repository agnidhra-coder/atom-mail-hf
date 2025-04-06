import { Pool } from 'pg';
import dotenv from 'dotenv';
import postgres from 'postgres';

dotenv.config();


const pool = new Pool({
  // connectionString: process.env.DATABASE_URL,
  // ssl: {
  //   rejectUnauthorized: false, // Required by Supabase
  // },
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

export default pool;
