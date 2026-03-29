# 🎯 Real Razorpay Integration Setup Guide

Your e-commerce backend is now configured to use **Real Razorpay API**! Follow these steps to complete the setup.

## Step 1: Get Your Razorpay API Credentials

### For Development (Test Mode):

1. **Go to**: https://razorpay.com
2. **Sign up** or **Log in**
3. **Go to Dashboard**:
   - Click your **Profile icon** (top right)
   - Select **Settings** → **API Keys**
4. **Copy your Test Credentials**:
   - 📋 **Key ID** (starts with `rzp_test_`)
   - 📋 **Key Secret** (keep this SAFE!)

### For Production (Live Mode):
- After testing, switch to Live Keys
- Use the same process but copy Live credentials
- Update with production keys before deploying

---

## Step 2: Stop Current Backend Server

```powershell
# Stop the running server
Get-Process java | Stop-Process -Force
```

---

## Step 3: Set Environment Variables & Start Backend

### On Windows PowerShell:

```powershell
# Set Razorpay credentials (replace with your actual keys)
$env:RAZORPAY_API_KEY = "rzp_test_YOUR_KEY_ID"
$env:RAZORPAY_API_SECRET = "rzp_test_YOUR_KEY_SECRET"

# Also set these if needed
$env:MAVEN_HOME = "C:\apache-maven-3.9.14"
$env:Path = "$env:MAVEN_HOME\bin;" + $env:Path
$env:SPRING_PROFILES_ACTIVE = "prod"

# Navigate to backend
cd D:\arena\ecommerce-backend\ecommerce-backend

# Start the server
mvn spring-boot:run
```

### On Mac/Linux:

```bash
export RAZORPAY_API_KEY="rzp_test_YOUR_KEY_ID"
export RAZORPAY_API_SECRET="rzp_test_YOUR_KEY_SECRET"
export SPRING_PROFILES_ACTIVE="prod"

cd /path/to/ecommerce-backend
mvn spring-boot:run
```

---

## Step 4: Verify Setup

You should see this log message:

```
✅ Razorpay client initialized with real API credentials
```

If you see instead:
```
⚠️ Razorpay credentials not configured. Using mock orders.
```

Then the environment variables weren't set properly. Restart with correct credentials.

---

## Step 5: Test the Payment Flow

### Complete Payment Flow:

1. **Frontend (Vite)**: http://localhost:5173
2. **Add Products to Cart** → Click the product cards
3. **Go to Cart** → Review items
4. **Checkout** → Enter shipping address
5. **Proceed to Payment** → Razorpay modal appears ✅
6. **Complete Payment** → Enter test payment details (see below)

### Test Payment Credentials:

Use these test credentials from Razorpay:

| Field | Value |
|-------|-------|
| **Card Number** | `4111 1111 1111 1111` |
| **Expiry (MM/YY)** | `12/25` |
| **CVV** | Any 3 digits (e.g., `123`) |
| **Name** | Any name |

After payment:
- ✅ Order status updates to `CONFIRMED`
- ✅ Payment status updates to `SUCCEEDED`
- 📧 Confirmation email sent
- 🗑️ Cart automatically cleared

---

## API Endpoints Affected

### Create Razorpay Order (Backend):
```
POST /api/payments/razorpay/create-order
Headers:
  Authorization: Bearer {jwt_token}
  Content-Type: application/json
Body:
{
  "orderId": 123,
  "userId": 456
}
Response:
{
  "orderId": "order_1A2B3C4D5E6F7G8H",
  "amount": 1299.99,
  "amountInPaise": 129999,
  "currency": "INR",
  "keyId": "rzp_test_YOUR_KEY_ID",
  "userEmail": "user@example.com",
  "userName": "John Doe",
  "message": "✅ Real Razorpay order created successfully"
}
```

### Verify Razorpay Payment (Backend):
```
POST /api/payments/razorpay/verify
Headers:
  Content-Type: application/json
Body:
{
  "razorpayOrderId": "order_1A2B3C4D5E6F7G8H",
  "razorpayPaymentId": "pay_1X2Y3Z4A5B6C7D8E",
  "razorpaySignature": "signature_hash_here"
}
Response:
{
  "success": true,
  "message": "✅ Payment verified successfully",
  "paymentStatus": "SUCCEEDED",
  "orderId": 123
}
```

---

## Security Notes

✅ **What's Protected:**
- API secrets stored in environment variables (NOT in code)
- HMAC-SHA256 signature verification
- JWT authentication on endpoints
- CORS restricted to localhost

⚠️ **Important**: 
- Never commit API keys to Git
- Use environment variables for all sensitive data
- In production, use a secrets manager (AWS Secrets Manager, HashiCorp Vault, etc.)
- Keep your Key Secret extremely safe

---

## Troubleshooting

### Issue: "Razorpay credentials not configured" message

**Solution**: Environment variables not set before starting the server

```powershell
# Verify variables are set
Get-ChildItem Env:RAZORPAY* 

# If empty, set them again:
$env:RAZORPAY_API_KEY = "your_key"
$env:RAZORPAY_API_SECRET = "your_secret"
```

### Issue: "404 Bad Request" from Razorpay

**Possible causes**:
- Credentials are incorrect
- Using Live keys in Test mode or vice versa
- Network connectivity issue

**Solution**: Double-check credentials at https://dashboard.razorpay.com

### Issue: Payment modal doesn't appear

**Check**:
1. Browser console (F12) for JavaScript errors
2. Network tab - verify `/api/payments/razorpay/create-order` returns valid response
3. Razorpay script loaded successfully

---

## Next Steps

✅ **Real Razorpay is now integrated!**

Additional features you can implement:
- 💰 Refund handling (POST /api/payments/refund)
- 📦 Webhook handlers for async updates
- 🔄 Payment retry logic
- 📊 Payment analytics dashboard
- 💳 Saved payment methods

---

## Support

For Razorpay API documentation: https://razorpay.com/docs/
For issues: Contact Razorpay support at support@razorpay.com

Happy selling! 🚀
