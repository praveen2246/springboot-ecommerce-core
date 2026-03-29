package com.ecommerce.service;

import com.ecommerce.model.Cart;
import com.ecommerce.model.CartItem;
import com.ecommerce.model.Product;
import com.ecommerce.model.User;
import com.ecommerce.repository.CartRepository;
import com.ecommerce.repository.CartItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
@Transactional
public class CartService {
    
    @Autowired
    private CartRepository cartRepository;
    
    @Autowired
    private CartItemRepository cartItemRepository;
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private ProductService productService;
    
    /**
     * Get cart for a user (create if doesn't exist)
     */
    public Cart getOrCreateCart(Long userId) {
        User user = userService.getUserById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        Optional<Cart> existingCart = cartRepository.findByUser(user);
        if (existingCart.isPresent()) {
            return existingCart.get();
        }
        
        // Create new cart for user
        Cart newCart = new Cart();
        newCart.setUser(user);
        return cartRepository.save(newCart);
    }
    
    /**
     * Get cart by user ID
     */
    public Optional<Cart> getCartByUser(Long userId) {
        User user = userService.getUserById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        return cartRepository.findByUser(user);
    }
    
    /**
     * Add item to cart
     */
    public Cart addItemToCart(Long userId, Long productId, Integer quantity) {
        // Validate quantity
        if (quantity <= 0) {
            throw new RuntimeException("Quantity must be positive!");
        }
        
        // Get or create cart
        Cart cart = getOrCreateCart(userId);
        
        // Get product
        Product product = productService.getProductById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + productId));
        
        // Check stock
        if (product.getStock() < quantity) {
            throw new RuntimeException("Insufficient stock! Available: " + product.getStock() + ", Requested: " + quantity);
        }
        
        // Create cart item
        CartItem cartItem = new CartItem();
        cartItem.setProduct(product);
        cartItem.setQuantity(quantity);
        cartItem.setUnitPrice(product.getPrice());
        
        // Add to cart
        cart.addItem(cartItem);
        
        return cartRepository.save(cart);
    }
    
    /**
     * Update item quantity
     */
    public Cart updateItemQuantity(Long userId, Long cartItemId, Integer newQuantity) {
        // Validate quantity
        if (newQuantity <= 0) {
            throw new RuntimeException("Quantity must be positive!");
        }
        
        Cart cart = getOrCreateCart(userId);
        
        CartItem cartItem = cart.getItems().stream()
                .filter(item -> item.getId().equals(cartItemId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Cart item not found with id: " + cartItemId));
        
        // Check stock
        Product product = cartItem.getProduct();
        if (product.getStock() < newQuantity) {
            throw new RuntimeException("Insufficient stock! Available: " + product.getStock() + ", Requested: " + newQuantity);
        }
        
        cartItem.setQuantity(newQuantity);
        cartItemRepository.save(cartItem);
        
        return cartRepository.save(cart);
    }
    
    /**
     * Remove item from cart
     */
    public Cart removeItemFromCart(Long userId, Long cartItemId) {
        Cart cart = getOrCreateCart(userId);
        
        CartItem cartItem = cart.getItems().stream()
                .filter(item -> item.getId().equals(cartItemId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Cart item not found with id: " + cartItemId));
        
        cart.removeItem(cartItem);
        cartItemRepository.delete(cartItem);
        
        return cartRepository.save(cart);
    }
    
    /**
     * Clear all items from cart
     */
    public void clearCart(Long userId) {
        Cart cart = getOrCreateCart(userId);
        
        // Delete all cart items
        for (CartItem item : cart.getItems()) {
            cartItemRepository.delete(item);
        }
        
        cart.clearCart();
        cartRepository.save(cart);
    }
    
    /**
     * Get cart summary with totals
     */
    public Map<String, Object> getCartSummary(Long userId) {
        Cart cart = getOrCreateCart(userId);
        
        Map<String, Object> summary = new HashMap<>();
        summary.put("cartId", cart.getId());
        summary.put("userId", userId);
        summary.put("itemCount", cart.getItems().size());
        summary.put("totalQuantity", cart.getTotalQuantity());
        summary.put("totalPrice", cart.getTotalPrice());
        summary.put("items", cart.getItems());
        summary.put("createdAt", cart.getCreatedAt());
        summary.put("updatedAt", cart.getUpdatedAt());
        
        return summary;
    }
    
    /**
     * Get simplified cart response (for responses)
     */
    public Map<String, Object> getCartResponse(Cart cart) {
        Map<String, Object> response = new HashMap<>();
        response.put("cartId", cart.getId());
        response.put("userId", cart.getUser().getId());
        response.put("itemCount", cart.getItems().size());
        response.put("totalQuantity", cart.getTotalQuantity());
        response.put("totalPrice", cart.getTotalPrice());
        response.put("items", cart.getItems());
        response.put("createdAt", cart.getCreatedAt());
        response.put("updatedAt", cart.getUpdatedAt());
        
        return response;
    }
}
