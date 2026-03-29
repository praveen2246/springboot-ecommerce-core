package com.ecommerce.service;

import com.ecommerce.model.*;
import com.ecommerce.repository.OrderRepository;
import com.ecommerce.repository.OrderItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;

@Service
@Transactional
public class OrderService {
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private OrderItemRepository orderItemRepository;
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private CartService cartService;
    
    @Autowired
    private ProductService productService;
    
    /**
     * Create order from cart items
     */
    public Order createOrderFromCart(Long userId, String shippingAddress, String notes) {
        // Get user
        User user = userService.getUserById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        // Get cart for user
        Cart cart = cartService.getOrCreateCart(userId);
        
        if (cart.getItems().isEmpty()) {
            throw new RuntimeException("Cannot create order from empty cart!");
        }
        
        // Create order
        Order order = new Order();
        order.setUser(user);
        order.setStatus(Order.OrderStatus.PENDING);
        order.setShippingAddress(shippingAddress != null ? shippingAddress : user.getAddress());
        order.setNotes(notes);
        
        // Create order items from cart items and deduct inventory
        for (CartItem cartItem : cart.getItems()) {
            Product product = cartItem.getProduct();
            
            // Check stock availability
            if (product.getStock() < cartItem.getQuantity()) {
                throw new RuntimeException("Insufficient stock for product: " + product.getName() + 
                    " (Available: " + product.getStock() + ", Requested: " + cartItem.getQuantity() + ")");
            }
            
            // Create order item
            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setProduct(product);
            orderItem.setQuantity(cartItem.getQuantity());
            orderItem.setUnitPrice(cartItem.getUnitPrice());
            
            // Deduct inventory
            product.setStock(product.getStock() - cartItem.getQuantity());
            productService.updateProductInventory(product.getId(), product.getStock());
            
            order.getItems().add(orderItem);
        }
        
        // Calculate total price
        order.setTotalPrice(order.calculateTotalPrice());
        
        // Save order
        Order savedOrder = orderRepository.save(order);
        
        // Clear cart after successful order creation
        cartService.clearCart(userId);
        
        return savedOrder;
    }
    
    /**
     * Get order by ID
     */
    public Optional<Order> getOrderById(Long orderId) {
        return orderRepository.findById(orderId);
    }
    
    /**
     * Get all orders for a user
     */
    public List<Order> getOrdersByUser(Long userId) {
        User user = userService.getUserById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        return orderRepository.findByUser(user);
    }
    
    /**
     * Get orders by user and status
     */
    public List<Order> getOrdersByUserAndStatus(Long userId, String status) {
        User user = userService.getUserById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        Order.OrderStatus orderStatus = Order.OrderStatus.valueOf(status.toUpperCase());
        return orderRepository.findByUserAndStatus(user, orderStatus);
    }
    
    /**
     * Get all orders with specific status
     */
    public List<Order> getOrdersByStatus(String status) {
        Order.OrderStatus orderStatus = Order.OrderStatus.valueOf(status.toUpperCase());
        return orderRepository.findByStatus(orderStatus);
    }
    
    /**
     * Update order status
     */
    public Order updateOrderStatus(Long orderId, String status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found with id: " + orderId));
        
        Order.OrderStatus newStatus = Order.OrderStatus.valueOf(status.toUpperCase());
        order.setStatus(newStatus);
        
        return orderRepository.save(order);
    }
    
    /**
     * Cancel order and restore inventory
     */
    public Order cancelOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found with id: " + orderId));
        
        if (order.getStatus() == Order.OrderStatus.CANCELLED) {
            throw new RuntimeException("Order is already cancelled!");
        }
        
        if (order.getStatus() == Order.OrderStatus.DELIVERED) {
            throw new RuntimeException("Cannot cancel delivered orders!");
        }
        
        // Restore inventory
        for (OrderItem item : order.getItems()) {
            Product product = item.getProduct();
            product.setStock(product.getStock() + item.getQuantity());
            productService.updateProductInventory(product.getId(), product.getStock());
        }
        
        order.setStatus(Order.OrderStatus.CANCELLED);
        return orderRepository.save(order);
    }
    
    /**
     * Get order summary with details
     */
    public Map<String, Object> getOrderSummary(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found with id: " + orderId));
        
        Map<String, Object> summary = new HashMap<>();
        summary.put("orderId", order.getId());
        summary.put("userId", order.getUser().getId());
        summary.put("status", order.getStatus().getDisplayName());
        summary.put("totalPrice", order.getTotalPrice());
        summary.put("totalQuantity", order.getTotalQuantity());
        summary.put("itemCount", order.getItems().size());
        summary.put("shippingAddress", order.getShippingAddress());
        summary.put("notes", order.getNotes());
        summary.put("items", order.getItems());
        summary.put("createdAt", order.getCreatedAt());
        summary.put("updatedAt", order.getUpdatedAt());
        
        return summary;
    }
}
