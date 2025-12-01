import { ProductModel } from '../models/product';

describe('Product Model', () => {
  describe('Schema Validation', () => {
    it('should create a valid product instance', () => {
      const productData = {
        name: 'Test Product',
        price: 99.99,
      };

      const product = new ProductModel(productData);

      expect(product.name).toBe('Test Product');
      expect(product.price).toBe(99.99);
    });

    it('should have required fields', () => {
      const schema = ProductModel.schema;
      const namePath = schema.path('name');
      const pricePath = schema.path('price');

      expect(namePath).toBeDefined();
      expect(namePath?.isRequired).toBe(true);
      expect(pricePath).toBeDefined();
      expect(pricePath?.isRequired).toBe(true);
    });

    it('should have timestamps enabled', () => {
      const schema = ProductModel.schema;
      const createdAtPath = schema.path('createdAt');
      const updatedAtPath = schema.path('updatedAt');

      // If timestamps are enabled, createdAt and updatedAt paths should exist
      expect(createdAtPath).toBeDefined();
      expect(updatedAtPath).toBeDefined();
    });
  });
});
