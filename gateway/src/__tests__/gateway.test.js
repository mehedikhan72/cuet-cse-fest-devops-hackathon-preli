const request = require('supertest');
const express = require('express');
const axios = require('axios');

// Mock axios
jest.mock('axios');

// Create a minimal version of the gateway for testing
const createGatewayApp = () => {
  const app = express();
  app.use(express.json());

  const backendUrl = process.env.BACKEND_URL || 'http://backend:3000';

  app.all('/api/*', async (req, res, next) => {
    const targetPath = req.url;
    const targetUrl = `${backendUrl}${targetPath}`;

    try {
      const headers = {};
      if (req.body && Object.keys(req.body).length > 0) {
        headers['Content-Type'] = req.headers['content-type'] || 'application/json';
      }
      headers['X-Forwarded-For'] =
        req.ip || req.connection.remoteAddress || req.socket.remoteAddress;
      headers['X-Forwarded-Proto'] = req.protocol;

      const response = await axios({
        method: req.method,
        url: targetUrl,
        params: req.query,
        data: req.body,
        headers,
        timeout: 30000,
        validateStatus: () => true,
        maxContentLength: 50 * 1024 * 1024,
        maxBodyLength: 50 * 1024 * 1024,
      });

      res.status(response.status);

      const headersToForward = ['content-type', 'content-length'];
      headersToForward.forEach((header) => {
        if (response.headers[header]) {
          res.setHeader(header, response.headers[header]);
        }
      });

      res.json(response.data);
    } catch (error) {
      if (axios.isAxiosError(error)) {
        if (error.code === 'ECONNREFUSED') {
          res.status(503).json({
            error: 'Backend service unavailable',
            message: 'The backend service is currently unavailable. Please try again later.',
          });
          return;
        } else if (error.code === 'ETIMEDOUT' || error.code === 'ECONNABORTED') {
          res.status(504).json({
            error: 'Backend service timeout',
            message: 'The backend service did not respond in time. Please try again later.',
          });
          return;
        } else if (error.response) {
          res.status(error.response.status).json(error.response.data);
          return;
        }
      }

      if (!res.headersSent) {
        res.status(502).json({ error: 'bad gateway' });
      } else {
        next(error);
      }
    }
  });

  app.get('/health', (req, res) => res.json({ ok: true }));

  return app;
};

describe('Gateway Service', () => {
  let app;

  beforeEach(() => {
    jest.clearAllMocks();
    app = createGatewayApp();
  });

  describe('Health Check', () => {
    it('should return ok status', async () => {
      const response = await request(app).get('/health').expect(200);

      expect(response.body).toEqual({ ok: true });
    });
  });

  describe('Proxy Functionality', () => {
    it('should forward GET requests to backend', async () => {
      const mockData = [
        { id: 1, name: 'Product 1' },
        { id: 2, name: 'Product 2' },
      ];

      axios.mockResolvedValue({
        status: 200,
        data: mockData,
        headers: { 'content-type': 'application/json' },
      });

      const response = await request(app).get('/api/products').expect(200);

      expect(response.body).toEqual(mockData);
      expect(axios).toHaveBeenCalledWith(
        expect.objectContaining({
          method: 'GET',
          url: expect.stringContaining('/api/products'),
        })
      );
    });

    it('should forward POST requests with body to backend', async () => {
      const mockProduct = { id: 1, name: 'New Product', price: 99.99 };

      axios.mockResolvedValue({
        status: 201,
        data: mockProduct,
        headers: { 'content-type': 'application/json' },
      });

      const response = await request(app)
        .post('/api/products')
        .send({ name: 'New Product', price: 99.99 })
        .expect(201);

      expect(response.body).toEqual(mockProduct);
      expect(axios).toHaveBeenCalledWith(
        expect.objectContaining({
          method: 'POST',
          data: { name: 'New Product', price: 99.99 },
        })
      );
    });

    it('should handle backend connection refused error', async () => {
      const error = new Error('Connection refused');
      error.code = 'ECONNREFUSED';
      axios.isAxiosError = jest.fn().mockReturnValue(true);
      axios.mockRejectedValue(error);

      const response = await request(app).get('/api/products').expect(503);

      expect(response.body).toEqual({
        error: 'Backend service unavailable',
        message: 'The backend service is currently unavailable. Please try again later.',
      });
    });

    it('should handle backend timeout error', async () => {
      const error = new Error('Timeout');
      error.code = 'ETIMEDOUT';
      axios.isAxiosError = jest.fn().mockReturnValue(true);
      axios.mockRejectedValue(error);

      const response = await request(app).get('/api/products').expect(504);

      expect(response.body).toEqual({
        error: 'Backend service timeout',
        message: 'The backend service did not respond in time. Please try again later.',
      });
    });

    it('should forward backend error responses', async () => {
      const error = new Error('Bad Request');
      error.response = {
        status: 400,
        data: { error: 'Invalid data' },
      };
      axios.isAxiosError = jest.fn().mockReturnValue(true);
      axios.mockRejectedValue(error);

      const response = await request(app)
        .post('/api/products')
        .send({ invalid: 'data' })
        .expect(400);

      expect(response.body).toEqual({ error: 'Invalid data' });
    });

    it('should handle unknown errors as bad gateway', async () => {
      const error = new Error('Unknown error');
      axios.isAxiosError = jest.fn().mockReturnValue(false);
      axios.mockRejectedValue(error);

      const response = await request(app).get('/api/products').expect(502);

      expect(response.body).toEqual({ error: 'bad gateway' });
    });

    it('should forward query parameters', async () => {
      axios.mockResolvedValue({
        status: 200,
        data: { results: [] },
        headers: { 'content-type': 'application/json' },
      });

      await request(app).get('/api/products?limit=10&sort=price').expect(200);

      expect(axios).toHaveBeenCalledWith(
        expect.objectContaining({
          params: { limit: '10', sort: 'price' },
        })
      );
    });

    it('should set X-Forwarded headers', async () => {
      axios.mockResolvedValue({
        status: 200,
        data: {},
        headers: { 'content-type': 'application/json' },
      });

      await request(app).get('/api/products').expect(200);

      expect(axios).toHaveBeenCalledWith(
        expect.objectContaining({
          headers: expect.objectContaining({
            'X-Forwarded-For': expect.any(String),
            'X-Forwarded-Proto': 'http',
          }),
        })
      );
    });
  });
});
