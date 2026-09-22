jest.mock('../../src/db', () => ({
  __esModule: true,
  default: { query: jest.fn() },
}));

import pool from '../db';
import { insertMetadata } from '../models/metadataModel';

const mockedPool = pool as jest.Mocked<typeof pool>;

describe('insertMetadata', () => {
  beforeEach(() => jest.clearAllMocks());

  it('inserts with category and is_urgent', async () => {
    (mockedPool.query as jest.Mock).mockResolvedValue({ rows: [{ id: 42 }] } as any);
    const id = await insertMetadata({
      from_email: 'a@b.com',
      to_email: 'c@d.com',
      timestamp: 123456,
      tags: ['Work'],
      thread_id: 't1',
      category: 'Work',
      is_urgent: true,
    });
    expect(id).toBe(42);
    expect(mockedPool.query).toHaveBeenCalledWith(
      expect.stringContaining('category, is_urgent'),
      ['a@b.com', 'c@d.com', 123456, ['Work'], 't1', 'Work', true]
    );
  });

  it('defaults category Updates and is_urgent false when missing', async () => {
    (mockedPool.query as jest.Mock).mockResolvedValue({ rows: [{ id: 1 }] } as any);
    await insertMetadata({
      from_email: 'a@b.com',
      to_email: 'c@d.com',
      timestamp: 1,
      tags: [],
      thread_id: 't2',
    } as any);
    expect(mockedPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.arrayContaining(['Updates', false])
    );
  });
});
