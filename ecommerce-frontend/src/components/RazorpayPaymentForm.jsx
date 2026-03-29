import React, { useContext, useEffect, useState } from 'react';
import { AuthContext } from '../context/AuthContext';
import API from '../services/api';
import './RazorpayPaymentForm.css';

const RazorpayPaymentForm = ({ orderId, amount, onPaymentSuccess, onPaymentError }) => {
  const { user } = useContext(AuthContext);
  const [loading, setLoading] = useState(false);
  const [orderDetails, setOrderDetails] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Load Razorpay script
    const script = document.createElement('script');
    script.src = 'https://checkout.razorpay.com/v1/checkout.js';
    script.async = true;
    script.onload = () => {
      console.log('Razorpay script loaded');
    };
    script.onerror = () => {
      setError('Failed to load Razorpay. Please refresh the page.');
      console.error('Failed to load Razorpay script');
    };
    document.body.appendChild(script);

    return () => {
      // Cleanup if needed
      if (document.body.contains(script)) {
        document.body.removeChild(script);
      }
    };
  }, []);

  const handlePayment = async () => {
    try {
      setLoading(true);
      setError(null);

      // Step 1: Create Razorpay order
      console.log('Creating Razorpay order for orderId:', orderId, 'userId:', user?.id);
      
      const orderResponse = await API.post(
        '/api/payments/razorpay/create-order',
        {
          orderId: orderId,
          userId: user?.id
        }
      );

      console.log('Order created:', orderResponse.data);
      setOrderDetails(orderResponse.data);

      const { orderId: razorpayOrderId, keyId, userEmail, userName, isMockMode } = orderResponse.data;

      // Step 2: Check if in mock mode
      if (isMockMode) {
        // Show mock payment modal for testing
        showMockPaymentModal(razorpayOrderId, userEmail, userName, orderResponse.data);
        return;
      }

      // Step 3: Open real Razorpay checkout
      const options = {
        key: keyId,
        amount: orderResponse.data.amountInPaise,
        currency: 'INR',
        name: 'E-Commerce Store',
        description: `Payment for Order #${orderId}`,
        order_id: razorpayOrderId,
        prefill: {
          name: userName || 'Customer',
          email: userEmail || 'customer@example.com'
        },
        theme: {
          color: '#007bff'
        },
        handler: async (response) => {
          // Step 4: Verify payment on backend
          try {
            console.log('Payment response:', response);
            
            const verifyResponse = await API.post(
              '/api/payments/razorpay/verify',
              {
                razorpayOrderId: response.razorpay_order_id,
                razorpayPaymentId: response.razorpay_payment_id,
                razorpaySignature: response.razorpay_signature
              }
            );

            console.log('Verification response:', verifyResponse.data);

            if (verifyResponse.data.success) {
              console.log('Payment verified successfully');
              onPaymentSuccess(verifyResponse.data);
            } else {
              console.error('Payment verification failed');
              setError('Payment verification failed. Please contact support.');
              onPaymentError('Payment verification failed');
            }
          } catch (verifyError) {
            console.error('Verification error:', verifyError);
            setError(
              verifyError.response?.data?.error || 
              'Payment verification failed. Please try again.'
            );
            onPaymentError(verifyError.message);
          }
        },
        modal: {
          ondismiss: () => {
            console.log('Checkout closed');
            setLoading(false);
          }
        }
      };

      // Open real Razorpay checkout
      if (window.Razorpay) {
        const rzp = new window.Razorpay(options);
        rzp.open();
      } else {
        setError('Razorpay is not loaded. Please refresh the page.');
      }
    } catch (err) {
      console.error('Payment setup error:', err);
      setError(
        err.response?.data?.error || 
        'Failed to process payment. Please try again.'
      );
      onPaymentError(err.message);
      setLoading(false);
    }
  };

  const showMockPaymentModal = async (razorpayOrderId, userEmail, userName, orderData) => {
    // For development/testing without real Razorpay credentials
    const mockPaymentId = 'pay_mock_' + Date.now();
    const mockSignature = 'mock_signature_' + Math.random().toString(36).substr(2, 9);

    try {
      setLoading(true);
      // Simulate payment verification with mock data
      const verifyResponse = await API.post(
        '/api/payments/razorpay/verify',
        {
          razorpayOrderId: razorpayOrderId,
          razorpayPaymentId: mockPaymentId,
          razorpaySignature: mockSignature,
          isMockMode: true
        }
      );

      console.log('Mock payment verified:', verifyResponse.data);

      if (verifyResponse.data.success) {
        onPaymentSuccess(verifyResponse.data);
      } else {
        setError('Payment verification failed');
        onPaymentError('Payment verification failed');
      }
    } catch (err) {
      console.error('Mock payment error:', err);
      setError(err.response?.data?.error || 'Payment failed');
      onPaymentError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="razorpay-payment-form">
      <h3>Complete Payment</h3>

      {error && (
        <div className="error-message">
          <strong>Error:</strong> {error}
        </div>
      )}

      <div className="payment-summary">
        <p>
          <strong>Order ID:</strong> #{orderId}
        </p>
        <p>
          <strong>Amount:</strong> ₹{amount?.toFixed(2) || '0.00'}
        </p>
        <p>
          <strong>Currency:</strong> INR
        </p>
      </div>

      <button
        className="btn-razorpay-pay"
        onClick={handlePayment}
        disabled={loading || !user || !orderId}
      >
        {loading ? 'Processing...' : 'Pay Now with Razorpay'}
      </button>

      {!user && (
        <p className="info-message">
          Please log in to proceed with payment.
        </p>
      )}

      {!orderId && (
        <p className="info-message">
          Please create an order first.
        </p>
      )}

      {orderDetails && (
        <div className="debug-info">
          <p><strong>Debug (Order Details):</strong></p>
          <pre>{JSON.stringify(orderDetails, null, 2)}</pre>
        </div>
      )}
    </div>
  );
};

export default RazorpayPaymentForm;
