package com.ecommerce.controller;

import com.ecommerce.model.Product;
import com.ecommerce.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/products")
@CrossOrigin(origins = "*")
public class ProductController {
    
    @Autowired
    private ProductService productService;
    
    /**
     * GET all products
     * URL: GET http://localhost:8080/api/products
     */
    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() {
        List<Product> products = productService.getAllProducts();
        return ResponseEntity.ok(products);
    }
    
    /**
     * GET product by ID
     * URL: GET http://localhost:8080/api/products/1
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getProductById(@PathVariable Long id) {
        Optional<Product> product = productService.getProductById(id);
        if (product.isPresent()) {
            return ResponseEntity.ok(product.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body("Product not found with id: " + id);
    }
    
    /**
     * CREATE a new product
     * URL: POST http://localhost:8080/api/products
     * Body: {
     *   "name": "Laptop",
     *   "description": "Gaming Laptop",
     *   "price": 1200.00,
     *   "stock": 10,
     *   "sku": "LAP-001"
     * }
     */
    @PostMapping
    public ResponseEntity<?> createProduct(@Valid @RequestBody Product product) {
        try {
            Product createdProduct = productService.createProduct(product);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdProduct);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * UPDATE a product
     * URL: PUT http://localhost:8080/api/products/1
     * Body: {
     *   "name": "Updated Laptop",
     *   "price": 1300.00,
     *   "stock": 15
     * }
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updateProduct(@PathVariable Long id, @RequestBody Product productDetails) {
        try {
            Product updatedProduct = productService.updateProduct(id, productDetails);
            return ResponseEntity.ok(updatedProduct);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * DELETE a product
     * URL: DELETE http://localhost:8080/api/products/1
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteProduct(@PathVariable Long id) {
        try {
            productService.deleteProduct(id);
            return ResponseEntity.ok("Product deleted successfully with id: " + id);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * GET product by SKU
     * URL: GET http://localhost:8080/api/products/sku/LAP-001
     */
    @GetMapping("/sku/{sku}")
    public ResponseEntity<?> getProductBySku(@PathVariable String sku) {
        Optional<Product> product = productService.getProductBySku(sku);
        if (product.isPresent()) {
            return ResponseEntity.ok(product.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body("Product not found with sku: " + sku);
    }
    
    /**
     * SEARCH products by keyword (name)
     * URL: GET http://localhost:8080/api/products/search?keyword=laptop
     */
    @GetMapping("/search")
    public ResponseEntity<List<Product>> searchProducts(
            @RequestParam(value = "keyword", required = false) String keyword) {
        List<Product> products = productService.searchProducts(keyword);
        return ResponseEntity.ok(products);
    }
    
    /**
     * FILTER products by price range
     * URL: GET http://localhost:8080/api/products/filter/price?minPrice=100&maxPrice=5000
     */
    @GetMapping("/filter/price")
    public ResponseEntity<?> filterByPrice(
            @RequestParam(value = "minPrice", required = false) java.math.BigDecimal minPrice,
            @RequestParam(value = "maxPrice", required = false) java.math.BigDecimal maxPrice) {
        
        if (minPrice == null || maxPrice == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: Both minPrice and maxPrice parameters are required");
        }
        
        if (minPrice.compareTo(maxPrice) > 0) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: minPrice cannot be greater than maxPrice");
        }
        
        List<Product> products = productService.filterByPrice(minPrice, maxPrice);
        return ResponseEntity.ok(products);
    }
}
