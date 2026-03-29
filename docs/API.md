# 📚 API Documentation

## Complete REST API Reference for TechStore

### Base URL
```
http://localhost:8080/api
```

### Authentication

All protected endpoints require JWT token in header:
```
Authorization: Bearer {token}
```

---

## 🔐 Authentication Endpoints

### Register User

**POST** `/auth/register`

Register a new user account.

**Request Body:**
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "securePassword123",
  "confirmPassword": "securePassword123",
  "firstName": "John",
  "lastName": "Doe"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Registration successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe"
  }
}
```

---

### Login User

**POST** `/auth/login`

Authenticate and get JWT token.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "securePassword123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com"
  }
}
```

---

### Validate Token

**GET** `/auth/validate`

Verify JWT token validity.

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com"
  }
}
```

---

## 📦 Product Endpoints

### Get All Products

**GET** `/products`

Retrieve all products from catalog.

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "iPhone 15 Pro",
    "description": "Latest Apple flagship with A17 Pro chip",
    "price": 99999.00,
    "stock": 50,
    "sku": "IPHONE15PRO",
    "createdAt": "2026-03-29T10:00:00",
    "updatedAt": "2026-03-29T10:00:00"
  },
  {
    "id": 2,
    "name": "MacBook Pro 14",
    "description": "Powerful laptop with M3 Pro chip",
    "price": 179999.00,
    "stock": 30,
    "sku": "MACBOOKPRO14",
    "createdAt": "2026-03-29T10:00:00",
    "updatedAt": "2026-03-29T10:00:00"
  }
]
```

---

### Get Product by ID

**GET** `/products/{id}`

Retrieve specific product details.

**Path Parameters:**
- `id` (Long) - Product ID

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "iPhone 15 Pro",
  "description": "Latest Apple flagship with A17 Pro chip",
  "price": 99999.00,
  "stock": 50,
  "sku": "IPHONE15PRO"
}
```

---

### Search Products

**GET** `/products/search?keyword={keyword}`

Search products by name (case-insensitive).

**Query Parameters:**
- `keyword` (String) - Search term

**Example:**
```
GET /products/search?keyword=iphone
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "iPhone 15 Pro",
    "description": "Latest Apple flagship",
    "price": 99999.00,
    "stock": 50
  }
]
```

---

### Filter Products by Price

**GET** `/products/filter/price?minPrice={min}&maxPrice={max}`

Filter products within price range.

**Query Parameters:**
- `minPrice` (BigDecimal) - Minimum price
- `maxPrice` (BigDecimal) - Maximum price

**Example:**
```
GET /products/filter/price?minPrice=10000&maxPrice=100000
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "iPhone 15 Pro",
    "price": 99999.00,
    "stock": 50
  },
  {
    "id": 2,
    "name": "Samsung Galaxy S24",
    "price": 69999.00,
    "stock": 45
  }
]
```

---

## 🛒 Cart Endpoints

### Get User Cart

**GET** `/cart/{userId}`

Retrieve shopping cart with all items.

**Path Parameters:**
- `userId` (Long) - User ID

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "userId": 1,
  "cartItems": [
    {
      "id": 1,
      "productId": 1,
      "productName": "iPhone 15 Pro",
      "quantity": 1,
      "unitPrice": 99999.00,
      "subtotal": 99999.00
    }
  ],
  "totalItems": 1,
  "totalPrice": 99999.00
}
```

---

### Add Item to Cart

**POST** `/cart/items`

Add product to shopping cart.

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "userId": 1,
  "productId": 1,
  "quantity": 1
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Item added to cart",
  "cartItem": {
    "id": 1,
    "productId": 1,
    "quantity": 1,
    "unitPrice": 99999.00
  }
}
```

---

### Remove Item from Cart

**DELETE** `/cart/items/{cartItemId}`

Remove product from shopping cart.

**Path Parameters:**
- `cartItemId` (Long) - Cart item ID

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Item removed from cart"
}
```

---

## 📋 Order Endpoints

### Create Order

**POST** `/orders`

Create new order from cart items.

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "userId": 1,
  "shippingAddress": "123 Main St, Madurai, TN 625001",
  "notes": "Please deliver after 5 PM"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "userId": 1,
  "totalPrice": 99999.00,
  "status": "PENDING",
  "shippingAddress": "123 Main St, Madurai",
  "createdAt": "2026-03-29T15:30:00"
}
```

---

### Get User Orders

**GET** `/orders/user/{userId}`

Retrieve all orders for a user.

**Path Parameters:**
- `userId` (Long) - User ID

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "userId": 1,
    "totalPrice": 99999.00,
    "status": "CONFIRMED",
    "createdAt": "2026-03-29T15:30:00"
  }
]
```

---

### Get Order Details

**GET** `/orders/{orderId}`

Retrieve specific order with items.

**Path Parameters:**
- `orderId` (Long) - Order ID

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "userId": 1,
  "totalPrice": 99999.00,
  "status": "CONFIRMED",
  "shippingAddress": "123 Main St",
  "orderItems": [
    {
      "id": 1,
      "productId": 1,
      "productName": "iPhone 15 Pro",
      "quantity": 1,
      "unitPrice": 99999.00
    }
  ],
  "createdAt": "2026-03-29T15:30:00"
}
```

---

## 💳 Payment Endpoints

### Create Razorpay Order

**POST** `/payments/razorpay/create-order`

Create payment order for checkout.

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "orderId": 1,
  "userId": 1
}
```

**Response (200 OK):**
```json
{
  "orderId": "order_1234567890",
  "amount": 5000.00,
  "amountInPaise": 500000,
  "currency": "INR",
  "keyId": "rzp_test_YOUR_KEY",
  "userEmail": "john@example.com",
  "userName": "John Doe",
  "message": "Razorpay order created successfully"
}
```

---

### Verify Payment

**POST** `/payments/razorpay/verify`

Verify completed payment.

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "razorpayOrderId": "order_1234567890",
  "razorpayPaymentId": "pay_1234567890",
  "razorpaySignature": "signature_hash"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Payment verified successfully",
  "paymentId": "pay_1234567890",
  "orderId": 1,
  "status": "SUCCEEDED"
}
```

---

### Get Payment Status

**GET** `/payments/{orderId}`

Retrieve payment status for order.

**Path Parameters:**
- `orderId` (Long) - Order ID

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "orderId": 1,
  "amount": 5000.00,
  "currency": "INR",
  "status": "SUCCEEDED",
  "paymentMethod": "card",
  "createdAt": "2026-03-29T15:35:00"
}
```

---

## 🚨 Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": "Invalid request parameters",
  "details": "Missing required field: email"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "error": "Unauthorized",
  "message": "JWT token is missing or invalid"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "Not found",
  "message": "Product with id 999 not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Server error",
  "message": "An unexpected error occurred"
}
```

---

## 🧪 Test Credentials

### Test User
- **Email**: praveen@example.com
- **Password**: password123

### Test Payment Card (Razorpay)
- **Number**: 4111 1111 1111 1111
- **Expiry**: Any future date (e.g., 12/25)
- **CVV**: Any 3 digits (e.g., 123)

---

## 📊 Rate Limiting

- No rate limiting implemented (for development)
- Recommended for production: 100 requests/minute per IP

---

## 🔄 API Versioning

Current API version: **v1**

Future versions will be available at:
- `/api/v2/products`
- `/api/v2/orders`

---

**For more help, check [README.md](../README.md) or open an issue on GitHub!**
