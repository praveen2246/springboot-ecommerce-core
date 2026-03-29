# Stripe Payment Integration Setup Guide

## What Was Built

### Backend (Java Spring Boot)
1. **Payment Entity** - Stores payment details, Stripe intent IDs, and payment status
2. **PaymentRepository** - Database access for payments
3. **PaymentService** - Core logic for creating Stripe payment intents and confirming payments
4. **PaymentController** - REST endpoints:
   - `POST /api/payments/create-intent` - Creates payment intent
   - `POST /api/payments/confirm` - Confirms payment after Stripe processes it
   - `GET /api/payments/order/{orderId}` - Checks payment status
5. **Stripe Dependency** - Added v24.8.0 to pom.xml

### Frontend (React)
1. **StripePaymentForm Component** - Two-step payment form:
   - Step 1: Create payment intent
   - Step 2: Enter card details and confirm payment
2. **CSS Styling** - Professional payment form styling

## Required Configuration

### Step 1: Get Stripe API Keys
1. Go to https://stripe.com/docs/keys
2. Sign up for a free Stripe account (or use existing)
3. Copy your keys:
   - **Secret Key** (starts with `sk_test_`)
   - **Publishable Key** (starts with `pk_test_`)

### Step 2: Backend Configuration
Update `src/main/resources/application.properties`:
```properties
stripe.api.key=sk_test_YOUR_ACTUAL_SECRET_KEY
```

### Step 3: Frontend Configuration
Update `src/components/StripePaymentForm.jsx`:
```javascript
const stripePromise = loadStripe('pk_test_YOUR_ACTUAL_PUBLISHABLE_KEY')
```

### Step 4: Install npm Packages (if not done)
```bash
npm install @stripe/js @stripe/react-stripe-js
```

## Integrate Payment Form into Checkout

Update `src/pages/CartPage.jsx` or checkout component to use `StripePaymentForm`:

```jsx
import StripePaymentForm from '../components/StripePaymentForm'

// In your checkout handler:
<StripePaymentForm
  orderId={orderId}
  userId={user.id}
  totalAmount={cartData.totalPrice}
  onPaymentSuccess={() => {
    // Navigate to success page or order history
  }}
/>
```

## Testing with Stripe Test Cards

Use these test cards during development:

| Card Number | Exp | CVC | Usage |
|------------|-----|-----|-------|
| 4242 4242 4242 4242 | Any future | Any 3 digits | Successful payment |
| 4000 0000 0000 0002 | Any future | Any 3 digits | Card declined |
| 5555 5555 5555 4444 | Any future | Any 3 digits | Visa |

## Next Steps

1. ✅ Get Stripe API keys from https://dashboard.stripe.com/apikeys
2. ✅ Update backend `application.properties` with secret key
3. ✅ Update frontend `StripePaymentForm.jsx` with publishable key
4. ✅ Install `@stripe/js` and `@stripe/react-stripe-js` npm packages
5. ✅ Integrate `StripePaymentForm` into your checkout flow
6. ✅ Test with Stripe test cards
7. ✅ Go live by switching to production keys

## API Endpoints Created

### Create Payment Intent
```
POST /api/payments/create-intent
Content-Type: application/json
Authorization: Bearer {token}

{
  "orderId": 1,
  "userId": 1
}

Response:
{
  "clientSecret": "pi_xxxxx_secret_xxxxx",
  "paymentIntentId": "pi_xxxxx",
  "amount": 1299.99
}
```

### Confirm Payment
```
POST /api/payments/confirm
Content-Type: application/json

{
  "paymentIntentId": "pi_xxxxx"
}

Response:
{
  "success": true,
  "status": "succeeded",
  "paymentStatus": "SUCCEEDED"
}
```

### Get Payment Status
```
GET /api/payments/order/{orderId}
Authorization: Bearer {token}

Response:
{
  "id": 1,
  "status": "SUCCEEDED",
  "amount": 1299.99,
  "currency": "USD",
  "last4Digits": "4242"
}
```

## Database Schema

```sql
-- payments table will be automatically created by Hibernate
-- Fields:
-- id (Long) - Primary key
-- order_id (Long) - Foreign key to orders
-- user_id (Long) - Foreign key to users
-- stripe_payment_intent_id (String) - Stripe PI ID
-- stripe_client_secret (String) - Secret for client confirmation
-- amount (BigDecimal) - Payment amount
-- currency (String) - Currency code (USD, EUR, etc)
-- status (String) - PENDING, PROCESSING, SUCCEEDED, FAILED, CANCELED
-- payment_method (String) - Payment method type
-- last4_digits (String) - Last 4 digits of card
-- created_at (LocalDateTime)
-- updated_at (LocalDateTime)
```

## Troubleshooting

### Build Issues
If Maven build fails:
1. Clear Maven cache: `./mvnw clean`
2. Download dependencies: `./mvnw dependency:resolve`
3. Rebuild: `./mvnw clean package -DskipTests`

### Stripe Connection Issues
- Verify API key is correct (starts with `sk_test_` or `sk_live_`)
- Check CORS configuration allows your frontend domain
- Enable Stripe in application.properties

### Payment Form Not Loading
- Verify Stripe publishable key is correct
- Check browser console for errors
- Ensure `@stripe/js` and `@stripe/react-stripe-js` are installed

---

Status: ✅ Backend implementation complete, awaiting Stripe API keys for testing
