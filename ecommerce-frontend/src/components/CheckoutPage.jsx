import React, { useContext, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { AuthContext } from '../context/AuthContext';
import API from '../services/api';
import RazorpayPaymentForm from './RazorpayPaymentForm';
import './CheckoutPage.css';

const CheckoutPage = () => {
  const { user } = useContext(AuthContext);
  const navigate = useNavigate();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [cartItems, setCartItems] = useState([]);
  const [shippingAddress, setShippingAddress] = useState('');
  const [notes, setNotes] = useState('');
  const [paymentStarted, setPaymentStarted] = useState(false);

  useEffect(() => {
    if (!user) {
      navigate('/login');
      return;
    }

    fetchCart();
  }, [user, navigate]);

  const fetchCart = async () => {
    try {
      setLoading(true);
      const response = await API.get(
        `/api/cart/${user.id}`
      );
      
      if (response.data) {
        setCartItems(response.data.items || []);
      }
    } catch (err) {
      setError('Failed to fetch cart');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const calculateTotal = () => {
    return cartItems.reduce((total, item) => {
      return total + (item.product.price * item.quantity);
    }, 0);
  };

  const handleCreateOrder = async () => {
    try {
      setLoading(true);
      setError(null);

      if (!shippingAddress.trim()) {
        setError('Please enter a shipping address');
        setLoading(false);
        return;
      }

      const response = await API.post(
        '/api/orders/checkout',
        {
          userId: user.id,
          shippingAddress: shippingAddress,
          notes: notes
        }
      );

      setOrder(response.data);
      setPaymentStarted(true);
    } catch (err) {
      console.error('Order creation error:', err);
      setError(
        err.response?.data?.message || 
        'Failed to create order. Please try again.'
      );
    } finally {
      setLoading(false);
    }
  };

  const handlePaymentSuccess = async (paymentResult) => {
    console.log('Payment successful:', paymentResult);
    // Redirect to order confirmation page
    navigate(`/order-confirmation/${order.orderId}`, { 
      state: { paymentResult } 
    });
  };

  const handlePaymentError = (errorMessage) => {
    console.error('Payment error:', errorMessage);
    setError('Payment failed. Please try again.');
    setPaymentStarted(false);
  };

  if (!user) {
    return (
      <div className="checkout-container">
        <p>Please log in to place an order.</p>
      </div>
    );
  }

  const total = calculateTotal();

  return (
    <div className="checkout-page">
      <h1>Checkout</h1>

      <div className="checkout-container">
        <div className="order-summary">
          <h2>Order Summary</h2>

          {error && (
            <div className="error-alert">
              <strong>Error:</strong> {error}
            </div>
          )}

          {cartItems.length === 0 ? (
            <div className="empty-cart">
              <p>Your cart is empty. Add items before checkout.</p>
              <button 
                className="btn-continue-shopping"
                onClick={() => navigate('/products')}
              >
                Continue Shopping
              </button>
            </div>
          ) : (
            <>
              <div className="cart-items-checkout">
                <table className="items-table">
                  <thead>
                    <tr>
                      <th>Product</th>
                      <th>Price</th>
                      <th>Quantity</th>
                      <th>Total</th>
                    </tr>
                  </thead>
                  <tbody>
                    {cartItems.map((item) => (
                      <tr key={item.id}>
                        <td>{item.product.name}</td>
                        <td>₹{item.product.price.toFixed(2)}</td>
                        <td>{item.quantity}</td>
                        <td>₹{(item.product.price * item.quantity).toFixed(2)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              <div className="order-total">
                <h3>Total: ₹{total.toFixed(2)}</h3>
              </div>

              {!paymentStarted ? (
                <form className="checkout-form" onSubmit={(e) => {
                  e.preventDefault();
                  handleCreateOrder();
                }}>
                  <div className="form-group">
                    <label htmlFor="shippingAddress">Shipping Address *</label>
                    <textarea
                      id="shippingAddress"
                      value={shippingAddress}
                      onChange={(e) => setShippingAddress(e.target.value)}
                      placeholder="Enter your full shipping address"
                      rows="4"
                      required
                    />
                  </div>

                  <div className="form-group">
                    <label htmlFor="notes">Order Notes (Optional)</label>
                    <textarea
                      id="notes"
                      value={notes}
                      onChange={(e) => setNotes(e.target.value)}
                      placeholder="Any special instructions for this order"
                      rows="3"
                    />
                  </div>

                  <button 
                    type="submit"
                    className="btn-proceed-payment"
                    disabled={loading}
                  >
                    {loading ? 'Processing...' : 'Proceed to Payment'}
                  </button>
                </form>
              ) : order && (
                <RazorpayPaymentForm
                  orderId={order.orderId}
                  amount={total}
                  onPaymentSuccess={handlePaymentSuccess}
                  onPaymentError={handlePaymentError}
                />
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default CheckoutPage;
