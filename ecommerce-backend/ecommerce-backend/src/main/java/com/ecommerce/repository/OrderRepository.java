package com.ecommerce.repository;

import com.ecommerce.model.Order;
import com.ecommerce.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    
    // Find all orders for a user
    List<Order> findByUser(User user);
    
    // Find orders by user and status
    List<Order> findByUserAndStatus(User user, Order.OrderStatus status);
    
    // Find all orders with a specific status
    List<Order> findByStatus(Order.OrderStatus status);
}
