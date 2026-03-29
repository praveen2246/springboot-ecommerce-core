# Razorpay Payment Integration - Setup & Testing Guide

## Overview
This guide walks you through setting up Razorpay payment processing in your e-commerce application. The integration is now **COMPLETE** at code level. You just need to add your API keys and test it.

---

## Step 1: Configure Razorpay API Keys

### Get Your Keys from Razorpay Dashboard:
1. Login to [Razorpay Dashboard](https://dashboard.razorpay.com/)
2. Navigate to **Settings** → **API Keys**
3. You'll see:
   - **Key ID** (starts with `rzp_live_` or `rzp_test_`)
   - **Key Secret** (keep this secret!)

### Add Keys to Backend:
Edit: `d:\arena\ecommerce-backend\ecommerce-backend\src\main\resources\application.properties`

Replace:
```properties
razorpay.api.key=YOUR_RAZORPAY_KEY_ID_HERE
razorpay.api.secret=YOUR_RAZORPAY_KEY_SECRET_HERE
```

With your actual keys:
```properties
razorpay.api.key=rzp_test_xxxxxxxxxxxxxx
razorpay.api.secret=abcdefg1234567890
```

---

## Step 2: Start Backend Server

```bash
# Navigate to backend directory
cd d:\arena\ecommerce-backend

# Start Spring Boot server
mvn spring-boot:run
```

**Expected Output:**
```
Started EcommerceBackendApplication in X.XXX seconds
Razorpay client initialized successfully
Server running on port 8080
```

---

## Step 3: Start Frontend Server

In a **new terminal**:

```bash
# Navigate to frontend directory
cd d:\arena\ecommerce-frontend

# Install dependencies (if not already done)
npm install

# Start Vite development server
npm run dev
```

**Expected Output:**
```
VITE v5.4.21  ready in XXX ms

➜  Local:   http://localhost:5173/
```

---

## Step 4: Test the Payment Flow

### Test Scenario: Complete Purchase

#### **Part 1: Browse & Add Products**
1. Open browser: http://localhost:5173
2. You should see 5 products on the homepage
3. Click **Add to Cart** on any product
4. Click **Cart** in navigation bar
5. Verify items appear in cart

#### **Part 2: Proceed to Checkout**
1. On CartPage, click **"Proceed to Checkout"** button
2. You should be redirected to CheckoutPage
3. See cart items listed with prices
4. Fill in **Shipping Address** field
5. (Optional) Add notes
6. Click **"Proceed to Payment"** button
7. Order is created and payment form appears

#### **Part 3: Make Payment**
1. **"Pay Now with Razorpay"** button is displayed
2. Click button to open Razorpay checkout modal
3. You'll see:
   - Order amount in INR
   - Your email
   - Payment method options

#### **Part 4: Use Test Card**
1. In Razorpay modal, select **Card** payment
2. Enter test card details:
   - **Card Number:** `4111 1111 1111 1111`
   - **Expiry:** Any future date (e.g., `12/25`)
   - **CVV:** Any 3 digits (e.g., `123`)
   - **Name:** Any name
3. Click **Pay Now**

#### **Part 5: Verify Payment Success**
1. Payment should process
2. You'll be redirected to **OrderConfirmationPage**
3. You should see:
   - ✓ Green success checkmark
   - Order ID
   - Order details with items
   - Total amount
   - Next steps information
4. Click "View All Orders" to see order in history

---

## Step 5: Verify Database State

### Check Backend Logs
Look for messages like:
```
Order saved: Order{id=1, status=CONFIRMED, totalAmount=...}
Payment verified successfully
```

### View H2 Database (Optional)
1. Open: http://localhost:8080/h2-console
2. Connection: `jdbc:h2:mem:testdb`
3. Query tables:
   - `SELECT * FROM PAYMENT;` - Should show payment with status SUCCEEDED
   - `SELECT * FROM ORDER;` - Should show order with status CONFIRMED
   - `SELECT * FROM ORDER_ITEM;` - Should show order items

---

## Step 6: Test Error Scenarios

### Test 1: Invalid Signature
Use Postman or curl:
```bash
curl -X POST http://localhost:8080/api/payments/razorpay/verify \
  -H "Content-Type: application/json" \
  -d '{
    "razorpayOrderId": "order_xxxxx",
    "razorpayPaymentId": "pay_xxxxx",
    "razorpaySignature": "invalid_signature"
  }'
```

**Expected:** 500 error with "Payment signature verification failed"

### Test 2: Non-existent Order
```bash
curl -X POST http://localhost:8080/api/payments/razorpay/create-order \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": 99999,
    "userId": 1
  }'
```

**Expected:** 500 error with "Order not found"

### Test 3: Missing Fields
```bash
curl -X POST http://localhost:8080/api/payments/razorpay/verify \
  -H "Content-Type: application/json" \
  -d '{
    "razorpayOrderId": "order_xxxxx"
  }'
```

**Expected:** 400 error with "Missing required fields"

---

## Troubleshooting

### Issue 1: "Razorpay client initialized successfully" not in logs
**Solution:** Verify API keys are set in `application.properties` and don't contain "YOUR_"

### Issue 2: "Failed to load Razorpay" in browser console
**Solution:** Check browser's Network tab - ensure checkout.razorpay.com is accessible

### Issue 3: 401 Unauthorized on /api/cart
**Solution:** Ensure you're logged in. JWT token should be in Authorization header.

### Issue 4: 403 CSRF Token error
**Solution:** Already fixed in SecurityConfig. Verify CSRF is disabled for /api/**

### Issue 5: "Order not found" when creating payment
**Solution:** Ensure order exists before payment. Complete "Proceed to Checkout" first.

### Issue 6: Payment verification fails
**Solution:** Check that signature matches. Verify razorpay.api.secret is correct.

---

## API Endpoints Reference

### Create Razorpay Order
```
POST /api/payments/razorpay/create-order
Content-Type: application/json
Authorization: Bearer {JWT_TOKEN}

{
  "orderId": 1,
  "userId": 1
}

Response:
{
  "orderId": "order_xxxxx",
  "amount": 1000,
  "amountInPaise": 100000,
  "currency": "INR",
  "keyId": "rzp_test_xxxxx",
  "userEmail": "user@example.com",
  "userName": "john"
}
```

### Verify Payment
```
POST /api/payments/razorpay/verify
Content-Type: application/json

{
  "razorpayOrderId": "order_xxxxx",
  "razorpayPaymentId": "pay_xxxxx",
  "razorpaySignature": "signature_xxxxx"
}

Response:
{
  "success": true,
  "message": "Payment verified successfully",
  "paymentStatus": "SUCCEEDED",
  "orderId": 1
}
```

### Get Payment Status
```
GET /api/payments/order/{orderId}
Authorization: Bearer {JWT_TOKEN}

Response:
{
  "id": 1,
  "status": "SUCCEEDED",
  "amount": 1000,
  "currency": "INR"
}
```

---

## Test Razorpay Cards

### Successful Payments:
- Card: `4111 1111 1111 1111`
- CVV: Any 3 digits
- Expiry: Any future date

### Failed Payments:
- Card: `4000 0000 0000 0002`
- CVV: Any 3 digits
- Expiry: Any future date

### Other Test Cards:
Visit: https://razorpay.com/docs/payments/payments-guide/test-card-details/

---

## Production Checklist

Before deploying to production:

- [ ] Replace test API keys with live keys
- [ ] Change `razorpay.api.key` to live key (starts with `rzp_live_`)
- [ ] Change `razorpay.api.secret` to live secret
- [ ] Test with live payment (small amount)
- [ ] Implement email notifications on payment success
- [ ] Set up order tracking/shipping integration
- [ ] Add webhook handlers for payment status updates
- [ ] Implement refund functionality
- [ ] Set up monitoring/logging for payment failures
- [ ] Review security (SSL, HTTPS everywhere)
- [ ] Test with actual customer data

---

## Next Features to Add

1. **Email Notifications**
   - Send order confirmation email
   - Payment success email
   - Shipping notification email

2. **Order Tracking**
   - Update order status as it ships
   - Track delivery status
   - Estimated delivery date

3. **Refunds**
   - Implement refund API
   - Allow customers to request refunds
   - Track refund status

4. **Payment Webhooks**
   - Handle async payment confirmations
   - Update order status via webhook
   - Reconciliation with Razorpay

5. **Multiple Payment Methods**
   - Wallet
   - UPI
   - Netbanking
   - EMI options

---

## Support & Documentation

- **Razorpay Documentation:** https://razorpay.com/docs/
- **Razorpay API Reference:** https://razorpay.com/docs/api/
- **Test Card Details:** https://razorpay.com/docs/payments/payments-guide/test-card-details/
- **Integration Troubleshooting:** https://razorpay.com/docs/payments/troubleshooting/

---

## Quick Start Summary

```bash
# Terminal 1: Backend
cd d:\arena\ecommerce-backend
# Update application.properties with API keys first!
mvn spring-boot:run

# Terminal 2: Frontend
cd d:\arena\ecommerce-frontend
npm run dev

# Browser
Open http://localhost:5173
Test the flow: Browse → Cart → Checkout → Pay → Confirmation
```

**You're ready to go! 🚀**
