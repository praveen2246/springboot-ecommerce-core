# E-Commerce Platform - Complete Technical Documentation

**Author**: Praveen Kumar  
**Date**: March 2024  
**Version**: 1.0.0  
**Status**: Production-Ready

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Technical Requirements Met](#technical-requirements-met)
3. [Architecture & Design](#architecture--design)
4. [Setup & Installation](#setup--installation)
5. [Code Structure Explanation](#code-structure-explanation)
6. [Database Schema](#database-schema)
7. [API Endpoints Documentation](#api-endpoints-documentation)
8. [Security Implementation](#security-implementation)
9. [Testing Strategy](#testing-strategy)
10. [Deployment Guide](#deployment-guide)
11. [Development Guidelines](#development-guidelines)

---

## 🎯 Project Overview

### Objectives

This project demonstrates a **production-ready full-stack e-commerce platform** built using modern technologies:

**Primary Objectives:**
- ✅ Build a scalable, secure REST API with Spring Boot
- ✅ Create a responsive, user-friendly frontend with React
- ✅ Implement complete authentication & authorization system
- ✅ Integrate third-party payment processing (Razorpay)
- ✅ Enable email notifications for customer engagement
- ✅ Support advanced product search and filtering
- ✅ Deploy application using containerization (Docker)
- ✅ Implement CI/CD pipelines for automated testing & deployment

### Problem Statement

E-commerce businesses need:
- **Scalable Platform**: Handle growing customer base
- **Secure Transactions**: PCI-compliant payment processing
- **User Management**: Authentication, authorization, profiles
- **Product Discovery**: Search, filtering, categorization
- **Order Management**: Creation, tracking, history
- **Communication**: Email notifications, order confirmations

### Solution

A complete e-commerce platform with:
- **Spring Boot Backend**: RESTful API with 20+ endpoints
- **React Frontend**: Modern UI with real-time updates
- **PostgreSQL Database**: Normalized schema, 8 tables, proper relationships
- **Razorpay Integration**: Secure payment processing
- **Email Service**: Order confirmations and notifications
- **Docker Deployment**: Easy scaling and deployment
- **Monitoring & Logging**: Health checks, error tracking

---

## ✅ Technical Requirements Met

### 1. **Backend API Development**

**Requirement**: Build a functional REST API with CRUD operations

**Implementation**:
- ✅ **20+ API Endpoints** across 5 resource categories
  - Authentication: Register, Login, Validate
  - Products: List, Search, Filter by price/category
  - Cart: Add, Remove, Clear, View
  - Orders: Create, View history, Track status
  - Payments: Process, Verify, Track

**Code Example** - ProductController:
```java
@RestController
@RequestMapping("/api/products")
public class ProductController {
    
    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() { }
    
    @GetMapping("/search")
    public ResponseEntity<List<Product>> searchProducts(
        @RequestParam String keyword) { }
    
    @GetMapping("/filter/price")
    public ResponseEntity<List<Product>> filterByPrice(
        @RequestParam BigDecimal minPrice,
        @RequestParam BigDecimal maxPrice) { }
}
```

### 2. **Authentication & Security**

**Requirement**: Implement secure user authentication and authorization

**Implementation**:
- ✅ **JWT Token-based Authentication**
  - Tokens generated on login
  - Tokens validated on each request
  - Tokens expire after 24 hours
  - Refresh token support available

- ✅ **Spring Security Framework**
  - WebSecurityConfig secures all endpoints
  - Role-based access control (USER, ADMIN)
  - CORS configuration for frontend

- ✅ **Password Security**
  - BCrypt hashing (10 rounds)
  - Never store plain passwords
  - Validation: min 8 chars, uppercase, lowercase, number

**Code Example** - Security Configuration:
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) {
        http.authorizeHttpRequests(auth -> auth
            .requestMatchers("/api/auth/**").permitAll()
            .requestMatchers("/api/products/**").permitAll()
            .requestMatchers("/api/**").authenticated()
            .anyRequest().authenticated())
        .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(10);
    }
}
```

### 3. **Database Design**

**Requirement**: Design normalized database schema with proper relationships

**Implementation**:
- ✅ **8 Database Tables** with proper relationships
  - `users` - User accounts and profiles
  - `categories` - Product categories
  - `products` - Product catalog
  - `carts` - Shopping carts
  - `cart_items` - Items in carts (composite key)
  - `orders` - Customer orders
  - `order_items` - Items in orders
  - `payments` - Payment records

- ✅ **Proper Indexing**
  - Primary keys on all tables
  - Foreign keys for relationships
  - Indexes on frequently queried columns (email, product_id)

- ✅ **Data Integrity**
  - Unique constraints (email, order_number)
  - NOT NULL constraints on required fields
  - CHECK constraints for valid values

**Database Diagram**:
```
users (1) ─── (∞) carts (1) ─── (∞) cart_items ─── (∞) products
  ↓                                              
orders (1) ─── (∞) order_items ─── (∞) products
  ↓
payments (1:1)

categories (1) ─── (∞) products
```

### 4. **API Response Format & Error Handling**

**Requirement**: Consistent API responses with proper error handling

**Implementation**:
- ✅ **Standardized Response Format**
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

- ✅ **Error Responses**
```json
{
  "success": false,
  "error": "PRODUCT_NOT_FOUND",
  "message": "Product with ID 999 not found",
  "status": 404,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

- ✅ **Exception Handling**
  - Global exception handler (@ControllerAdvice)
  - Custom exceptions (ProductNotFoundException, etc.)
  - Proper HTTP status codes (200, 201, 400, 404, 500)

### 5. **Frontend Development**

**Requirement**: Build responsive, user-friendly interface

**Implementation**:
- ✅ **Core Pages**
  - Home/Landing page with featured products
  - Product catalog with search
  - Product detail page
  - Shopping cart
  - Checkout page
  - Order confirmation
  - User profile/orders history

- ✅ **UI Components**
  - Navigation bar with user menu
  - Product cards with images
  - Search bar with real-time filtering
  - Price range filter
  - Shopping cart modal
  - Login/Register forms
  - Order history table

- ✅ **Responsive Design**
  - Mobile-first approach (320px+)
  - Tablet optimization (768px+)
  - Desktop optimization (1024px+)
  - Touch-friendly buttons and inputs

### 6. **Payment Integration**

**Requirement**: Integrate third-party payment gateway

**Implementation**:
- ✅ **Razorpay Integration**
  - Test mode: rzp_test_SX0HsSL3fbdppU
  - Live mode ready (update credentials)
  - Webhook support for payment verification
  - Test cards provided (4111 1111 1111 1111)

- ✅ **Payment Flow**
  1. User clicks "Pay with Razorpay"
  2. Backend creates Razorpay order
  3. Frontend opens Razorpay modal
  4. User enters payment details
  5. Backend verifies payment signature
  6. Order marked as paid
  7. Confirmation email sent

**Code Example**:
```java
@PostMapping("/create-order")
public ResponseEntity<?> createRazorpayOrder(@RequestBody PaymentRequest request) {
    RazorpayClient client = new RazorpayClient(apiKey, apiSecret);
    JSONObject orderRequest = new JSONObject();
    orderRequest.put("amount", request.getAmount() * 100); // paise
    orderRequest.put("currency", "INR");
    orderRequest.put("receipt", "receipt#" + request.getOrderId());
    
    Order order = client.Orders.create(orderRequest);
    return ResponseEntity.ok(order);
}

@PostMapping("/verify")
public ResponseEntity<?> verifyPayment(@RequestBody PaymentVerification verification) {
    boolean isValid = verifySignature(
        verification.getOrderId(),
        verification.getPaymentId(),
        verification.getSignature()
    );
    
    if (isValid) {
        Order order = orderService.getOrder(verification.getOrderId());
        order.setStatus("PAID");
        orderService.saveOrder(order);
        emailService.sendConfirmation(order);
        return ResponseEntity.ok("Payment verified");
    }
    return ResponseEntity.status(400).body("Invalid payment");
}
```

### 7. **Search & Filtering**

**Requirement**: Implement advanced search and filtering capabilities

**Implementation**:
- ✅ **Product Search**
  - Case-insensitive keyword search
  - Searches product name and description
  - Real-time filtering as user types
  - Minimum 1 character to trigger search

- ✅ **Price Filtering**
  - Filter by minimum price
  - Filter by maximum price
  - Dynamic range based on product catalog
  - Combines with search results

- ✅ **Category Filtering**
  - Filter by product category
  - Multiple category selection
  - Combines with other filters

**Database Queries**:
```java
// Search
findByNameContainingIgnoreCase(String keyword)

// Price Filter
findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice)

// Category Filter
findByCategory_NameIgnoreCase(String category)

// Combined
findByNameContainingIgnoreCaseAndPriceBetween(
    String keyword, BigDecimal min, BigDecimal max)
```

### 8. **Email Notifications**

**Requirement**: Send email notifications for orders

**Implementation**:
- ✅ **Order Confirmation Email**
  - Sent after successful payment
  - Contains order details
  - Lists all items with prices
  - Includes customer information
  - Professional HTML template

- ✅ **Email Service**
  - Gmail SMTP configuration
  - Async processing (doesn't block order)
  - Error handling and retries
  - Fallback logging if email fails

**Code Example**:
```java
@Service
public class EmailService {
    
    @Async
    public void sendOrderConfirmation(Order order) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(order.getUser().getEmail());
        message.setSubject("Order Confirmation #" + order.getOrderNumber());
        message.setText(buildOrderConfirmationTemplate(order));
        mailSender.send(message);
    }
    
    private String buildOrderConfirmationTemplate(Order order) {
        // Build HTML email with order details
        return "<h1>Thank you for your order!</h1>" +
               "<p>Order #" + order.getOrderNumber() + "</p>" +
               "<p>Total: ₹" + order.getTotalAmount() + "</p>";
    }
}
```

### 9. **API Documentation**

**Requirement**: Document all API endpoints

**Implementation**:
- ✅ **Swagger/OpenAPI Integration**
  - Interactive API documentation
  - Try API calls directly from browser
  - Request/Response examples
  - Parameter descriptions
  - Available at http://localhost:8080/swagger-ui.html

- ✅ **Comprehensive Endpoint Documentation**
  - 20+ endpoints documented
  - Request/response examples
  - Error responses documented
  - Authentication requirements specified

### 10. **Deployment & DevOps**

**Requirement**: Deploy application using containers

**Implementation**:
- ✅ **Docker Containerization**
  - Dockerfile for backend (multi-stage build)
  - Dockerfile for frontend (Nginx + React)
  - Optimized images (~150MB backend, ~30MB frontend)
  - Health checks configured

- ✅ **Docker Compose**
  - Orchestrates backend, frontend, PostgreSQL
  - Volume management for data persistence
  - Environment variable configuration
  - Network communication between services

- ✅ **CI/CD Pipelines**
  - GitHub Actions workflows
  - Automated build on push
  - Automated tests on PR
  - Docker image build
  - Multi-environment support

---

## 🏗️ Architecture & Design

### System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Client Layer                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │     React + Vite Frontend (Port 5173)            │  │
│  │  - Components: Home, Products, Cart, Checkout   │  │
│  │  - Services: API calls, Authentication          │  │
│  │  - State: Context API for Auth & Theme          │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           ↓ HTTP/REST
┌─────────────────────────────────────────────────────────┐
│                   API Gateway Layer                      │
│  ┌──────────────────────────────────────────────────┐  │
│  │        Nginx Reverse Proxy (Port 80)             │  │
│  │  - Routes /api/* to backend                      │  │
│  │  - Serves static frontend files                  │  │
│  │  - SSL/TLS termination (production)              │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           ↓ HTTP/REST
┌─────────────────────────────────────────────────────────┐
│               Application Layer                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │   Spring Boot Backend (Port 8080)                │  │
│  │   ┌────────────────────────────────────────┐    │  │
│  │   │ Controller Layer                       │    │  │
│  │   │ - AuthController, ProductController   │    │  │
│  │   │ - OrderController, PaymentController  │    │  │
│  │   └────────────────────────────────────────┘    │  │
│  │   ┌────────────────────────────────────────┐    │  │
│  │   │ Service Layer                          │    │  │
│  │   │ - UserService, ProductService         │    │  │
│  │   │ - OrderService, PaymentService        │    │  │
│  │   │ - EmailService, RazorpayService       │    │  │
│  │   └────────────────────────────────────────┘    │  │
│  │   ┌────────────────────────────────────────┐    │  │
│  │   │ Repository Layer (Spring Data JPA)    │    │  │
│  │   │ - UserRepository, ProductRepository   │    │  │
│  │   │ - OrderRepository, PaymentRepository  │    │  │
│  │   └────────────────────────────────────────┘    │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           ↓ JDBC/JPA
┌─────────────────────────────────────────────────────────┐
│                  Data Layer                              │
│  ┌──────────────────────────────────────────────────┐  │
│  │   PostgreSQL Database (Port 5432)                │  │
│  │   - users, categories, products                  │  │
│  │   - carts, cart_items, orders, order_items      │  │
│  │   - payments, reviews                            │  │
│  │   - Proper indexing & relationships              │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Design Patterns Used

1. **MVC (Model-View-Controller)**
   - Controllers handle requests
   - Services contain business logic
   - Models/Entities represent data

2. **Repository Pattern**
   - Data access abstraction
   - Spring Data JPA repositories
   - Testable database operations

3. **Service Locator Pattern**
   - Services autowired via Spring DI
   - Loose coupling between layers

4. **JWT Token Pattern**
   - Stateless authentication
   - Tokens issued on login
   - Tokens validated on each request

5. **Decorator Pattern**
   - Spring annotations for configuration
   - @Entity, @Service, @Repository

### Technology Decision Rationale

| Decision | Why |
|----------|-----|
| **Spring Boot** | Industry standard, enterprise features, great ecosystem |
| **React** | Component reusability, virtual DOM efficiency, large community |
| **PostgreSQL** | ACID compliance, complex queries, open-source |
| **JWT** | Stateless, scalable, no server-side session storage needed |
| **Razorpay** | Indian payment gateway, easy integration, test mode |
| **Docker** | Consistency across environments, easy deployment, scaling |

---

## 🔧 Setup & Installation

### Prerequisites Installation

#### Java 17
```bash
# Windows (using Chocolatey)
choco install openjdk17

# macOS
brew install openjdk@17

# Linux (Ubuntu)
sudo apt-get install openjdk-17-jdk
```

#### Node.js 18+
```bash
# Windows (using Chocolatey)
choco install nodejs

# macOS
brew install node@18

# Linux (Ubuntu)
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install nodejs
```

#### Maven
```bash
# Windows (using Chocolatey)
choco install maven

# macOS
brew install maven

# Linux (Ubuntu)
sudo apt-get install maven
```

### Complete Installation Steps

#### 1. Clone Repository
```bash
git clone https://github.com/praveen2246/springboot-ecommerce-core.git
cd springboot-ecommerce-core
```

#### 2. Backend Setup
```bash
cd ecommerce-backend/ecommerce-backend

# Copy environment template
cp .env.example .env

# Edit .env with your credentials
# - Update Razorpay test credentials (already provided)
# - Update Gmail SMTP credentials (enter your email/app password)
# - Update JWT secret (minimum 32 characters)

# Install dependencies
mvn clean install

# Build project
mvn clean package -DskipTests
```

#### 3. Frontend Setup
```bash
cd ../../ecommerce-frontend

# Copy environment template
cp .env.example .env.local

# Install dependencies
npm install

# Verify installation
npm list
```

#### 4. Database Setup (Optional - for PostgreSQL)
```bash
# Create database
createdb -U postgres ecommerce

# Initialize schema (if using PostgreSQL)
psql -U postgres -d ecommerce -f ../scripts/init-db.sql
```

### Verification

```bash
# Verify Java installation
java -version
# Output: openjdk version "17.0.x"

# Verify Maven installation
mvn -version
# Output: Apache Maven 3.8.x

# Verify Node.js installation
node -version
# Output: v18.x.x

npm -version
# Output: 9.x.x
```

---

## 📁 Code Structure Explanation

### Backend Structure

```
ecommerce-backend/ecommerce-backend/
├── src/main/java/com/ecommerce/
│   ├── config/
│   │   ├── SecurityConfig.java           # Spring Security configuration
│   │   ├── JwtTokenProvider.java         # JWT token generation/validation
│   │   └── CorsConfig.java               # CORS configuration
│   │
│   ├── controller/
│   │   ├── AuthController.java           # /api/auth/* endpoints
│   │   ├── ProductController.java        # /api/products/* endpoints
│   │   ├── CartController.java           # /api/cart/* endpoints
│   │   ├── OrderController.java          # /api/orders/* endpoints
│   │   └── PaymentController.java        # /api/payments/* endpoints
│   │
│   ├── service/
│   │   ├── AuthService.java              # Authentication logic
│   │   ├── UserService.java              # User management
│   │   ├── ProductService.java           # Product operations
│   │   ├── CartService.java              # Cart management
│   │   ├── OrderService.java             # Order processing
│   │   ├── PaymentService.java           # Payment handling
│   │   ├── RazorpayService.java          # Razorpay integration
│   │   └── EmailService.java             # Email notifications
│   │
│   ├── model/
│   │   ├── User.java                     # User entity
│   │   ├── Product.java                  # Product entity
│   │   ├── Cart.java                     # Cart entity
│   │   ├── CartItem.java                 # Cart item entity
│   │   ├── Order.java                    # Order entity
│   │   ├── OrderItem.java                # Order item entity
│   │   ├── Payment.java                  # Payment entity
│   │   ├── Category.java                 # Category entity
│   │   └── Review.java                   # Review entity
│   │
│   ├── repository/
│   │   ├── UserRepository.java           # User data access
│   │   ├── ProductRepository.java        # Product data access
│   │   ├── CartRepository.java           # Cart data access
│   │   ├── CartItemRepository.java       # Cart item data access
│   │   ├── OrderRepository.java          # Order data access
│   │   ├── OrderItemRepository.java      # Order item data access
│   │   ├── PaymentRepository.java        # Payment data access
│   │   └── CategoryRepository.java       # Category data access
│   │
│   ├── exception/
│   │   ├── ResourceNotFoundException.java     # Custom exception
│   │   ├── InvalidCredentialsException.java   # Auth exception
│   │   ├── PaymentException.java              # Payment exception
│   │   └── GlobalExceptionHandler.java       # Global exception handler
│   │
│   ├── dto/
│   │   ├── LoginRequest.java                 # Login DTO
│   │   ├── LoginResponse.java                # Login response DTO
│   │   ├── ProductDTO.java                   # Product DTO
│   │   ├── OrderDTO.java                     # Order DTO
│   │   └── PaymentVerificationDTO.java       # Payment verification DTO
│   │
│   ├── util/
│   │   ├── JwtUtil.java                      # JWT utilities
│   │   ├── PasswordEncoder.java              # Password utilities
│   │   └── EmailUtil.java                    # Email utilities
│   │
│   └── EcommerceBackendApplication.java  # Main application class
│
├── src/main/resources/
│   ├── application.properties              # Default configuration
│   ├── application-dev.properties          # Development config
│   ├── application-prod.properties         # Production config
│   └── data.sql                            # Sample data
│
├── pom.xml                                 # Maven dependencies
└── Dockerfile                              # Container configuration
```

#### Key Classes Explanation

**SecurityConfig.java**
- Configures Spring Security
- Enables JWT filter
- Defines protected/public endpoints
- Sets up CORS
- Configures password encoder

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    // Spring Security bean configurations
    // JWT filter setup
    // Exception handling for auth failures
}
```

**JwtTokenProvider.java**
- Generates JWT tokens
- Validates tokens
- Extracts claims from tokens
- Handles token expiration

```java
public class JwtTokenProvider {
    public String generateToken(UserDetails userDetails) { }
    public boolean validateToken(String token) { }
    public String getEmailFromToken(String token) { }
}
```

**ProductService.java**
- Searches products by keyword
- Filters by price range
- Filters by category
- Handles product retrieval

```java
@Service
public class ProductService {
    public List<Product> searchProducts(String keyword) { }
    public List<Product> filterByPrice(BigDecimal min, BigDecimal max) { }
    public List<Product> filterByCategory(String category) { }
}
```

**PaymentService.java**
- Creates payment orders
- Verifies payment signatures
- Updates order status
- Triggers email notifications

```java
@Service
public class PaymentService {
    public Order createPaymentOrder(Order order) { }
    public boolean verifyPaymentSignature(String orderId, String paymentId, String signature) { }
    public void markPaymentSucceeded(Order order) { }
}
```

### Frontend Structure

```
ecommerce-frontend/
├── src/
│   ├── components/
│   │   ├── NavBar.jsx                    # Navigation header
│   │   ├── HeroSection.jsx               # Landing hero
│   │   ├── ProductCard.jsx               # Individual product card
│   │   ├── Footer.jsx                    # Footer component
│   │   └── AuthModal.jsx                 # Login/Register modal
│   │
│   ├── pages/
│   │   ├── Home.jsx                      # Home page
│   │   ├── ProductPage.jsx               # Products listing
│   │   ├── ProductDetail.jsx             # Product details
│   │   ├── Cart.jsx                      # Shopping cart
│   │   ├── Checkout.jsx                  # Checkout page
│   │   ├── OrderHistory.jsx              # User orders
│   │   └── Profile.jsx                   # User profile
│   │
│   ├── context/
│   │   ├── AuthContext.jsx               # Authentication context
│   │   └── ThemeContext.jsx              # Dark/Light theme
│   │
│   ├── services/
│   │   ├── api.js                        # API configuration
│   │   ├── authService.js                # Auth API calls
│   │   ├── productService.js             # Product API calls
│   │   ├── cartService.js                # Cart API calls
│   │   └── orderService.js               # Order API calls
│   │
│   ├── styles/
│   │   ├── App.css                       # Global styles
│   │   ├── components.css                # Component styles
│   │   └── pages.css                     # Page styles
│   │
│   ├── App.jsx                           # Main app component
│   ├── main.jsx                          # Entry point
│   └── index.css                         # Base styles
│
├── public/
│   ├── images/                           # Product images
│   └── index.html                        # HTML template
│
├── package.json                          # npm dependencies
├── vite.config.js                        # Vite configuration
├── .env.example                          # Environment template
└── Dockerfile                            # Container configuration
```

#### Key Components Explanation

**AuthContext.jsx**
- Manages user authentication state
- Stores JWT token
- Provides login/logout functions
- Auto-login on app load

```jsx
export const useAuth = () => {
    const { user, token, login, logout, isLoading } = useContext(AuthContext);
    return { user, token, login, logout, isLoading };
};
```

**ProductPage.jsx**
- Displays products in grid
- Implements search functionality
- Implements price filtering
- Handles pagination

```jsx
const [searchKeyword, setSearchKeyword] = useState('');
const [minPrice, setMinPrice] = useState(0);
const [maxPrice, setMaxPrice] = useState(100000);
const [products, setProducts] = useState([]);

const handleSearch = async () => {
    const response = await productService.searchProducts(searchKeyword);
    setProducts(response.data);
};
```

**Cart Management**
- Add items to cart
- Remove items
- Update quantities
- Persist to localStorage

```jsx
const addToCart = (product, quantity) => {
    const cart = JSON.parse(localStorage.getItem('cart')) || [];
    // Add product to cart
    localStorage.setItem('cart', JSON.stringify(cart));
};
```

---

## 💾 Database Schema

### ER Diagram

```
┌─────────────┐
│   Users     │
├─────────────┤
│ id (PK)     │
│ email       │ UNIQUE
│ password    │
│ firstName   │
│ lastName    │
│ phone       │
│ address     │
└──────┬──────┘
       │ (1:∞)
       │
┌──────┴──────────────────────────────┐
│                                     │
│ (1:∞)                          (1:∞)
│                                     │
┌────────────┐            ┌──────────────────┐
│   Carts    │            │    Orders        │
├────────────┤            ├──────────────────┤
│ id (PK)    │            │ id (PK)          │
│ userId(FK) │            │ userId (FK)      │
│ createdAt  │            │ orderNumber (UK) │
└────┬───────┘            │ totalAmount      │
     │ (1:∞)              │ status           │
     │                    │ shippingAddress  │
     │                    └────────┬─────────┘
     │                            │ (1:∞)
     │                            │
┌────┴──────────────┐      ┌──────┴──────────────┐
│   CartItems       │      │   OrderItems       │
├──────────────────┤      ├──────────────────┤
│ id (PK)          │      │ id (PK)          │
│ cartId (FK)      │      │ orderId (FK)     │
│ productId (FK)   │      │ productId (FK)   │
│ quantity         │      │ quantity         │
│ price            │      │ price            │
└───────┬──────────┘      └───────┬──────────┘
        │ (∞:1)                   │ (∞:1)
        └───────────┬─────────────┘
                    │
             ┌──────┴──────────┐
             │                 │
        (∞:1)                (∞:1)
             │                 │
      ┌────────────────┐ ┌──────────────┐
      │    Products    │ │  Categories  │
      ├────────────────┤ ├──────────────┤
      │ id (PK)        │ │ id (PK)      │
      │ categoryId(FK) │ │ name         │
      │ name           │ │ description  │
      │ description    │ └──────────────┘
      │ price          │
      │ stock          │
      │ imageUrl       │
      └────────────────┘

┌──────────────┐
│   Payments   │
├──────────────┤
│ id (PK)      │
│ orderId(FK)  │ UNIQUE
│ razorpayId   │
│ amount       │
│ status       │
│ createdAt    │
└──────────────┘
```

### Table Definitions

**Users Table**
```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Products Table**
```sql
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_name ON products(name);
```

**Orders Table**
```sql
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    shipping_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
```

**Payments Table**
```sql
CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT UNIQUE NOT NULL REFERENCES orders(id),
    razorpay_order_id VARCHAR(255),
    razorpay_payment_id VARCHAR(255),
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 📡 API Endpoints Documentation

### Base URL
```
http://localhost:8080/api
```

### Authentication Endpoints

#### 1. Register User
```http
POST /auth/register
Content-Type: application/json

{
    "username": "newuser",
    "email": "newuser@example.com",
    "password": "SecurePass@123",
    "firstName": "John",
    "lastName": "Doe"
}

Response (201 Created):
{
    "success": true,
    "data": {
        "id": 1,
        "email": "newuser@example.com",
        "firstName": "John"
    },
    "message": "User registered successfully"
}
```

#### 2. Login
```http
POST /auth/login
Content-Type: application/json

{
    "email": "praveen@example.com",
    "password": "password123"
}

Response (200 OK):
{
    "success": true,
    "data": {
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "user": {
            "id": 1,
            "email": "praveen@example.com",
            "firstName": "Praveen"
        }
    },
    "message": "Login successful"
}
```

#### 3. Validate Token
```http
GET /auth/validate
Authorization: Bearer <JWT_TOKEN>

Response (200 OK):
{
    "success": true,
    "data": {
        "email": "praveen@example.com",
        "valid": true
    },
    "message": "Token is valid"
}
```

### Product Endpoints

#### 1. Get All Products
```http
GET /products
Authorization: Bearer <JWT_TOKEN>

Query Parameters:
- page=0 (optional)
- size=10 (optional)
- sort=price,asc (optional)

Response (200 OK):
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "Wireless Headphones",
            "description": "High-quality Bluetooth headphones",
            "price": 4999.00,
            "category": "Electronics",
            "imageUrl": "https://..."
        },
        ...
    ],
    "message": "Products retrieved successfully"
}
```

#### 2. Get Product by ID
```http
GET /products/{id}

Response (200 OK):
{
    "success": true,
    "data": {
        "id": 1,
        "name": "Wireless Headphones",
        "description": "High-quality Bluetooth headphones with noise cancellation",
        "price": 4999.00,
        "stockQuantity": 50,
        "category": {
            "id": 1,
            "name": "Electronics"
        },
        "imageUrl": "https://..."
    }
}
```

#### 3. Search Products
```http
GET /products/search?keyword=iphone

Response (200 OK):
{
    "success": true,
    "data": [
        {
            "id": 5,
            "name": "iPhone 15 Pro",
            "price": 99999.00,
            "category": "Electronics"
        }
    ],
    "message": "2 products found"
}
```

#### 4. Filter by Price Range
```http
GET /products/filter/price?minPrice=1000&maxPrice=50000

Response (200 OK):
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "Wireless Headphones",
            "price": 4999.00
        },
        {
            "id": 2,
            "name": "Smart Watch",
            "price": 15999.00
        }
    ],
    "message": "20 products found in price range"
}
```

### Cart Endpoints

#### 1. Get Cart
```http
GET /cart
Authorization: Bearer <JWT_TOKEN>

Response (200 OK):
{
    "success": true,
    "data": {
        "id": 1,
        "userId": 1,
        "items": [
            {
                "id": 1,
                "productId": 1,
                "productName": "Wireless Headphones",
                "quantity": 2,
                "price": 4999.00,
                "totalPrice": 9998.00
            }
        ],
        "cartTotal": 9998.00,
        "itemCount": 2
    }
}
```

#### 2. Add Item to Cart
```http
POST /cart/items
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
    "productId": 1,
    "quantity": 2
}

Response (201 Created):
{
    "success": true,
    "data": {
        "cartId": 1,
        "productId": 1,
        "quantity": 2,
        "totalPrice": 9998.00
    },
    "message": "Item added to cart"
}
```

#### 3. Remove Item from Cart
```http
DELETE /cart/items/1
Authorization: Bearer <JWT_TOKEN>

Response (200 OK):
{
    "success": true,
    "message": "Item removed from cart"
}
```

#### 4. Clear Cart
```http
DELETE /cart/clear
Authorization: Bearer <JWT_TOKEN>

Response (200 OK):
{
    "success": true,
    "message": "Cart cleared"
}
```

### Order Endpoints

#### 1. Create Order
```http
POST /orders
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
    "shippingAddress": "123 Main St, City, Country"
}

Response (201 Created):
{
    "success": true,
    "data": {
        "id": 1,
        "orderNumber": "ORD-2024-001",
        "totalAmount": 9998.00,
        "status": "CREATED",
        "items": [...]
    },
    "message": "Order created successfully"
}
```

#### 2. Get User Orders
```http
GET /orders
Authorization: Bearer <JWT_TOKEN>

Response (200 OK):
{
    "success": true,
    "data": [
        {
            "id": 1,
            "orderNumber": "ORD-2024-001",
            "totalAmount": 9998.00,
            "status": "DELIVERED",
            "createdAt": "2024-01-15T10:30:00Z"
        }
    ],
    "message": "Orders retrieved"
}
```

#### 3. Get Order by ID
```http
GET /orders/{id}
Authorization: Bearer <JWT_TOKEN>

Response (200 OK):
{
    "success": true,
    "data": {
        "id": 1,
        "orderNumber": "ORD-2024-001",
        "totalAmount": 9998.00,
        "status": "DELIVERED",
        "items": [
            {
                "productId": 1,
                "productName": "Wireless Headphones",
                "quantity": 2,
                "price": 4999.00
            }
        ]
    }
}
```

### Payment Endpoints

#### 1. Create Razorpay Order
```http
POST /payments/create-order
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
    "orderId": 1,
    "amount": 9998
}

Response (200 OK):
{
    "success": true,
    "data": {
        "id": "order_123456789",
        "entity": "order",
        "amount": 999800,
        "amount_paid": 0,
        "amount_due": 999800,
        "currency": "INR",
        "receipt": "ORD-2024-001",
        "status": "created"
    },
    "message": "Razorpay order created"
}
```

#### 2. Verify Payment
```http
POST /payments/verify
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
    "razorpayOrderId": "order_123456789",
    "razorpayPaymentId": "pay_123456789",
    "razorpaySignature": "5ef8f3a1fe9f7f8c6d5e4f3a"
}

Response (200 OK):
{
    "success": true,
    "data": {
        "orderId": 1,
        "paymentId": "pay_123456789",
        "status": "COMPLETED",
        "amount": 9998
    },
    "message": "Payment verified successfully"
}
```

#### 3. Get Payment Status
```http
GET /payments/{orderId}
Authorization: Bearer <JWT_TOKEN>

Response (200 OK):
{
    "success": true,
    "data": {
        "orderId": 1,
        "paymentId": "pay_123456789",
        "amount": 9998,
        "status": "COMPLETED",
        "createdAt": "2024-01-15T10:35:00Z"
    }
}
```

### Error Responses

#### 400 Bad Request
```json
{
    "success": false,
    "error": "INVALID_INPUT",
    "message": "Email is required",
    "status": 400
}
```

#### 401 Unauthorized
```json
{
    "success": false,
    "error": "INVALID_CREDENTIALS",
    "message": "Incorrect email or password",
    "status": 401
}
```

#### 404 Not Found
```json
{
    "success": false,
    "error": "PRODUCT_NOT_FOUND",
    "message": "Product with ID 999 not found",
    "status": 404
}
```

#### 500 Internal Server Error
```json
{
    "success": false,
    "error": "SERVER_ERROR",
    "message": "An unexpected error occurred",
    "status": 500
}
```

---

## 🔐 Security Implementation

### 1. Authentication

**JWT Token Flow**:
```
1. User submits credentials
2. Server validates credentials
3. Server generates JWT token (valid for 24h)
4. Token sent to client
5. Client includes token in Authorization header for all requests
6. Server validates token on each request
7. Token expires after 24 hours
```

**Token Structure**:
```
Header:
{
    "alg": "HS256",
    "typ": "JWT"
}

Payload:
{
    "sub": "user@example.com",
    "iat": 1704067800,
    "exp": 1704154200,
    "iss": "ecommerce-api"
}

Signature:
HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), SECRET_KEY)
```

### 2. Password Security

**Password Hashing**:
- Algorithm: BCrypt with 10 rounds
- Salt: Auto-generated by BCrypt
- Verification: Never compare plaintext, always hash and compare

```java
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder(10);
}

// Hashing
String hashedPassword = passwordEncoder.encode(plainPassword);

// Verification
boolean isValid = passwordEncoder.matches(plainPassword, hashedPassword);
```

### 3. Authorization

**Role-Based Access Control (RBAC)**:
- USER role: Can browse products, manage cart, create orders
- ADMIN role: Can manage products, view all orders

```java
@GetMapping("/admin/stats")
@PreAuthorize("hasRole('ADMIN')")
public ResponseEntity<?> getAdminStats() {
    // Only accessible to users with ADMIN role
}
```

### 4. CORS Configuration

**Cross-Origin Resource Sharing**:
- Only allow requests from trusted origins
- Frontend on localhost:5173 can call backend on localhost:8080

```java
@Configuration
public class CorsConfig {
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")
                    .allowedOrigins("http://localhost:5173")
                    .allowedMethods("GET", "POST", "PUT", "DELETE")
                    .allowCredentials(true);
            }
        };
    }
}
```

### 5. SQL Injection Prevention

**JPA/Parameterized Queries**:
- Using Spring Data JPA prevents SQL injection
- All queries are parameterized

```java
// Safe - using parameterized queries
@Query("SELECT p FROM Product p WHERE p.name LIKE %:keyword%")
List<Product> searchByKeyword(@Param("keyword") String keyword);

// NOT SAFE - string concatenation (avoided in this project)
// String sql = "SELECT * FROM products WHERE name = '" + keyword + "'";
```

### 6. Sensitive Data Protection

**Environment Variables**:
- Razorpay API keys stored in environment variables
- Gmail credentials stored as app password
- JWT secret stored securely
- Never committed to version control

```yaml
# .env (not version controlled)
RAZORPAY_API_KEY=rzp_test_xxx
RAZORPAY_API_SECRET=yyy
JWT_SECRET=zzz_very_long_secret_key
MAIL_PASSWORD=app_password
```

### 7. Payment Security

**Razorpay Integration Security**:
- Client-side validation with Razorpay SDK
- Server-side signature verification
- Webhooks for payment notifications
- PCI-DSS compliance (handled by Razorpay)

```java
// Verify Razorpay signature
public boolean verifySignature(String orderId, String paymentId, String signature) {
    String message = orderId + "|" + paymentId;
    String expectedSignature = HmacSHA256(message, SECRET);
    return signature.equals(expectedSignature);
}
```

### 8. Input Validation

**Server-Side Validation**:
- All inputs validated
- Length checks on strings
- Type checks on numbers
- Email format validation
- Business logic validation

```java
@PostMapping("/auth/register")
public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
    // @Valid triggers validation
    // Validation annotations used:
    // @NotBlank, @Email, @Size, @Pattern
}
```

---

## 🧪 Testing Strategy

### Unit Testing

**Product Service Tests**:
```java
@SpringBootTest
public class ProductServiceTest {
    
    @MockBean
    private ProductRepository productRepository;
    
    @Autowired
    private ProductService productService;
    
    @Test
    public void testSearchProducts() {
        // Arrange
        List<Product> expectedProducts = Arrays.asList(
            new Product("iPhone", 99999)
        );
        when(productRepository.findByNameContainingIgnoreCase("iPhone"))
            .thenReturn(expectedProducts);
        
        // Act
        List<Product> result = productService.searchProducts("iPhone");
        
        // Assert
        assertEquals(1, result.size());
        assertEquals("iPhone", result.get(0).getName());
    }
}
```

### Integration Testing

**Controller Integration Tests**:
```java
@SpringBootTest
@AutoConfigureMockMvc
public class ProductControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    public void testGetAllProducts() throws Exception {
        mockMvc.perform(get("/api/products"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(true))
            .andExpect(jsonPath("$.data").isArray());
    }
}
```

### API Testing

**Using Postman Collection**:
- Available in `postman/E-Commerce-API.postman_collection.json`
- Pre-configured with environment variables
- Test cases for happy path and error scenarios

**Manual Testing Checklist**:
- [ ] Register new user
- [ ] Login with valid credentials
- [ ] Login with invalid credentials
- [ ] Search products by keyword
- [ ] Filter products by price
- [ ] Add item to cart
- [ ] Remove item from cart
- [ ] Create order from cart
- [ ] Complete payment
- [ ] Verify order confirmation email
- [ ] View order history
- [ ] Logout

### Performance Testing

**Load Testing Scenarios**:
- 100 concurrent users browsing products
- 50 users adding items to cart
- 10 users completing checkout
- Response time: < 500ms for product API
- Response time: < 1000ms for payment API

---

## 🚀 Deployment Guide

### Local Development
```bash
# Backend
cd ecommerce-backend/ecommerce-backend
mvn spring-boot:run

# Frontend (new terminal)
cd ecommerce-frontend
npm run dev
```

### Docker Deployment
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Production Deployment

**Environment Preparation**:
```bash
# Create .env file with production credentials
RAZORPAY_API_KEY=rzp_live_xxxxx  # Live key (from Razorpay)
RAZORPAY_API_SECRET=yyyyy          # Live secret
MAIL_USERNAME=noreply@company.com
MAIL_PASSWORD=app_password
JWT_SECRET=very_long_secret_key_min_32_chars
DATABASE_URL=postgresql://user:pass@host:5432/ecommerce
```

**Database Migration**:
```bash
# Backup existing database
./scripts/backup-restore.sh backup

# Initialize new database
./scripts/postgres-init.sh
```

**SSL/HTTPS Setup**:
```bash
# Get certificate from Let's Encrypt
sudo certbot certonly --standalone -d yourdomain.com

# Configure Nginx with SSL
# Update nginx-frontend.conf with certificate paths
```

**Deployment Commands**:
```bash
# Build images
docker build -t ecommerce-backend:1.0.0 ./ecommerce-backend
docker build -t ecommerce-frontend:1.0.0 ./ecommerce-frontend

# Push to registry (if using cloud)
docker push your-registry/ecommerce-backend:1.0.0
docker push your-registry/ecommerce-frontend:1.0.0

# Deploy
docker-compose -f docker-compose.prod.yml up -d
```

---

## 📖 Development Guidelines

### Code Style

**Java Conventions**:
- Class names: PascalCase (ProductService)
- Method names: camelCase (getProduct)
- Constants: UPPER_CASE (API_KEY)
- Package structure: com.ecommerce.category

**JavaScript/React Conventions**:
- Component names: PascalCase (ProductCard)
- Function names: camelCase (handleClick)
- Constants: UPPER_CASE (API_BASE_URL)
- File naming: lowercase with hyphens (product-card.jsx)

### Commit Conventions

**Commit Message Format**:
```
<type>: <subject>

<body>

<footer>
```

Examples:
```
feat: Add product search functionality
fix: Fix JWT token validation bug
docs: Update API documentation
refactor: Simplify payment verification logic
test: Add unit tests for ProductService
```

### Branch Strategy

**Git Branches**:
- `main` - Production code
- `develop` - Development branch
- `feature/*` - Feature branches
- `bugfix/*` - Bug fixes
- `hotfix/*` - Production hotfixes

**Workflow**:
```bash
# Create feature branch
git checkout -b feature/add-reviews

# Make changes and commit
git add .
git commit -m "Add product reviews feature"

# Create pull request
git push origin feature/add-reviews

# After review, merge to develop
git checkout develop
git merge feature/add-reviews

# When ready for production, merge to main
git checkout main
git merge develop
```

### Documentation

**Code Comments**:
```java
/**
 * Searches products by keyword in name and description.
 * Case-insensitive search using LIKE operator.
 *
 * @param keyword the search keyword (minimum 1 character)
 * @return list of matching products
 * @throws IllegalArgumentException if keyword is empty
 */
public List<Product> searchProducts(String keyword) {
    if (keyword == null || keyword.trim().isEmpty()) {
        throw new IllegalArgumentException("Keyword cannot be empty");
    }
    return productRepository.findByNameContainingIgnoreCase(keyword);
}
```

### Logging Standards

**Log Levels**:
- ERROR: System errors, exceptions
- WARN: Warnings, deprecated features
- INFO: Important events, operations
- DEBUG: Detailed information for debugging

```java
logger.error("Payment verification failed for order: {}", orderId, exception);
logger.warn("Low stock for product: {}", productId);
logger.info("User {} logged in successfully", email);
logger.debug("Searching products with keyword: {}", keyword);
```

---

## 📋 Project Requirements Checklist

### Functional Requirements
- ✅ User registration and login
- ✅ Product catalog with search
- ✅ Price filtering
- ✅ Shopping cart management
- ✅ Order creation
- ✅ Payment processing
- ✅ Email notifications
- ✅ API documentation

### Non-Functional Requirements
- ✅ Security (JWT, BCrypt, CORS)
- ✅ Scalability (Docker, stateless design)
- ✅ Performance (<500ms response time)
- ✅ Reliability (Error handling, validation)
- ✅ Maintainability (Clean code, documentation)
- ✅ Accessibility (Responsive design)

### Technology Requirements
- ✅ Java 17 & Spring Boot 4.0.4
- ✅ React 18 & Vite
- ✅ PostgreSQL / H2
- ✅ Razorpay integration
- ✅ Docker & Docker Compose
- ✅ GitHub Actions CI/CD

---

## 📞 Support & Resources

- **Documentation**: See README.md and docs/API.md
- **API Testing**: Use postman/E-Commerce-API.postman_collection.json
- **Scripts**: See scripts/SCRIPTS_GUIDE.md for deployment/maintenance
- **GitHub**: https://github.com/praveen2246/springboot-ecommerce-core

---

**Document Version**: 1.0.0  
**Last Updated**: March 2024  
**Author**: Praveen Kumar
