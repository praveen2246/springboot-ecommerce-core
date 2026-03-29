package com.ecommerce.controller;

import com.ecommerce.model.Cart;
import com.ecommerce.service.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/cart")
@CrossOrigin(origins = "*")
public class CartController {
    
    @Autowired
    private CartService cartService;
    
    /**
     * GET cart for a user (create if doesn't exist)
     * URL: GET http://localhost:8080/api/cart/1
     */
    @GetMapping("/{userId}")
    public ResponseEntity<?> getCart(@PathVariable Long userId) {
        try {
            Cart cart = cartService.getOrCreateCart(userId);
            return ResponseEntity.ok(cartService.getCartResponse(cart));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * GET cart summary with totals
     * URL: GET http://localhost:8080/api/cart/1/summary
     */
    @GetMapping("/{userId}/summary")
    public ResponseEntity<?> getCartSummary(@PathVariable Long userId) {
        try {
            Map<String, Object> summary = cartService.getCartSummary(userId);
            return ResponseEntity.ok(summary);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * ADD item to cart
     * URL: POST http://localhost:8080/api/cart/items
     * Body: {
     *   "userId": 1,
     *   "productId": 1,
     *   "quantity": 2
     * }
     */
    @PostMapping("/items")
    public ResponseEntity<?> addItemToCart(@RequestBody Map<String, Object> request) {
        try {
            Long userId = Long.parseLong(request.get("userId").toString());
            Long productId = Long.parseLong(request.get("productId").toString());
            Integer quantity = Integer.parseInt(request.get("quantity").toString());
            
            Cart updatedCart = cartService.addItemToCart(userId, productId, quantity);
            return ResponseEntity.status(HttpStatus.CREATED).body(cartService.getCartResponse(updatedCart));
        } catch (NumberFormatException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Invalid input format. Ensure userId, productId are numbers and quantity is an integer.");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * UPDATE item quantity in cart
     * URL: PUT http://localhost:8080/api/cart/items/1
     * Body: {
     *   "userId": 1,
     *   "newQuantity": 5
     * }
     */
    @PutMapping("/items/{cartItemId}")
    public ResponseEntity<?> updateItemQuantity(
            @PathVariable Long cartItemId,
            @RequestBody Map<String, Object> request) {
        try {
            Long userId = Long.parseLong(request.get("userId").toString());
            Integer newQuantity = Integer.parseInt(request.get("newQuantity").toString());
            
            Cart updatedCart = cartService.updateItemQuantity(userId, cartItemId, newQuantity);
            return ResponseEntity.ok(cartService.getCartResponse(updatedCart));
        } catch (NumberFormatException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Invalid input format. Ensure userId is a number and newQuantity is an integer.");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * REMOVE item from cart
     * URL: DELETE http://localhost:8080/api/cart/items/1?userId=1
     */
    @DeleteMapping("/items/{cartItemId}")
    public ResponseEntity<?> removeItemFromCart(
            @PathVariable Long cartItemId,
            @RequestParam Long userId) {
        try {
            Cart updatedCart = cartService.removeItemFromCart(userId, cartItemId);
            return ResponseEntity.ok(cartService.getCartResponse(updatedCart));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * CLEAR cart
     * URL: DELETE http://localhost:8080/api/cart/1/clear
     */
    @DeleteMapping("/{userId}/clear")
    public ResponseEntity<?> clearCart(@PathVariable Long userId) {
        try {
            cartService.clearCart(userId);
            return ResponseEntity.ok("Cart cleared successfully for user: " + userId);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
}
