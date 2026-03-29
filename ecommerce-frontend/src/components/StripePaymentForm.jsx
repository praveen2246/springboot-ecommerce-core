import { useState } from 'react'
import { loadStripe } from '@stripe/js'
import { Elements, CardElement, useStripe, useElements } from '@stripe/react-stripe-js'
import axios from 'axios'
import './StripePaymentForm.css'

const stripePromise = loadStripe('pk_test_YOUR_STRIPE_PUBLISHABLE_KEY_HERE')

export default function StripePaymentForm({ orderId, userId, totalAmount, onPaymentSuccess }) {
  return (
    <Elements stripe={stripePromise}>
      <PaymentFormContent orderId={orderId} userId={userId} totalAmount={totalAmount} onPaymentSuccess={onPaymentSuccess} />
    </Elements>
  )
}

function PaymentFormContent({ orderId, userId, totalAmount, onPaymentSuccess }) {
  const stripe = useStripe()
  const elements = useElements()
  const [loading, setLoading] = useState(false)
  const [clientSecret, setClientSecret] = useState(null)
  const [paymentIntentId, setPaymentIntentId] = useState(null)
  const [message, setMessage] = useState('')
  const [step, setStep] = useState(1) // 1: Create intent, 2: Confirm payment

  const createPaymentIntent = async () => {
    try {
      setLoading(true)
      setMessage('')

      const response = await axios.post('/api/payments/create-intent', {
        orderId,
        userId
      })

      setClientSecret(response.data.clientSecret)
      setPaymentIntentId(response.data.paymentIntentId)
      setStep(2)
      setMessage('Payment intent created. Enter card details to complete payment.')
    } catch (error) {
      setMessage('Error creating payment: ' + (error.response?.data?.error || error.message))
    } finally {
      setLoading(false)
    }
  }

  const handlePaymentSubmit = async (e) => {
    e.preventDefault()

    if (!stripe || !elements) {
      setMessage('Stripe has not loaded yet')
      return
    }

    try {
      setLoading(true)
      setMessage('')

      // Confirm payment with card element
      const { error, paymentIntent } = await stripe.confirmCardPayment(clientSecret, {
        payment_method: {
          card: elements.getElement(CardElement),
          billing_details: {
            name: 'Customer'
          }
        }
      })

      if (error) {
        setMessage('Payment failed: ' + error.message)
      } else if (paymentIntent.status === 'succeeded') {
        // Confirm payment on backend
        await axios.post('/api/payments/confirm', {
          paymentIntentId: paymentIntentId
        })

        setMessage('✅ Payment successful! Your order has been confirmed.')
        setTimeout(() => {
          onPaymentSuccess()
        }, 2000)
      } else {
        setMessage('Payment processing: ' + paymentIntent.status)
      }
    } catch (error) {
      setMessage('Error confirming payment: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="stripe-payment-form">
      <h3>Complete Payment</h3>
      <p className="amount">Amount: <strong>${totalAmount.toFixed(2)}</strong></p>

      {step === 1 ? (
        <button
          onClick={createPaymentIntent}
          disabled={loading}
          className="continue-btn"
        >
          {loading ? 'Creating Payment...' : 'Continue to Payment'}
        </button>
      ) : (
        <form onSubmit={handlePaymentSubmit}>
          <div className="card-element-wrapper">
            <label>Card Information</label>
            <CardElement
              options={{
                style: {
                  base: {
                    fontSize: '16px',
                    color: '#424770',
                    '::placeholder': {
                      color: '#aab7c4',
                    },
                  },
                  invalid: {
                    color: '#9e2146',
                  },
                },
              }}
            />
          </div>

          <button
            type="submit"
            disabled={!stripe || loading}
            className="pay-btn"
          >
            {loading ? 'Processing...' : `Pay $${totalAmount.toFixed(2)}`}
          </button>
        </form>
      )}

      {message && (
        <div className={`message ${message.includes('✅') ? 'success' : message.includes('Error') ? 'error' : 'info'}`}>
          {message}
        </div>
      )}
    </div>
  )
}
