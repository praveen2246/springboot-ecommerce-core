package com.ecommerce.config;

import com.ecommerce.model.User;
import com.ecommerce.model.Cart;
import com.ecommerce.model.CartItem;
import com.ecommerce.model.Product;
import com.ecommerce.model.Order;
import com.ecommerce.repository.UserRepository;
import com.ecommerce.repository.CartRepository;
import com.ecommerce.repository.CartItemRepository;
import com.ecommerce.repository.ProductRepository;
import com.ecommerce.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import java.time.LocalDateTime;
import java.math.BigDecimal;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {
    
    private final UserRepository userRepository;
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;
    private final OrderRepository orderRepository;
    private final PasswordEncoder passwordEncoder;
    
    @Override
    public void run(String... args) {
        initializeTestUser();
        initializeTestData();
    }
    
    private void initializeTestUser() {
        // Check if test user already exists
        if (userRepository.existsByEmail("praveen@example.com")) {
            return;
        }
        
        User testUser = new User();
        testUser.setUsername("praveen");
        testUser.setEmail("praveen@example.com");
        testUser.setPassword(passwordEncoder.encode("password123"));
        testUser.setFirstName("Praveen");
        testUser.setLastName("Test");
        testUser.setIsActive(true);
        testUser.setCreatedAt(LocalDateTime.now());
        testUser.setUpdatedAt(LocalDateTime.now());
        
        userRepository.save(testUser);
    }
    
    private void initializeTestData() {
        // Check if test data already exists
        User testUser = userRepository.findByEmail("praveen@example.com").orElse(null);
        if (testUser == null) {
            return;
        }
        
        // Create test cart if not exists
        if (!cartRepository.existsByUser(testUser)) {
            Cart cart = new Cart();
            cart.setUser(testUser);
            cart.setCreatedAt(LocalDateTime.now());
            cart.setUpdatedAt(LocalDateTime.now());
            cartRepository.save(cart);
        }
        
        // Create test order if not exists
        if (orderRepository.findByUser(testUser).isEmpty()) {
            Order order = new Order();
            order.setUser(testUser);
            order.setStatus(Order.OrderStatus.PENDING);
            order.setTotalPrice(new BigDecimal("5000.00"));
            order.setShippingAddress("SS Colony, Madurai");
            order.setNotes("Test order for payment testing");
            order.setCreatedAt(LocalDateTime.now());
            order.setUpdatedAt(LocalDateTime.now());
            orderRepository.save(order);
        }
    }
}
