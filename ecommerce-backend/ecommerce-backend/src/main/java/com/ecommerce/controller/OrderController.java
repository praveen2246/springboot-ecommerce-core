package com.ecommerce.controller;

import com.ecommerce.model.Order;
import com.ecommerce.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {
    
    @Autowired
    private OrderService orderService;
    
    /**
     * GET order by ID
     * URL: GET http://localhost:8080/api/orders/1
     */
    @GetMapping("/{orderId}")
    public ResponseEntity<?> getOrder(@PathVariable Long orderId) {
        try {
            Optional<Order> order = orderService.getOrderById(orderId);
            if (order.isPresent()) {
                // Return order summary instead of raw entity
                Map<String, Object> summary = orderService.getOrderSummary(orderId);
                return ResponseEntity.ok(summary);
            }
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Order not found with id: " + orderId);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * GET all orders for a user (order history)
     * URL: GET http://localhost:8080/api/orders/user/1
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getUserOrders(@PathVariable Long userId) {
        try {
            List<Order> orders = orderService.getOrdersByUser(userId);
            Map<String, Object> response = Map.of(
                "userId", userId,
                "orderCount", orders.size(),
                "orders", orders
            );
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * GET orders by status
     * URL: GET http://localhost:8080/api/orders/status/pending
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<?> getOrdersByStatus(@PathVariable String status) {
        try {
            List<Order> orders = orderService.getOrdersByStatus(status);
            Map<String, Object> response = Map.of(
                "status", status,
                "orderCount", orders.size(),
                "orders", orders
            );
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * CREATE order from cart (CHECKOUT)
     * URL: POST http://localhost:8080/api/orders/checkout
     * Body: {
     *   "userId": 1,
     *   "shippingAddress": "123 Main St, City, State 12345",
     *   "notes": "Please deliver after 5 PM"
     * }
     */
    @PostMapping("/checkout")
    public ResponseEntity<?> checkoutOrder(@RequestBody Map<String, Object> request) {
        try {
            Long userId = Long.parseLong(request.get("userId").toString());
            String shippingAddress = (String) request.get("shippingAddress");
            String notes = (String) request.get("notes");
            
            Order order = orderService.createOrderFromCart(userId, shippingAddress, notes);
            Map<String, Object> summary = orderService.getOrderSummary(order.getId());
            
            return ResponseEntity.status(HttpStatus.CREATED).body(summary);
        } catch (NumberFormatException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Invalid input format. userId must be a number.");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * UPDATE order status
     * URL: PUT http://localhost:8080/api/orders/1/status
     * Body: {
     *   "status": "shipped"
     * }
     * Status options: PENDING, CONFIRMED, SHIPPED, DELIVERED, CANCELLED
     */
    @PutMapping("/{orderId}/status")
    public ResponseEntity<?> updateOrderStatus(
            @PathVariable Long orderId,
            @RequestBody Map<String, Object> request) {
        try {
            String status = (String) request.get("status");
            if (status == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("status field is required");
            }
            
            Order updatedOrder = orderService.updateOrderStatus(orderId, status);
            Map<String, Object> summary = orderService.getOrderSummary(orderId);
            
            return ResponseEntity.ok(summary);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
    
    /**
     * CANCEL order (restores inventory)
     * URL: DELETE http://localhost:8080/api/orders/1/cancel
     */
    @DeleteMapping("/{orderId}/cancel")
    public ResponseEntity<?> cancelOrder(@PathVariable Long orderId) {
        try {
            Order cancelledOrder = orderService.cancelOrder(orderId);
            Map<String, Object> summary = orderService.getOrderSummary(orderId);
            
            return ResponseEntity.ok(summary);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }
}
