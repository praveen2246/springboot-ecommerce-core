import React, { useContext, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { AuthContext } from '../context/AuthContext';
import API from '../services/api';
import './OrderConfirmationPage.css';

const OrderConfirmationPage = () => {
  const { orderId } = useParams();
  const { user } = useContext(AuthContext);
  const navigate = useNavigate();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!user) {
      navigate('/login');
      return;
    }

    fetchOrder();
  }, [user, orderId, navigate]);

  const fetchOrder = async () => {
    try {
      setLoading(true);
      const response = await API.get(
        `/api/orders/${orderId}`
      );
      setOrder(response.data);
    } catch (err) {
      console.error('Failed to fetch order:', err);
      setError('Failed to load order details');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="confirmation-container">
        <p>Loading order details...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="confirmation-container">
        <div className="error-alert">
          <p>{error}</p>
        </div>
      </div>
    );
  }

  if (!order) {
    return (
      <div className="confirmation-container">
        <p>Order not found.</p>
      </div>
    );
  }

  const total = order.items.reduce((sum, item) => {
    return sum + (item.product.price * item.quantity);
  }, 0);

  return (
    <div className="order-confirmation-page">
      <div className="confirmation-container">
        <div className="confirmation-header success">
          <div className="success-icon">✓</div>
          <h1>Payment Successful!</h1>
          <p>Your order has been confirmed and payment received</p>
        </div>

        <div className="order-details-card">
          <div className="order-info-section">
            <h2>Order Details</h2>
            
            <div className="info-row">
              <span className="label">Order ID:</span>
              <span className="value">#{order.id}</span>
            </div>

            <div className="info-row">
              <span className="label">Order Date:</span>
              <span className="value">
                {new Date(order.createdAt).toLocaleDateString()}
              </span>
            </div>

            <div className="info-row">
              <span className="label">Order Status:</span>
              <span className="value status confirmed">{order.status}</span>
            </div>

            <div className="info-row">
              <span className="label">Shipping Address:</span>
              <span className="value">{order.shippingAddress}</span>
            </div>
          </div>

          <div className="order-items-section">
            <h2>Items Ordered</h2>
            
            <div className="items-table">
              <div className="item-header">
                <strong>Product</strong>
                <strong>Price</strong>
                <strong>Quantity</strong>
                <strong>Total</strong>
              </div>

              {order.items.map((item) => (
                <div className="item-row" key={item.id}>
                  <span>{item.product.name}</span>
                  <span>₹{item.product.price.toFixed(2)}</span>
                  <span>{item.quantity}</span>
                  <span>₹{(item.product.price * item.quantity).toFixed(2)}</span>
                </div>
              ))}
            </div>

            <div className="order-total-row">
              <strong>Total Amount:</strong>
              <strong className="amount">₹{total.toFixed(2)}</strong>
            </div>
          </div>

          {order.notes && (
            <div className="order-notes-section">
              <h3>Special Instructions:</h3>
              <p>{order.notes}</p>
            </div>
          )}
        </div>

        <div className="confirmation-actions">
          <button 
            className="btn-view-orders"
            onClick={() => navigate('/orders')}
          >
            View All Orders
          </button>
          <button 
            className="btn-continue-shopping"
            onClick={() => navigate('/products')}
          >
            Continue Shopping
          </button>
        </div>

        <div className="confirmation-next-steps">
          <h3>What's Next?</h3>
          <ul>
            <li>You will receive a confirmation email shortly</li>
            <li>Your order will be processed and shipped within 2-3 business days</li>
            <li>You can track your order status from your account</li>
            <li>Contact us at support@ecommerce.com for any queries</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default OrderConfirmationPage;
