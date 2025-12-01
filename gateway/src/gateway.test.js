const request = require('supertest');
const express = require('express');
const axios = require('axios');

jest.mock('axios');

describe('Gateway API', () => {
  let app;

  beforeEach(() => {
    // Mock gateway app
    app = express();
    app.use(express.json());

    // Health check endpoint
    app.get('/health', (req, res) => res.json({ ok: true }));

    // Mock proxy endpoint
    app.all('/api/*', async (req, res) => {
      try {
        const response = await axios({
          method: req.method,
          url: `http://backend:3847${req.url}`,
          data: req.body,
        });
        res.status(response.status).json(response.data);
      } catch (error) {
        res.status(502).json({ error: 'bad gateway' });
      }
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /health', () => {
    it('should return health status', async () => {
      const response = await request(app).get('/health');

      expect(response.status).toBe(200);
      expect(response.body).toEqual({ ok: true });
    });
  });

  describe('Proxy functionality', () => {
    it('should forward requests to backend', async () => {
      const mockData = [{ name: 'Product 1', price: 99.99 }];
      axios.mockResolvedValue({
        status: 200,
        data: mockData,
      });

      const response = await request(app).get('/api/products');

      expect(response.status).toBe(200);
      expect(response.body).toEqual(mockData);
    });

    it('should handle backend errors', async () => {
      axios.mockRejectedValue({
        isAxiosError: true,
        code: 'ECONNREFUSED',
      });

      const response = await request(app).get('/api/products');

      expect(response.status).toBe(502);
      expect(response.body).toHaveProperty('error');
    });
  });
});
