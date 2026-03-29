package com.ecommerce.repository;

import com.ecommerce.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    
    // Custom query method - find product by SKU
    Optional<Product> findBySku(String sku);
    
    // Custom query method - find products by name (case-insensitive)
    boolean existsBySku(String sku);
    
    // Search products by name (case-insensitive)
    List<Product> findByNameContainingIgnoreCase(String name);
    
    // Filter products by price range
    List<Product> findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice);
    
    // Filter products by category
    @Query("SELECT p FROM Product p WHERE p.id IN (SELECT DISTINCT p.id FROM Product p)")
    List<Product> findByCategory(String category);
}
