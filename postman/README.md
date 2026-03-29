# Postman API Collection

Complete Postman collection for testing the E-Commerce Platform API.

## 📋 Contents

- **E-Commerce-API.postman_collection.json** - Complete API collection with all endpoints
- **E-Commerce-Environment.postman_environment.json** - Environment variables for testing

## 🚀 How to Use

### 1. Import the Collection and Environment

**Option A: Using Postman UI**
1. Open Postman
2. Click **Import** button (top left)
3. Select Files tab
4. Upload `E-Commerce-API.postman_collection.json`
5. Repeat steps 2-3 to import `E-Commerce-Environment.postman_environment.json`

**Option B: Using Postman CLI**
```bash
postman collection import E-Commerce-API.postman_collection.json
postman environment import E-Commerce-Environment.postman_environment.json
```

### 2. Select Environment
1. In Postman, click the environment dropdown (top right)
2. Select **E-Commerce Environment**

### 3. Update Base URL (if needed)
If running on different host/port, update the `base_url` variable:
```
https://api.yourdomain.com  # Production
http://localhost:8080       # Development
```

## 📚 API Endpoints

### Authentication
- `POST /api/auth/register` - Create new account
- `POST /api/auth/login` - Login and get JWT token

### Products
- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `GET /api/products/search?keyword=...` - Search products
- `GET /api/products/filter/price?minPrice=...&maxPrice=...` - Filter by price

### Cart
- `GET /api/cart` - Get user's cart
- `POST /api/cart/add` - Add item to cart
- `DELETE /api/cart/remove/{productId}` - Remove item
- `DELETE /api/cart/clear` - Clear cart

### Orders
- `POST /api/orders` - Create order
- `GET /api/orders` - Get user's orders
- `GET /api/orders/{id}` - Get order details

### Payments
- `POST /api/payments/create-order` - Create Razorpay order
- `POST /api/payments/verify` - Verify payment

## 🔐 Authentication

### Getting JWT Token

1. Call **Login** endpoint:
```json
{
  "email": "praveen@example.com",
  "password": "password123"
}
```

2. Copy the JWT token from response
3. Set `jwt_token` environment variable with the token value
4. All subsequent requests will use this token in Authorization header

### Test User Credentials
- Email: `praveen@example.com`
- Password: `password123`

## 🧪 Testing Workflow

### 1. Authentication Flow
```
1. Register (or use test user)
2. Login → Get JWT token
3. Set jwt_token variable
```

### 2. Product Browsing
```
1. Get All Products
2. Search for products
3. Filter by price range
```

### 3. Shopping Flow
```
1. Add items to cart
2. Get cart
3. Create order
```

### 4. Payment Flow
```
1. Create Razorpay order
2. Complete payment in Razorpay modal
3. Verify payment
```

## 💡 Tips

### Razorpay Test Cards

Use these test cards in Razorpay payment modal:

| Type | Card Number | Expiry | CVV |
|------|-------------|--------|-----|
| Success | 4111 1111 1111 1111 | Any future date | Any 3 digits |
| Failure | 4222 2222 2222 2222 | Any future date | Any 3 digits |

### Environment Variables Available

```
base_url              → http://localhost:8080
jwt_token             → Your JWT token (set after login)
test_user_email       → praveen@example.com
test_user_password    → password123
razorpay_test_amount  → 5000
```

### Pre-request Scripts

All authenticated endpoints automatically add the JWT token to headers:
```javascript
Authorization: Bearer {{jwt_token}}
```

## 📝 Examples

### Login and Get Token
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "praveen@example.com",
    "password": "password123"
  }'
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "id": 1,
  "email": "praveen@example.com",
  "firstName": "Praveen"
}
```

### Add Item to Cart (with JWT)
```bash
curl -X POST http://localhost:8080/api/cart/add \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "productId": 1,
    "quantity": 2
  }'
```

## 🐛 Troubleshooting

### "Invalid JWT Token" Error
- **Cause**: JWT token expired or invalid
- **Solution**: Re-login and update `jwt_token` variable

### "Product not found" Error
- **Cause**: Invalid product ID
- **Solution**: First call "Get All Products" to get valid IDs

### "CORS Error" Error
- **Cause**: Frontend origin not in CORS whitelist
- **Solution**: Add your frontend URL to `application.properties`:
  ```properties
  cors.allowed.origins=http://localhost:5173,http://localhost:3000
  ```

### "Razorpay payment failed" Error
- **Cause**: Amount exceeds limits or invalid credentials
- **Solution**: Use test amount (5000), test card (4111 1111 1111 1111)

## 📖 Additional Resources

- [Postman Documentation](https://learning.postman.com/)
- [API Documentation](../docs/API.md)
- [Backend README](../ecommerce-backend/ecommerce-backend/README.md)
- [Razorpay Test Mode](https://razorpay.com/docs/payments/aggregator-apis/test-mode/)

## 🤝 Contributing

To add new endpoints to the collection:
1. Edit `E-Commerce-API.postman_collection.json`
2. Add new request in appropriate folder
3. Include example request body and URL
4. Update this README with endpoint details

---

**Last Updated**: 2024-01-15
**Collection Version**: 1.0.0
**API Version**: v1
