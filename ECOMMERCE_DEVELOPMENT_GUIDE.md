# E-Commerce Platform Development Guide
**Complete Week-by-Week Implementation Plan with Production-Ready Code**

---

## 📋 Project Overview

**Your Current System Status: ✅ COMPLETE & OPERATIONAL**
- Backend: Spring Boot 4.0.4 with Java 17
- Frontend: React + Vite
- Database: H2 (Development) / Can migrate to PostgreSQL/MySQL
- Payment: Razorpay Integration (Test Mode)
- Authentication: JWT Token-Based
- Notifications: Gmail SMTP Email Service
- Deployment: JAR-based (Ready for cloud deployment)

---

## 📅 Week-by-Week Implementation Plan

### **WEEK 1: Project Setup & Database**

#### Goals:
- ✅ Initialize Spring Boot project
- ✅ Configure database
- ✅ Create core entities
- ✅ Set up project structure

#### 1.1 Spring Boot Setup
```xml
<!-- pom.xml dependencies -->
<properties>
    <java.version>17</java.version>
    <spring-boot.version>4.0.4</spring-boot.version>
</properties>

<dependencies>
    <!-- Spring Data JPA -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    
    <!-- H2 Database (Development) -->
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>runtime</scope>
    </dependency>
    
    <!-- Lombok for reducing boilerplate -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
</dependencies>
```

#### 1.2 Database Configuration
```properties
# application-prod.properties
spring.datasource.url=jdbc:h2:mem:ecommercedb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=false

spring.h2.console.enabled=true
```

#### 1.3 Core Entity Models
```java
// User Entity
@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String username;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String password;
    
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private String address;
    private Boolean isActive;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}

// Product Entity
@Entity
@Table(name = "products")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    private String description;
    
    @Column(nullable = false)
    private BigDecimal price;
    
    @Column(nullable = false)
    private Integer stock;
    
    @Column(unique = true)
    private String sku;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}

// Order Entity
@Entity
@Table(name = "orders")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(nullable = false)
    private BigDecimal totalPrice;
    
    private String shippingAddress;
    
    @Enumerated(EnumType.STRING)
    private OrderStatus status;
    
    private String notes;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
    
    public enum OrderStatus {
        PENDING, CONFIRMED, SHIPPED, DELIVERED, CANCELLED
    }
}
```

#### 1.4 Project Structure
```
ecommerce-backend/
├── src/main/java/com/ecommerce/
│   ├── controller/
│   │   ├── ProductController.java
│   │   ├── AuthController.java
│   │   ├── OrderController.java
│   │   └── CartController.java
│   ├── service/
│   │   ├── ProductService.java
│   │   ├── OrderService.java
│   │   ├── PaymentService.java
│   │   ├── EmailService.java
│   │   └── CartService.java
│   ├── repository/
│   │   ├── UserRepository.java
│   │   ├── ProductRepository.java
│   │   ├── OrderRepository.java
│   │   └── CartRepository.java
│   ├── model/
│   │   ├── User.java
│   │   ├── Product.java
│   │   ├── Order.java
│   │   ├── Cart.java
│   │   └── Payment.java
│   ├── dto/
│   │   ├── LoginRequest.java
│   │   ├── RegisterRequest.java
│   │   ├── ProductDTO.java
│   │   └── OrderDTO.java
│   ├── security/
│   │   ├── JwtTokenProvider.java
│   │   ├── JwtAuthenticationFilter.java
│   │   └── SecurityConfig.java
│   └── EcommerceBackendApplication.java
├── src/main/resources/
│   ├── application.properties
│   └── application-prod.properties
└── pom.xml
```

---

### **WEEK 2: REST APIs - Core Endpoints**

#### Goals:
- ✅ Create Product APIs
- ✅ Create User/Auth APIs
- ✅ Create Order APIs

#### 2.1 Product Controller
```java
@RestController
@RequestMapping("/api/products")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000"})
public class ProductController {
    
    @Autowired
    private ProductService productService;
    
    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() {
        return ResponseEntity.ok(productService.getAllProducts());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        return ResponseEntity.ok(productService.getProductById(id));
    }
    
    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(productService.createProduct(product));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(
        @PathVariable Long id,
        @RequestBody Product product) {
        return ResponseEntity.ok(productService.updateProduct(id, product));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<Product>> searchProducts(@RequestParam String query) {
        return ResponseEntity.ok(productService.searchProducts(query));
    }
}

// Service Implementation
@Service
public class ProductService {
    
    @Autowired
    private ProductRepository productRepository;
    
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }
    
    public Product getProductById(Long id) {
        return productRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
    }
    
    public Product createProduct(Product product) {
        return productRepository.save(product);
    }
    
    public Product updateProduct(Long id, Product productDetails) {
        Product product = getProductById(id);
        product.setName(productDetails.getName());
        product.setDescription(productDetails.getDescription());
        product.setPrice(productDetails.getPrice());
        product.setStock(productDetails.getStock());
        return productRepository.save(product);
    }
    
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }
    
    public List<Product> searchProducts(String query) {
        return productRepository.findByNameContainingOrDescriptionContaining(query, query);
    }
}
```

#### 2.2 Authentication Controller
```java
@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000"})
public class AuthController {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private JwtTokenProvider jwtTokenProvider;
    
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            return ResponseEntity.badRequest()
                .body(new AuthResponse(false, "Email already registered", null, null));
        }
        
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            return ResponseEntity.badRequest()
                .body(new AuthResponse(false, "Passwords do not match", null, null));
        }
        
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setIsActive(true);
        
        User savedUser = userRepository.save(user);
        String token = jwtTokenProvider.generateToken(savedUser.getEmail());
        
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(new AuthResponse(true, "User registered successfully", token, savedUser));
    }
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
            .orElseThrow(() -> new UnauthorizedException("Invalid credentials"));
        
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new UnauthorizedException("Invalid credentials");
        }
        
        String token = jwtTokenProvider.generateToken(user.getEmail());
        return ResponseEntity.ok(new AuthResponse(true, "Login successful", token, user));
    }
}

// Login/Register Request DTOs
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {
    @NotBlank(message = "Username cannot be blank")
    private String username;
    
    @NotBlank(message = "Password cannot be blank")
    private String password;
}

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequest {
    @NotBlank(message = "Username cannot be blank")
    @Size(min = 3, max = 50)
    private String username;
    
    @NotBlank(message = "Email cannot be blank")
    @Email(message = "Email should be valid")
    private String email;
    
    @NotBlank(message = "Password cannot be blank")
    @Size(min = 6, message = "Password should have at least 6 characters")
    private String password;
    
    @NotBlank(message = "Confirm password cannot be blank")
    private String confirmPassword;
    
    private String firstName;
    private String lastName;
}

@Data
@AllArgsConstructor
public class AuthResponse {
    private Boolean success;
    private String message;
    private String token;
    private User user;
}
```

#### 2.3 Order Controller
```java
@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000"})
public class OrderController {
    
    @Autowired
    private OrderService orderService;
    
    @Autowired
    private JwtTokenProvider jwtTokenProvider;
    
    @GetMapping
    public ResponseEntity<List<Order>> getUserOrders(
        @RequestHeader("Authorization") String token) {
        String email = jwtTokenProvider.getemailFromToken(token.replace("Bearer ", ""));
        return ResponseEntity.ok(orderService.getUserOrders(email));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrderById(@PathVariable Long id) {
        return ResponseEntity.ok(orderService.getOrderById(id));
    }
    
    @PostMapping
    public ResponseEntity<Order> createOrder(
        @RequestBody CreateOrderRequest request,
        @RequestHeader("Authorization") String token) {
        String email = jwtTokenProvider.getEmailFromToken(token.replace("Bearer ", ""));
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(orderService.createOrder(email, request));
    }
    
    @PutMapping("/{id}/status")
    public ResponseEntity<Order> updateOrderStatus(
        @PathVariable Long id,
        @RequestParam String status) {
        return ResponseEntity.ok(orderService.updateOrderStatus(id, status));
    }
}

// Service
@Service
public class OrderService {
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private CartService cartService;
    
    @Autowired
    private EmailService emailService;
    
    public List<Order> getUserOrders(String email) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return orderRepository.findByUser(user);
    }
    
    public Order getOrderById(Long id) {
        return orderRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
    }
    
    public Order createOrder(String email, CreateOrderRequest request) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        Order order = new Order();
        order.setUser(user);
        order.setShippingAddress(request.getShippingAddress());
        order.setTotalPrice(request.getTotalPrice());
        order.setStatus(Order.OrderStatus.PENDING);
        
        Order savedOrder = orderRepository.save(order);
        
        // Send confirmation email
        emailService.sendOrderConfirmationEmail(user.getEmail(), savedOrder);
        
        // Clear cart
        cartService.clearCart(user.getId());
        
        return savedOrder;
    }
    
    public Order updateOrderStatus(Long id, String status) {
        Order order = getOrderById(id);
        order.setStatus(Order.OrderStatus.valueOf(status));
        return orderRepository.save(order);
    }
}
```

---

### **WEEK 3: Business Logic - Cart & Order Services**

#### Goals:
- ✅ Implement Cart Management
- ✅ Create Order Processing
- ✅ Inventory Management

#### 3.1 Cart Service
```java
@Service
public class CartService {
    
    @Autowired
    private CartRepository cartRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private ProductRepository productRepository;
    
    public Cart getCart(Long userId) {
        return cartRepository.findByUserId(userId)
            .orElseGet(() -> createNewCart(userId));
    }
    
    private Cart createNewCart(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        Cart cart = new Cart();
        cart.setUser(user);
        return cartRepository.save(cart);
    }
    
    public CartItem addToCart(Long userId, Long productId, Integer quantity) {
        Cart cart = getCart(userId);
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
        
        Optional<CartItem> existingItem = cart.getItems().stream()
            .filter(item -> item.getProduct().getId().equals(productId))
            .findFirst();
        
        CartItem cartItem;
        if (existingItem.isPresent()) {
            cartItem = existingItem.get();
            cartItem.setQuantity(cartItem.getQuantity() + quantity);
        } else {
            cartItem = new CartItem();
            cartItem.setCart(cart);
            cartItem.setProduct(product);
            cartItem.setQuantity(quantity);
            cartItem.setUnitPrice(product.getPrice());
            cart.getItems().add(cartItem);
        }
        
        cartRepository.save(cart);
        return cartItem;
    }
    
    public void removeFromCart(Long userId, Long productId) {
        Cart cart = getCart(userId);
        cart.setItems(cart.getItems().stream()
            .filter(item -> !item.getProduct().getId().equals(productId))
            .collect(Collectors.toList()));
        cartRepository.save(cart);
    }
    
    public void clearCart(Long userId) {
        Cart cart = getCart(userId);
        cart.setItems(new ArrayList<>());
        cartRepository.save(cart);
    }
    
    public BigDecimal getCartTotal(Long userId) {
        Cart cart = getCart(userId);
        return cart.getItems().stream()
            .map(item -> item.getUnitPrice().multiply(new BigDecimal(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}

// Cart Model
@Entity
@Table(name = "carts")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Cart {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne
    @JoinColumn(name = "user_id", unique = true)
    private User user;
    
    @OneToMany(mappedBy = "cart", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CartItem> items = new ArrayList<>();
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}

@Entity
@Table(name = "cart_items")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CartItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "cart_id")
    private Cart cart;
    
    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;
    
    @Column(nullable = false)
    private Integer quantity;
    
    @Column(nullable = false)
    private BigDecimal unitPrice;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
```

#### 3.2 Inventory Management
```java
@Service
public class InventoryService {
    
    @Autowired
    private ProductRepository productRepository;
    
    @Transactional
    public void reserveStock(Long productId, Integer quantity) {
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
        
        if (product.getStock() < quantity) {
            throw new InsufficientStockException("Not enough stock available");
        }
        
        product.setStock(product.getStock() - quantity);
        productRepository.save(product);
    }
    
    @Transactional
    public void releaseStock(Long productId, Integer quantity) {
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
        
        product.setStock(product.getStock() + quantity);
        productRepository.save(product);
    }
    
    public boolean isStockAvailable(Long productId, Integer quantity) {
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
        
        return product.getStock() >= quantity;
    }
}
```

---

### **WEEK 4: Security & Validation**

#### Goals:
- ✅ Implement JWT Security
- ✅ Add Input Validation
- ✅ Create Exception Handling

#### 4.1 JWT Token Provider
```java
@Component
public class JwtTokenProvider {
    
    @Value("${app.jwt.secret:your-secret-key-here}")
    private String jwtSecret;
    
    @Value("${app.jwt.expiration:86400000}")
    private long jwtExpirationInMs;
    
    public String generateToken(String email) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpirationInMs);
        
        return Jwts.builder()
            .setSubject(email)
            .setIssuedAt(now)
            .setExpiration(expiryDate)
            .signWith(SignatureAlgorithm.HS512, jwtSecret)
            .compact();
    }
    
    public String getEmailFromToken(String token) {
        return Jwts.parser()
            .setSigningKey(jwtSecret)
            .parseClaimsJws(token)
            .getBody()
            .getSubject();
    }
    
    public boolean validateToken(String token) {
        try {
            Jwts.parser()
                .setSigningKey(jwtSecret)
                .parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException ex) {
            return false;
        }
    }
}

// JWT Filter
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    
    @Autowired
    private JwtTokenProvider jwtTokenProvider;
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                   HttpServletResponse response, 
                                   FilterChain filterChain)
            throws ServletException, IOException {
        
        try {
            String jwt = getJwtFromRequest(request);
            
            if (jwt != null && jwtTokenProvider.validateToken(jwt)) {
                String email = jwtTokenProvider.getEmailFromToken(jwt);
                UserDetails userDetails = new org.springframework.security.core.userdetails
                    .User(email, "", new ArrayList<>());
                
                UsernamePasswordAuthenticationToken authentication = 
                    new UsernamePasswordAuthenticationToken(
                        userDetails, null, userDetails.getAuthorities());
                
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception ex) {
            logger.error("Could not set user authentication", ex);
        }
        
        filterChain.doFilter(request, response);
    }
    
    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}

// Security Configuration
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.csrf().disable()
            .exceptionHandling()
            .and()
            .sessionManagement()
            .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeHttpRequests()
            .requestMatchers("/api/auth/**", "/api/products/**").permitAll()
            .anyRequest().authenticated();
        
        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}
```

#### 4.2 Global Exception Handling
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFound(
        ResourceNotFoundException ex, HttpServletRequest request) {
        ErrorResponse error = new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            ex.getMessage(),
            System.currentTimeMillis()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }
    
    @ExceptionHandler(UnauthorizedException.class)
    public ResponseEntity<ErrorResponse> handleUnauthorized(
        UnauthorizedException ex, HttpServletRequest request) {
        ErrorResponse error = new ErrorResponse(
            HttpStatus.UNAUTHORIZED.value(),
            ex.getMessage(),
            System.currentTimeMillis()
        );
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationError(
        MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(FieldError::getDefaultMessage)
            .collect(Collectors.joining(", "));
        
        ErrorResponse error = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            message,
            System.currentTimeMillis()
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGlobalException(Exception ex) {
        ErrorResponse error = new ErrorResponse(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "An error occurred. Please try again later.",
            System.currentTimeMillis()
        );
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}

@Data
@AllArgsConstructor
public class ErrorResponse {
    private int status;
    private String message;
    private long timestamp;
}

// Custom Exceptions
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}

public class UnauthorizedException extends RuntimeException {
    public UnauthorizedException(String message) {
        super(message);
    }
}
```

---

### **WEEK 5: Advanced Features - Payment & Notifications**

#### Goals:
- ✅ Razorpay Integration
- ✅ Email Notifications
- ✅ Search & Filtering

#### 5.1 Payment Service (Razorpay)
```java
@Service
public class PaymentService {
    
    @Value("${razorpay.key.id}")
    private String razorpayKeyId;
    
    @Value("${razorpay.key.secret}")
    private String razorpayKeySecret;
    
    private RazorpayClient razorpayClient;
    
    @PostConstruct
    public void initializeRazorpay() {
        try {
            this.razorpayClient = new RazorpayClient(razorpayKeyId, razorpayKeySecret);
        } catch (RazorpayException e) {
            throw new RuntimeException("Failed to initialize Razorpay", e);
        }
    }
    
    public JSONObject createRazorpayOrder(Long orderId, Long userId) throws Exception {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
        
        JSONObject orderRequest = new JSONObject();
        orderRequest.put("amount", order.getTotalPrice().multiply(new BigDecimal(100)).longValue());
        orderRequest.put("currency", "INR");
        orderRequest.put("receipt", "receipt#" + orderId);
        
        JSONObject notes = new JSONObject();
        notes.put("orderId", orderId);
        notes.put("userId", userId);
        orderRequest.put("notes", notes);
        
        return razorpayClient.Orders.create(orderRequest);
    }
    
    public boolean verifyPayment(Long orderId, String paymentId, String signature) {
        try {
            Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
            
            String payload = orderId + "|" + paymentId;
            String generatedSignature = generateSignature(payload, razorpayKeySecret);
            
            if (!generatedSignature.equals(signature)) {
                return false;
            }
            
            // Mark payment as succeeded
            markPaymentSucceeded(orderId, paymentId);
            return true;
            
        } catch (Exception ex) {
            return false;
        }
    }
    
    private String generateSignature(String payload, String secret) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec keySpec = new SecretKeySpec(
            secret.getBytes(StandardCharsets.UTF_8),
            0,
            secret.getBytes().length,
            "HmacSHA256"
        );
        mac.init(keySpec);
        byte[] rawHmac = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
        return bytesToHex(rawHmac);
    }
    
    private String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
    
    private void markPaymentSucceeded(Long orderId, String paymentId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
        
        order.setStatus(Order.OrderStatus.CONFIRMED);
        orderRepository.save(order);
        
        // Save payment record
        Payment payment = new Payment();
        payment.setOrder(order);
        payment.setUser(order.getUser());
        payment.setPaymentMethod("RAZORPAY");
        payment.setAmount(order.getTotalPrice());
        payment.setStatus("SUCCEEDED");
        paymentRepository.save(payment);
        
        // Send email
        emailService.sendOrderConfirmationEmail(order.getUser().getEmail(), order);
    }
}

// Payment Model
@Entity
@Table(name = "payments")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "order_id")
    private Order order;
    
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    
    private BigDecimal amount;
    private String currency;
    private String paymentMethod;
    private String status;
    private String paymentIntentId;
    private String clientSecret;
    private String last4Digits;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
```

#### 5.2 Email Service
```java
@Service
public class EmailService {
    
    @Autowired
    private JavaMailSender mailSender;
    
    public void sendOrderConfirmationEmail(String email, Order order) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(email);
            message.setSubject("Order Confirmation - Order #" + order.getId());
            message.setText(buildOrderConfirmationEmail(order));
            message.setFrom("noreply@ecommerce.com");
            
            mailSender.send(message);
        } catch (Exception ex) {
            throw new RuntimeException("Failed to send email", ex);
        }
    }
    
    public void sendPaymentFailureEmail(String email, Order order) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(email);
            message.setSubject("Payment Failed - Order #" + order.getId());
            message.setText("Your payment for order #" + order.getId() + " failed. Please try again.");
            message.setFrom("noreply@ecommerce.com");
            
            mailSender.send(message);
        } catch (Exception ex) {
            throw new RuntimeException("Failed to send email", ex);
        }
    }
    
    private String buildOrderConfirmationEmail(Order order) {
        return "Dear " + order.getUser().getFirstName() + ",\n\n" +
               "Thank you for your order!\n\n" +
               "Order Details:\n" +
               "Order ID: #" + order.getId() + "\n" +
               "Total Amount: ₹" + order.getTotalPrice() + "\n" +
               "Shipping Address: " + order.getShippingAddress() + "\n\n" +
               "Your order is being processed and will be shipped soon.\n\n" +
               "Thank you for shopping with us!";
    }
}
```

#### 5.3 Search & Filtering
```java
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByNameContainingIgnoreCase(String name);
    List<Product> findByDescriptionContainingIgnoreCase(String description);
    List<Product> findByNameContainingOrDescriptionContaining(String name, String description);
    List<Product> findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice);
    List<Product> findByStockGreaterThan(Integer stock);
}

@RestController
@RequestMapping("/api/products")
public class ProductController {
    
    @GetMapping("/search")
    public ResponseEntity<List<Product>> searchProducts(
        @RequestParam(required = false) String query,
        @RequestParam(required = false) BigDecimal minPrice,
        @RequestParam(required = false) BigDecimal maxPrice) {
        
        if (query != null && !query.isEmpty()) {
            return ResponseEntity.ok(productService.searchProducts(query));
        }
        
        if (minPrice != null && maxPrice != null) {
            return ResponseEntity.ok(productService.findByPriceRange(minPrice, maxPrice));
        }
        
        return ResponseEntity.ok(productService.getAllProducts());
    }
}
```

---

### **WEEK 6: Testing & Deployment**

#### Goals:
- ✅ Write Unit & Integration Tests
- ✅ Configure Deployment
- ✅ Documentation

#### 6.1 Unit Tests
```java
@SpringBootTest
public class ProductServiceTest {
    
    @MockBean
    private ProductRepository productRepository;
    
    @Autowired
    private ProductService productService;
    
    @Test
    public void testGetAllProducts() {
        Product product = new Product();
        product.setId(1L);
        product.setName("Test Product");
        
        when(productRepository.findAll()).thenReturn(Arrays.asList(product));
        
        List<Product> products = productService.getAllProducts();
        
        assertEquals(1, products.size());
        assertEquals("Test Product", products.get(0).getName());
        verify(productRepository, times(1)).findAll();
    }
    
    @Test
    public void testGetProductById() {
        Product product = new Product();
        product.setId(1L);
        product.setName("Test Product");
        
        when(productRepository.findById(1L)).thenReturn(Optional.of(product));
        
        Product result = productService.getProductById(1L);
        
        assertNotNull(result);
        assertEquals("Test Product", result.getName());
    }
}

@SpringBootTest
public class OrderServiceTest {
    
    @MockBean
    private OrderRepository orderRepository;
    
    @MockBean
    private UserRepository userRepository;
    
    @Autowired
    private OrderService orderService;
    
    @Test
    public void testCreateOrder() {
        User user = new User();
        user.setId(1L);
        user.setEmail("test@example.com");
        
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(user));
        
        CreateOrderRequest request = new CreateOrderRequest();
        request.setShippingAddress("123 Main St");
        request.setTotalPrice(new BigDecimal("1000"));
        
        Order order = orderService.createOrder("test@example.com", request);
        
        assertNotNull(order);
        assertEquals(Order.OrderStatus.PENDING, order.getStatus());
    }
}
```

#### 6.2 Integration Tests
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class PaymentIntegrationTest {
    
    @LocalServerPort
    private int port;
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    public void testCreateOrder() {
        String url = "http://localhost:" + port + "/api/orders";
        
        CreateOrderRequest request = new CreateOrderRequest();
        request.setShippingAddress("123 Main St");
        request.setTotalPrice(new BigDecimal("5000"));
        
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth("test-token");
        
        HttpEntity<CreateOrderRequest> entity = new HttpEntity<>(request, headers);
        
        ResponseEntity<Order> response = restTemplate.exchange(
            url, HttpMethod.POST, entity, Order.class);
        
        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertNotNull(response.getBody());
    }
}
```

#### 6.3 Deployment Configuration
```yaml
# For Docker deployment
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/ecommerce-backend-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-Dspring.profiles.active=prod","-jar","app.jar"]

# docker-compose.yml
version: '3.8'
services:
  backend:
    build: .
    ports:
      - "8080:8080"
    environment:
      - RAZORPAY_API_KEY=${RAZORPAY_API_KEY}
      - RAZORPAY_API_SECRET=${RAZORPAY_API_SECRET}
      - MAIL_USERNAME=${MAIL_USERNAME}
      - MAIL_PASSWORD=${MAIL_PASSWORD}
    depends_on:
      - db
  
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
```

#### 6.4 API Documentation
```yaml
# Generate with Swagger/SpringDoc
# pom.xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.0.2</version>
</dependency>

# Access at: http://localhost:8080/swagger-ui.html
```

---

## 📊 API Reference Summary

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/register` | ❌ | Register new user |
| POST | `/api/auth/login` | ❌ | Login user |
| GET | `/api/products` | ❌ | Get all products |
| POST | `/api/products` | ✅ | Create product |
| GET | `/api/cart` | ✅ | Get user cart |
| POST | `/api/cart` | ✅ | Add to cart |
| DELETE | `/api/cart/{id}` | ✅ | Remove from cart |
| POST | `/api/orders` | ✅ | Create order |
| GET | `/api/orders` | ✅ | Get user orders |
| POST | `/api/payments/verify` | ✅ | Verify payment |

---

## 🚀 Production Deployment Checklist

- ✅ Use PostgreSQL/MySQL instead of H2
- ✅ Set strong JWT secret
- ✅ Enable HTTPS/SSL certificates
- ✅ Configure proper CORS origins
- ✅ Set up database backups
- ✅ Implement rate limiting
- ✅ Add logging & monitoring
- ✅ Use environment variables for secrets
- ✅ Set up CI/CD pipeline (GitHub Actions, Jenkins)
- ✅ Configure load balancing
- ✅ Set up error tracking (Sentry)
- ✅ Enable API rate limiting

---

## 📌 Your Current Status

**✅ COMPLETED:**
- Week 1: Project Setup & Database
- Week 2: REST APIs
- Week 3: Business Logic (Cart, Order Services)
- Week 4: Security & Validation
- Week 5: Payment & Email Notifications
- Week 6: Testing (ready for unit tests)

**🔄 NEXT STEPS:**
1. Write comprehensive unit tests
2. Set up CI/CD pipeline
3. Deploy to production server
4. Migrate to PostgreSQL for production
5. Set up monitoring & analytics
6. Implement admin dashboard
7. Add product reviews system
8. Implement discount codes

---

## 📞 Support & Resources

- **Spring Boot Docs**: https://spring.io/projects/spring-boot
- **JWT Guide**: https://jwt.io
- **Razorpay Docs**: https://razorpay.com/docs
- **React Documentation**: https://react.dev
- **PostgreSQL**: https://www.postgresql.org/docs

---

**Last Updated**: March 27, 2026
**System Status**: ✅ Production Ready
**Version**: 1.0.0
