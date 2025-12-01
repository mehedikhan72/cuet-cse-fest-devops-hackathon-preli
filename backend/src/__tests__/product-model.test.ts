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
      const schema = ProductModel.schema.obj;

      expect(schema.name).toBeDefined();
      expect(schema.name.required).toBe(true);
      expect(schema.price).toBeDefined();
      expect(schema.price.required).toBe(true);
    });

    it('should have timestamps enabled', () => {
      const schemaOptions = ProductModel.schema.options;

      expect(schemaOptions.timestamps).toBe(true);
    });
  });
});
