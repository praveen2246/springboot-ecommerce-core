# System Architecture & Design Patterns

---

## 📐 System Architecture Overview

### Multi-Layered Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                          │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  React Components (ProductCard, Cart, Checkout)          │  │
│  │  - Handles User Interactions                              │  │
│  │  - Manages Local State                                    │  │
│  │  - Displays Data                                          │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            ↓ HTTP REST
┌─────────────────────────────────────────────────────────────────┐
│                      API LAYER                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  REST Endpoints (Controllers)                             │  │
│  │  - AuthController.java                                    │  │
│  │  - ProductController.java                                 │  │
│  │  - OrderController.java                                   │  │
│  │  - Validate requests, Return responses                    │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            ↓ Business Logic
┌─────────────────────────────────────────────────────────────────┐
│                    SERVICE LAYER                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Business Logic Services                                  │  │
│  │  - ProductService: Search, Filter, Get Details           │  │
│  │  - OrderService: Create, Update, Retrieve               │  │
│  │  - PaymentService: Process, Verify                       │  │
│  │  - EmailService: Send Notifications                      │  │
│  │  - AuthService: Authenticate Users                       │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            ↓ JDBC/JPA
┌─────────────────────────────────────────────────────────────────┐
│                    REPOSITORY LAYER                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Data Access Objects (Spring Data JPA)                   │  │
│  │  - ProductRepository: CRUD operations                    │  │
│  │  - UserRepository: User data access                      │  │
│  │  - OrderRepository: Order data access                    │  │
│  │  - Custom queries for search/filter                      │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            ↓ SQL
┌─────────────────────────────────────────────────────────────────┐
│                    DATABASE LAYER                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  PostgreSQL Database                                      │  │
│  │  - 8 Tables with relationships                            │  │
│  │  - Indexes for performance                                │  │
│  │  - Constraints for data integrity                         │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Request Flow Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                    USER ACTION (GET /api/products)                    │
└──────────────────────────────────────────────────────────────────────┘
                                 ↓
┌──────────────────────────────────────────────────────────────────────┐
│  1. HTTP REQUEST                                                      │
│  GET /api/products                                                    │
│  Authorization: Bearer <JWT_TOKEN>                                    │
└──────────────────────────────────────────────────────────────────────┘
                                 ↓
┌──────────────────────────────────────────────────────────────────────┐
│  2. JWT FILTER (SecurityConfig)                                       │
│  - Extract token from header                                          │
│  - Validate token signature                                           │
│  - Check token expiration                                             │
│  - Extract user email from token                                      │
│  - Set Security Context                                               │
└──────────────────────────────────────────────────────────────────────┘
                                 ↓
┌──────────────────────────────────────────────────────────────────────┐
│  3. CONTROLLER (ProductController.java)                               │
│  @GetMapping                                                          │
│  public ResponseEntity<?> getAllProducts()                           │
│  - Validate request parameters                                        │
│  - Call ProductService.getAllProducts()                              │
└──────────────────────────────────────────────────────────────────────┘
                                 ↓
┌──────────────────────────────────────────────────────────────────────┐
│  4. SERVICE (ProductService.java)                                     │
│  public List<Product> getAllProducts()                               │
│  - Get products from repository                                       │
│  - Log operation                                                      │
│  - Return data                                                        │
└──────────────────────────────────────────────────────────────────────┘
                                 ↓
┌──────────────────────────────────────────────────────────────────────┐
│  5. REPOSITORY (ProductRepository.java)                               │
│  List<Product> findAll()                                             │
│  - Execute SQL query                                                  │
│  - Map results to objects                                             │
│  - Return list                                                        │
└──────────────────────────────────────────────────────────────────────┘
                                 ↓
┌──────────────────────────────────────────────────────────────────────┐
│  6. DATABASE (PostgreSQL)                                             │
│  SELECT * FROM products;                                              │
│  - Retrieve data                                                      │
│  - Return rows                                                        │
└──────────────────────────────────────────────────────────────────────┘
                                 ↓
┌──────────────────────────────────────────────────────────────────────┐
│  7. RESPONSE PATH (Same layers in reverse)                            │
│  Repository → Service → Controller → HTTP Response                    │
│  └→ Status: 200 OK                                                    │
│  └→ Body: { "success": true, "data": [...], ... }                   │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Authentication Flow

```
┌─────────────┐
│   Client    │
│  (Browser)  │
└──────┬──────┘
       │
       │ POST /api/auth/login
       │ {email, password}
       ↓
┌──────────────────────────────────────────┐
│      AuthController                      │
│  @PostMapping("/login")                 │
└──────────────────────────────────────────┘
       │
       │ Call authService.authenticate()
       ↓
┌──────────────────────────────────────────┐
│      AuthService                         │
│  1. Find user by email                  │
│  2. Verify password with BCrypt         │
│  3. Create JWT token (24h expiry)       │
│  4. Return token + user info            │
└──────────────────────────────────────────┘
       │
       │ JWT: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
       ↓
┌──────────────────────────────────────────┐
│      Client                              │
│  Store token in localStorage            │
│  Include in Authorization header:        │
│  Authorization: Bearer <JWT_TOKEN>      │
└──────────────────────────────────────────┘
       │
       │ GET /api/products
       │ Authorization: Bearer <JWT_TOKEN>
       ↓
┌──────────────────────────────────────────┐
│      JwtTokenFilter                      │
│  1. Extract token from header           │
│  2. Validate signature (secret key)     │
│  3. Check expiration (iat, exp claims)  │
│  4. Extract email from token            │
│  5. Set Security Context                │
└──────────────────────────────────────────┘
       │
       │ ✓ Token valid, request proceeds
       ↓
┌──────────────────────────────────────────┐
│      Controller Action                   │
│  Process authorized request             │
└──────────────────────────────────────────┘
```

### JWT Token Structure

```
┌────────────┬──────────────┬──────────────┐
│  HEADER    │   PAYLOAD    │  SIGNATURE   │
└────────────┴──────────────┴──────────────┘

HEADER:
{
  "alg": "HS256",
  "typ": "JWT"
}

PAYLOAD:
{
  "sub": "user@example.com",
  "iat": 1704067800,    // Issued At
  "exp": 1704154200,    // Expiration (24h later)
  "iss": "ecommerce",
  "aud": "ecommerce-users"
}

SIGNATURE:
HMACSHA256(
  base64UrlEncode(header) + "." + 
  base64UrlEncode(payload),
  SECRET_KEY
)
```

---

## 💳 Payment Processing Flow

```
┌──────────────────────────────────────────────────────────┐
│  User Clicks "Pay with Razorpay" Button                 │
└────────────────────┬─────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────┐
│  Frontend: Send current cart data                        │
│  POST /api/payments/create-order                         │
│  { orderId: 1, amount: 9998 }                           │
└────────────────────┬─────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────┐
│  Backend: PaymentController                              │
│  - Create order in database (status: PENDING)           │
│  - Create Razorpay order via API                        │
│  - Return order details to frontend                      │
└────────────────────┬─────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────┐
│  Frontend: Initialize Razorpay Modal                     │
│  razorpay_options = {                                    │
│    key: "rzp_test_xxx",                                 │
│    order_id: "order_123",                               │
│    handler: handlePaymentSuccess,                        │
│    prefill: { email, contact }                          │
│  }                                                       │
│  new Razorpay(options).open()                           │
└────────────────────┬─────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────┐
│  Razorpay Modal: User Enters Payment Details            │
│  - Card number: 4111 1111 1111 1111                     │
│  - Expiry: 12/25                                         │
│  - CVV: 123                                              │
│  - OTP: (auto-filled in test mode)                      │
│  - User clicks "Pay Now"                                │
└────────────────────┬─────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────┐
│  Razorpay: Processes Payment                            │
│  - Validates card details                                │
│  - Charges amount                                        │
│  - Returns payment_id to client                          │
└────────────────────┬─────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────┐
│  Frontend: handlePaymentSuccess() Called                 │
│  - Receive: razorpay_order_id, razorpay_payment_id      │
│  - Generate signature locally                            │
│  - Send to backend for verification                      │
│  POST /api/payments/verify                              │
│  {                                                       │
│    razorpayOrderId: "order_123",                        │
│    razorpayPaymentId: "pay_456",                        │
│    razorpaySignature: "hash_789"                        │
│  }                                                       │
└────────────────────┬─────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────┐
│  Backend: Verify Signature                              │
│  - Concatenate: orderId + "|" + paymentId              │
│  - Generate signature using HMAC-SHA256                  │
│  - Compare with provided signature                       │
│  - If valid: Update order status → PAID                │
│           Create payment record                          │
│           Trigger email notification                     │
│           Clear user's cart                              │
│  - If invalid: Return error                              │
└────────────────────┬─────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────┐
│  Frontend: Show Confirmation                            │
│  "Payment successful! Order confirmed."                  │
│  Redirect to order tracking page                         │
└──────────────────────────────────────────────────────────┘
```

### Signature Verification Process

```javascript
// Client-side (for display only)
const signatureBody = order_id + '|' + payment_id;
// Backend verifies with secret key

// Backend (Java)
String message = orderId + "|" + paymentId;
String generatedSignature = HmacUtils.hmacSha256Hex(apiSecret, message);
boolean isValid = generatedSignature.equals(providedSignature);
```

---

## 🛒 Shopping Cart & Order Management

```
┌─────────────────────────────────────────────────┐
│        CART LIFECYCLE                           │
└─────────────────────────────────────────────────┘

[1] ADD ITEM
    User clicks "Add to Cart"
         ↓
    POST /api/cart/items
    { productId: 1, quantity: 2 }
         ↓
    Check if product exists
    Check stock availability
    Add/Update cart_items record
    Return updated cart

[2] VIEW CART
    GET /api/cart
         ↓
    Retrieve user's cart
    Get all cart_items
    Fetch product details
    Calculate totals
    Return cart with items

[3] MODIFY CART
    User changes quantity
         ↓
    PUT /api/cart/items/{itemId}
    { quantity: 5 }
         ↓
    Validate new quantity
    Update cart_items
    Recalculate totals

[4] REMOVE ITEM
    User clicks "Remove"
         ↓
    DELETE /api/cart/items/{itemId}
         ↓
    Delete from cart_items
    Recalculate totals

[5] CHECKOUT
    User clicks "Proceed to Checkout"
         ↓
    POST /api/orders (with cart items)
         ↓
    Create order record
    Create order_items (copy from cart_items)
    Calculate total amount
    Clear cart (optional)
    Return order confirmation

[6] PAYMENT
    User proceeds to payment
         ↓
    POST /api/payments/create-order
         ↓
    Create Razorpay order
    Store in payments table
    Return Razorpay order ID

[7] PAYMENT VERIFICATION
    Payment successful
         ↓
    POST /api/payments/verify
         ↓
    Verify Razorpay signature
    Update order status → PAID
    Send confirmation email
    Clear cart
    Return success
```

### Database Relationships

```
          ┌──────────────┐
          │    Users     │
          │ (id, email)  │
          └───────┬──────┘
                  │ (1:1)
                  │
          ┌───────┴──────────┐
          │                  │
    ┌─────▼─────┐      ┌────▼──────┐
    │   Carts   │      │   Orders   │
    │  (id, uk) │      │ (id, uk)   │
    └─────┬─────┘      └────┬───────┘
          │ (1:∞)           │ (1:∞)
          │                 │
    ┌─────▼──────────┐ ┌────▼─────────┐
    │  CartItems     │ │ OrderItems    │
    │ (cart_id, pk)  │ │ (order_id, pk)│
    └────────┬───────┘ └────────┬──────┘
             │                  │
             │ (∞:1)       (∞:1)│
             └──────────┬───────┘
                        │
                  ┌─────▼────────┐
                  │   Products   │
                  │  (id, price) │
                  └──────────────┘
```

---

## 📊 Search & Filter Architecture

```
┌─────────────────────────────────────────────────────────┐
│      SEARCH UI                                          │
│  [Search box] [Price Min] [Price Max] [Category]      │
└──────────────────┬──────────────────────────────────────┘
                   │
                   │ onChange event
                   ↓
┌─────────────────────────────────────────────────────────┐
│  Frontend State (React)                                │
│  - searchKeyword                                        │
│  - minPrice                                             │
│  - maxPrice                                             │
│  - selectedCategory                                     │
│  - results: []                                          │
└──────────────────┬──────────────────────────────────────┘
                   │
                   │ API call (debounced)
                   ↓
┌─────────────────────────────────────────────────────────┐
│  API Endpoint Selection (Smart routing)                │
│                                                         │
│  If only keyword:                                       │
│  → GET /api/products/search?keyword=...               │
│                                                         │
│  If price range:                                       │
│  → GET /api/products/filter/price?min=...&max=...    │
│                                                         │
│  If multiple filters:                                 │
│  → Custom endpoint combining all filters              │
│                                                         │
│  If category:                                          │
│  → GET /api/products/category/electronics             │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│  Backend: ProductService                              │
│                                                         │
│  searchProducts(keyword):                              │
│  → productRepository.findByNameContainingIgnoreCase()│
│                                                         │
│  filterByPrice(min, max):                             │
│  → productRepository.findByPriceBetween()            │
│                                                         │
│  filterByCategory(category):                          │
│  → productRepository.findByCategory()                │
│                                                         │
│  combinedSearch(keyword, min, max, category):        │
│  → Custom query combining all conditions             │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│  Database Query (JPA)                                 │
│                                                         │
│  SELECT * FROM products                               │
│  WHERE name LIKE '%keyword%'                          │
│  AND price >= 1000 AND price <= 50000               │
│  AND category_id = 2                                  │
│  ORDER BY price ASC                                   │
│  LIMIT 20 OFFSET 0                                    │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│  Database Indexes (Optimization)                      │
│  idx_products_name      - Fast keyword search         │
│  idx_products_price     - Fast range queries          │
│  idx_products_category  - Fast category filter        │
│  Combined index on (category, price, name)           │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│  Response Path                                          │
│  ← Return matching products                            │
│  ← Frontend: Update results list                       │
│  ← Display in grid with filters applied               │
└─────────────────────────────────────────────────────────┘
```

---

## 📧 Email Notification Flow

```
┌─────────────────────────────────┐
│    Event: Order Paid             │
│  (Payment verification success) │
└────────────────┬────────────────┘
                 │
                 │ Event triggered
                 ↓
┌─────────────────────────────────┐
│    PaymentService.java           │
│  - Update order status           │
│  - Save payment record           │
│  - Trigger email service         │
└────────────────┬────────────────┘
                 │
                 │ emailService.sendOrderConfirmation()
                 ↓
┌─────────────────────────────────┐
│    EmailService.java             │
│  @Async (non-blocking)           │
│  - Get order details             │
│  - Build email template          │
│  - Queue for sending             │
└────────────────┬────────────────┘
                 │
                 │ Async processing
                 ↓
┌─────────────────────────────────┐
│    Gmail SMTP Mailer             │
│  - Connect to SMTP server        │
│  - Authenticate with credentials │
│  - Send email                    │
│  - Log result                    │
└────────────────┬────────────────┘
                 │
                 │ Background process
                 ↓
┌─────────────────────────────────┐
│    Customer Email                │
│  Order Confirmation              │
│  - Order number                  │
│  - Items list                    │
│  - Total amount                  │
│  - Tracking number               │
│  - Support contact               │
└─────────────────────────────────┘
```

### Email Template Flow

```html
<email>
  <header>
    <logo>E-Commerce Store</logo>
  </header>
  
  <body>
    <greeting>Dear {{ customerName }},</greeting>
    
    <content>
      <section>Thank you for your purchase!</section>
      <order-details>
        Order #{{ orderNumber }}
        Date: {{ orderDate }}
        Total:  ₹{{ totalAmount }}
      </order-details>
      
      <items-list>
        {% for item in orderItems %}
          ${{ item.name }} × {{ item.quantity }}
          = ₹{{ item.total }}
        {% endfor %}
      </items-list>
      
      <tracking>
        Track your order: [LINK]
      </tracking>
    </content>
    
    <footer>
      <support>Contact us anytime</support>
      <unsubscribe>[unsubscribe link]</unsubscribe>
    </footer>
  </body>
</email>
```

---

## 🐳 Docker Architecture

```
┌────────────────────────────────────────────────┐
│         docker-compose.yml                     │
│                                                 │
│  Services:                                     │
│  - frontend (Nginx + React app)               │
│  - backend (Spring Boot API)                  │
│  - postgres (Database)                        │
│  - nginx (Reverse proxy)                      │
└────────────────────────────────────────────────┘

┌─────────────────┐    ┌──────────────────┐
│  Host Machine   │    │  Container Ports │
│   (localhost)   │    │                  │
└────────┬────────┘    └────────┬─────────┘
         │                      │
    ┌────┴──────────────────────┴────┐
    │     Docker Compose Network     │
    │        (ecommerce_net)         │
    │                                │
    │  ┌────────────────────────┐   │
    │  │   Nginx (Port 80)      │   │
    │  │  - Reverse proxy       │   │
    │  │  - Static files        │   │
    │  │  - Load balancer       │   │
    │  └─────────┬──────────────┘   │
    │            │                  │
    │  ┌─────────┴──────────────┐   │
    │  │                        │   │
    │  ↓                        ↓   │
    │  ┌──────────────┐   ┌──────────────┐
    │  │ Frontend     │   │  Backend     │
    │  │ (React app)  │   │  (Spring     │
    │  │ Port: 3000   │   │   Boot)      │
    │  │              │   │  Port: 8080  │
    │  └──────────────┘   └──────┬───────┘
    │                            │
    │                    ┌───────┴────────┐
    │                    │                │
    │                    ↓                │
    │              ┌──────────────┐       │
    │              │   Database   │       │
    │              │ (PostgreSQL) │       │
    │              │  Port: 5432  │       │
    │              └──────────────┘       │
    │                                     │
    └─────────────────────────────────────┘
```

### Docker Build Process

```
Frontend Dockerfile:
┌─────────────────────────────┐
│  Stage 1: Build             │
│  - FROM node:18             │
│  - npm install              │
│  - npm run build            │
│  - Output: dist folder      │
└────────────────┬────────────┘
                 ↓
        ┌────────────────┐
        │  dist/ folder  │
        │  (Static files)│
        └────────────────┘
                 ↓
┌─────────────────────────────┐
│  Stage 2: Runtime           │
│  - FROM nginx:alpine        │
│  - Copy dist/ to nginx root │
│  - Copy nginx config        │
│  - Expose port 80           │
│  - Final image: ~50MB       │
└─────────────────────────────┘

Backend Dockerfile:
┌─────────────────────────────┐
│  Stage 1: Build             │
│  - FROM maven:3.8           │
│  - mvn clean package        │
│  - Output: JAR file         │
└────────────────┬────────────┘
                 ↓
        ┌────────────────┐
        │  target/       │
        │  app.jar       │
        └────────────────┘
                 ↓
┌─────────────────────────────┐
│  Stage 2: Runtime           │
│  - FROM openjdk:17-alpine   │
│  - Copy JAR from build      │
│  - Expose port 8080         │
│  - Health check             │
│  - Final image: ~150MB      │
└─────────────────────────────┘
```

---

## 🔄 Dependency Injection Pattern

```
Spring Container
┌──────────────────────────────────┐
│  Manages all bean lifetimes      │
│  - Creation                      │
│  - Initialization                │
│  - Destruction                   │
└──────────────────────────────────┘

Constructor Injection (Preferred):
┌──────────────────────────────────┐
│  @Service                        │
│  public class OrderService {     │
│    private final ProductService; │
│    private final CartService;    │
│                                  │
│    @Autowired  // Optional       │
│    public OrderService(          │
│      ProductService productSvc,  │
│      CartService cartSvc         │
│    ) {                           │
│      this.productService = ✓;    │
│      this.cartService = ✓;       │
│    }                             │
│  }                               │
└──────────────────────────────────┘

Benefits:
✓ Immutable dependencies
✓ Explicit requirements
✓ Easier testing (pass mocks)
✓ Fail fast if dependency missing
✓ No reflection needed

Field Injection (Avoided):
┌──────────────────────────────────┐
│  @Service                        │
│  public class OrderService {     │
│    @Autowired                    │
│    private ProductService ps;    │
│                                  │
│    @Autowired  // X Not good     │
│    private CartService cs;       │
│  }                               │
│                                  │
│  Drawbacks:                      │
│  ✗ Mutable dependencies          │
│  ✗ Hidden dependencies           │
│  ✗ Harder to test               │
│  ✗ NullPointerException risk     │
└──────────────────────────────────┘
```

---

## 🎯 Design Patterns Used

| Pattern | Location | Purpose |
|---------|----------|---------|
| **MVC** | Entire application | Separation of concerns |
| **Repository** | *Repository classes | Data access abstraction |
| **Service Locator** | Spring DI | Loose coupling |
| **Singleton** | Spring beans | Single instance per app |
| **Factory** | Spring containers | Object creation |
| **Decorator** | Spring annotations | Cross-cutting concerns |
| **Strategy** | Search/filter services | Multiple algorithms |
| **Observer** | Email events | Async notifications |
| **Template Method** | Base service classes | Common operations |
| **Adapter** | HTTP adapters | 3rd party integration |

---

## 📈 Performance Optimization

### Database Optimization

```sql
-- Indexes for fast queries
CREATE INDEX idx_products_name 
ON products(name);

CREATE INDEX idx_products_price 
ON products(price);

CREATE INDEX idx_orders_user 
ON orders(user_id);

CREATE INDEX idx_orders_status 
ON orders(status);

-- Composite index for complex queries
CREATE INDEX idx_products_search 
ON products(category_id, price, name);

-- Query optimization
EXPLAIN ANALYZE
SELECT * FROM products
WHERE name LIKE '%keyword%'
AND price BETWEEN 1000 AND 50000
ORDER BY price;
```

### Caching Strategy

```java
@Service
public class ProductService {
    
    @Cacheable("products")
    public List<Product> getAllProducts() {
        // Cached for 1 hour
        return productRepository.findAll();
    }
    
    @CacheEvict("products")
    public void updateProduct(Product product) {
        // Invalidate cache when updated
        productRepository.save(product);
    }
}
```

### Async Processing

```java
@Service
public class EmailService {
    
    @Async
    public void sendOrderConfirmation(Order order) {
        // Non-blocking, executes in thread pool
        // Request doesn't wait for email
        // Improves user experience
        mailSender.send(createMessage(order));
    }
}
```

---

## 🛡️ Error Handling Architecture

```
┌──────────────────────────────────────┐
│  Application Error Occurs            │
└────────────────┬─────────────────────┘
                 │
      ┌──────────┴──────────┐
      │                     │
      ↓                     ↓
 Checked              Unchecked
 Exception            Exception
      │                     │
      │         ┌───────────┐
      │         │           │
      ↓         ↓           ↓
   Catch    RuntimeEx   Custom
   &        (null ref)   Exception
   Handle   (class cast)

      └─────────┬──────────┘
                │
                ↓
   @ControllerAdvice
   GlobalExceptionHandler
                │
      ┌─────────┴──────────┐
      │                    │
      ↓                    ↓
   Log         Convert to
   Error       API Response
                    │
                    ↓
           { success: false,
             error: "CODE",
             message: "...",
             status: 404 }
```

---

## 🔍 Monitoring & Logging

```
╔════════════════════════════════════════╗
║  Application Activity                  ║
╚════════════════════════════════════════╝
         │         │         │
         ↓         ↓         ↓
     ERROR   WARN  INFO  DEBUG
         │         │         │
         └────────┬┬┬────────┘
                 Loggers
                   ↓
         SLF4J (Logging facade)
                   ↓
         Logback (Implementation)
                   ↓
         ┌────────┴────────┐
         │                 │
         ↓                 ↓
    Console         File
    (Development)   (Production)
         │                 │
         └────────┬────────┘
                  ↓
          Monitoring Tools
    (ELK, Splunk, DataDog)
```

---

**Last Updated**: March 2024  
**Maintained By**: Praveen Kumar
