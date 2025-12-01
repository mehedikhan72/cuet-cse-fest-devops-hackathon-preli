import request from 'supertest';
import express from 'express';
import productsRouter from '../routes/products';

// Mock mongoose model
jest.mock('../models/product');

describe('Products API', () => {
  let app: express.Application;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use('/api/products', productsRouter);
  });

  describe('POST /api/products', () => {
    it('should reject empty product name', async () => {
      const response = await request(app)
        .post('/api/products')
        .send({ name: '', price: 100 });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
    });

    it('should reject negative price', async () => {
      const response = await request(app)
        .post('/api/products')
        .send({ name: 'Test Product', price: -10 });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
    });

    it('should reject invalid price type', async () => {
      const response = await request(app)
        .post('/api/products')
        .send({ name: 'Test Product', price: 'invalid' });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('GET /api/products', () => {
    it('should return empty array when no products exist', async () => {
      const { ProductModel } = require('../models/product');
      ProductModel.find = jest.fn().mockReturnValue({
        sort: jest.fn().mockReturnValue({
          lean: jest.fn().mockResolvedValue([]),
        }),
      });

      const response = await request(app).get('/api/products');

      expect(response.status).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
    });
  });
});
