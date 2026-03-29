package com.ecommerce.service;

import com.ecommerce.model.Product;
import com.ecommerce.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class ProductService {
    
    @Autowired
    private ProductRepository productRepository;
    
    /**
     * Get all products
     */
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }
    
    /**
     * Get product by ID
     */
    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }
    
    /**
     * Create a new product
     */
    public Product createProduct(Product product) {
        // Check if SKU already exists
        if (productRepository.existsBySku(product.getSku())) {
            throw new RuntimeException("Product with SKU " + product.getSku() + " already exists!");
        }
        return productRepository.save(product);
    }
    
    /**
     * Update an existing product
     */
    public Product updateProduct(Long id, Product productDetails) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        // Update fields
        if (productDetails.getName() != null) {
            product.setName(productDetails.getName());
        }
        if (productDetails.getDescription() != null) {
            product.setDescription(productDetails.getDescription());
        }
        if (productDetails.getPrice() != null) {
            product.setPrice(productDetails.getPrice());
        }
        if (productDetails.getStock() != null) {
            product.setStock(productDetails.getStock());
        }
        if (productDetails.getSku() != null) {
            product.setSku(productDetails.getSku());
        }
        
        return productRepository.save(product);
    }
    
    /**
     * Delete a product
     */
    public void deleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        productRepository.delete(product);
    }
    
    /**
     * Get product by SKU
     */
    public Optional<Product> getProductBySku(String sku) {
        return productRepository.findBySku(sku);
    }
    
    /**
     * Update product inventory (for order processing)
     */
    public Product updateProductInventory(Long id, Integer newStock) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        product.setStock(newStock);
        return productRepository.save(product);
    }
    
    /**
     * Search products by name (case-insensitive)
     */
    public List<Product> searchProducts(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllProducts();
        }
        return productRepository.findByNameContainingIgnoreCase(keyword.trim());
    }
    
    /**
     * Filter products by price range
     */
    public List<Product> filterByPrice(java.math.BigDecimal minPrice, java.math.BigDecimal maxPrice) {
        if (minPrice == null || maxPrice == null) {
            return getAllProducts();
        }
        return productRepository.findByPriceBetween(minPrice, maxPrice);
    }
    
    /**
     * Filter products by category
     */
    public List<Product> filterByCategory(String category) {
        if (category == null || category.trim().isEmpty()) {
            return getAllProducts();
        }
        return productRepository.findByCategory(category);
    }
}
