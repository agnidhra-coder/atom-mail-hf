jest.mock('../../src/db', () => ({
  __esModule: true,
  default: { query: jest.fn() },
}));

import pool from '../db';

const mockedPool = pool as jest.Mocked<typeof pool>;

// Import router after mock so it picks up mocked pool
import request from 'supertest';
import express from 'express';
import emailRoutes from '../routes/emailRoutes';

const app = express();
app.use(express.json());
app.use('/email', emailRoutes);

describe('GET /email/download', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns combined data with category and is_urgent', async () => {
    (mockedPool.query as jest.Mock)
      .mockResolvedValueOnce({ rows: [{ id: 1, content: 'hello', embedding: [0.1], metadata_id: 10 }] } as any)
      .mockResolvedValueOnce({ rows: [{ id: 10, from_email: 'a@b.com', to_email: 'c@d.com', timestamp: 1, tags: ['Work'], thread_id: 't1', category: 'Finance', is_urgent: true }] } as any);

    const res = await request(app).get('/email/download');
    expect(res.status).toBe(200);
    expect(res.body[0].metadata.category).toBe('Finance');
    expect(res.body[0].metadata.is_urgent).toBe(true);
  });

  it('defaults category/is_urgent when null', async () => {
    (mockedPool.query as jest.Mock)
      .mockResolvedValueOnce({ rows: [{ id: 1, content: 'x', embedding: [], metadata_id: 10 }] } as any)
      .mockResolvedValueOnce({ rows: [{ id: 10, from_email: 'a@b.com', to_email: 'c@d.com', timestamp: 1, tags: [], thread_id: 't1', category: null, is_urgent: null }] } as any);

    const res = await request(app).get('/email/download');
    expect(res.body[0].metadata.category).toBe('Updates');
    expect(res.body[0].metadata.is_urgent).toBe(false);
  });
});
