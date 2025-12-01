import request from 'supertest';
import express from 'express';
import productsRouter from '../routes/products';
import { ProductModel } from '../models/product';

// Mock the ProductModel
jest.mock('../models/product');

const app = express();
app.use(express.json());
app.use('/api/products', productsRouter);

describe('Products API', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('POST /api/products', () => {
    it('should create a new product with valid data', async () => {
      const mockProduct = {
        _id: '123',
        name: 'Test Product',
        price: 99.99,
        createdAt: new Date().toISOString(),
      };

      const saveMock = jest.fn().mockResolvedValue(mockProduct);
      (ProductModel as jest.MockedClass<typeof ProductModel>).mockImplementation(
        () =>
          ({
            save: saveMock,
          }) as any
      );

      const response = await request(app)
        .post('/api/products')
        .send({ name: 'Test Product', price: 99.99 })
        .expect(201);

      expect(response.body).toEqual(mockProduct);
      expect(saveMock).toHaveBeenCalled();
    });

    it('should reject product with empty name', async () => {
      const response = await request(app)
        .post('/api/products')
        .send({ name: '   ', price: 99.99 })
        .expect(400);

      expect(response.body).toEqual({ error: 'Invalid name' });
    });

    it('should reject product with invalid name type', async () => {
      const response = await request(app)
        .post('/api/products')
        .send({ name: 123, price: 99.99 })
        .expect(400);

      expect(response.body).toEqual({ error: 'Invalid name' });
    });

    it('should reject product with negative price', async () => {
      const response = await request(app)
        .post('/api/products')
        .send({ name: 'Test Product', price: -10 })
        .expect(400);

      expect(response.body).toEqual({ error: 'Invalid price' });
    });

    it('should reject product with non-numeric price', async () => {
      const response = await request(app)
        .post('/api/products')
        .send({ name: 'Test Product', price: 'invalid' })
        .expect(400);

      expect(response.body).toEqual({ error: 'Invalid price' });
    });

    it('should handle database errors gracefully', async () => {
      const saveMock = jest.fn().mockRejectedValue(new Error('Database error'));
      (ProductModel as jest.MockedClass<typeof ProductModel>).mockImplementation(
        () =>
          ({
            save: saveMock,
          }) as any
      );

      const response = await request(app)
        .post('/api/products')
        .send({ name: 'Test Product', price: 99.99 })
        .expect(500);

      expect(response.body).toEqual({ error: 'server error' });
    });
  });

  describe('GET /api/products', () => {
    it('should return list of products', async () => {
      const mockProducts = [
        { _id: '1', name: 'Product 1', price: 10.99, createdAt: new Date().toISOString() },
        { _id: '2', name: 'Product 2', price: 20.99, createdAt: new Date().toISOString() },
      ];

      const findMock = {
        sort: jest.fn().mockReturnThis(),
        lean: jest.fn().mockResolvedValue(mockProducts),
      };

      (ProductModel.find as jest.Mock) = jest.fn().mockReturnValue(findMock);

      const response = await request(app).get('/api/products').expect(200);

      expect(response.body).toEqual(mockProducts);
      expect(ProductModel.find).toHaveBeenCalled();
      expect(findMock.sort).toHaveBeenCalledWith({ createdAt: -1 });
      expect(findMock.lean).toHaveBeenCalled();
    });

    it('should return empty array when no products exist', async () => {
      const findMock = {
        sort: jest.fn().mockReturnThis(),
        lean: jest.fn().mockResolvedValue([]),
      };

      (ProductModel.find as jest.Mock) = jest.fn().mockReturnValue(findMock);

      const response = await request(app).get('/api/products').expect(200);

      expect(response.body).toEqual([]);
    });

    it('should handle database errors gracefully', async () => {
      const findMock = {
        sort: jest.fn().mockReturnThis(),
        lean: jest.fn().mockRejectedValue(new Error('Database error')),
      };

      (ProductModel.find as jest.Mock) = jest.fn().mockReturnValue(findMock);

      const response = await request(app).get('/api/products').expect(500);

      expect(response.body).toEqual({ error: 'server error' });
    });
  });
});
