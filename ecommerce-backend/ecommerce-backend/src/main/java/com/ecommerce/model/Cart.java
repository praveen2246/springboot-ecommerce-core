package com.ecommerce.model;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "carts")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Cart {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    @JsonIgnore
    private User user;
    
    @OneToMany(mappedBy = "cart", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<CartItem> items = new ArrayList<>();
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    /**
     * Calculate total price: sum of all item subtotals
     */
    @Transient
    public BigDecimal getTotalPrice() {
        return items.stream()
                .map(CartItem::getSubtotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
    
    /**
     * Calculate total quantity: sum of all item quantities
     */
    @Transient
    public Integer getTotalQuantity() {
        return items.stream()
                .mapToInt(CartItem::getQuantity)
                .sum();
    }
    
    /**
     * Add item to cart or increase quantity if product already exists
     */
    public void addItem(CartItem item) {
        // Check if product already exists in cart
        CartItem existingItem = items.stream()
                .filter(ci -> ci.getProduct().getId().equals(item.getProduct().getId()))
                .findFirst()
                .orElse(null);
        
        if (existingItem != null) {
            // Update quantity and price
            existingItem.setQuantity(existingItem.getQuantity() + item.getQuantity());
            existingItem.setUnitPrice(item.getUnitPrice());
        } else {
            // Add new item
            item.setCart(this);
            items.add(item);
        }
    }
    
    /**
     * Remove item from cart
     */
    public void removeItem(CartItem item) {
        items.remove(item);
    }
    
    /**
     * Clear all items from cart
     */
    public void clearCart() {
        items.clear();
    }
}
