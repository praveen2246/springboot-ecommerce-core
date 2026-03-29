import { useState, useEffect } from 'react'
import API from '../services/api'
import './Cart.css'

export default function Cart({ userId, onCheckoutClick, onOrderSuccess }) {
  const [cartData, setCartData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [message, setMessage] = useState('')

  useEffect(() => {
    fetchCart()
  }, [userId])

  const fetchCart = async () => {
    try {
      setLoading(true)
      const response = await API.get(`/api/cart/${userId}`)
      setCartData(response.data)
    } catch (error) {
      setMessage('Error loading cart: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const removeFromCart = async (itemId) => {
    try {
      await API.delete(`/api/cart/items/${itemId}`)
      fetchCart()
    } catch (error) {
      setMessage('Error removing item: ' + error.message)
    }
  }

  const clearCart = async () => {
    try {
      await API.delete(`/api/cart/${userId}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
      fetchCart()
      setMessage('Cart cleared!')
    } catch (error) {
      setMessage('Error clearing cart: ' + error.message)
    }
  }

  if (loading) {
    return <div className="loading">Loading cart...</div>
  }

  if (!cartData || !cartData.items || cartData.items.length === 0) {
    return (
      <div className="cart-empty">
        <h2>Your Cart is Empty</h2>
        <p>Add some products to get started!</p>
      </div>
    )
  }

  return (
    <div className="cart-container">
      <h2>Shopping Cart</h2>
      
      {message && (
        <div className={`message ${message.includes('✓') ? 'success' : 'error'}`}>
          {message}
        </div>
      )}

      <div className="cart-content">
        <div className="cart-items">
          <div className="items-header">
            <span>Product</span>
            <span>Price</span>
            <span>Qty</span>
            <span>Total</span>
            <span></span>
          </div>
          
          {cartData.items.map(item => (
            <div key={item.id} className="cart-item">
              <span className="item-name">{item.product?.name || 'Product'}</span>
              <span className="item-price">₹{item.product?.price?.toFixed(2) || '0.00'}</span>
              <span className="item-qty">{item.quantity}</span>
              <span className="item-total">₹{((item.product?.price || 0) * item.quantity).toFixed(2)}</span>
              <button 
                className="remove-btn"
                onClick={() => removeFromCart(item.id)}
              >
                Remove
              </button>
            </div>
          ))}
        </div>

        <div className="cart-summary">
          <div className="summary-box">
            <h3>Order Summary</h3>
            <div className="summary-row">
              <span>Subtotal:</span>
              <span>₹{(cartData.items.reduce((total, item) => total + ((item.product?.price || 0) * item.quantity), 0)).toFixed(2)}</span>
            </div>
            <div className="summary-row">
              <span>Shipping:</span>
              <span>FREE</span>
            </div>
            <div className="summary-row total">
              <span>Total:</span>
              <span>₹{(cartData.items.reduce((total, item) => total + ((item.product?.price || 0) * item.quantity), 0)).toFixed(2)}</span>
            </div>

            <button 
              onClick={onCheckoutClick}
              className="checkout-btn"
            >
              Proceed to Checkout
            </button>

            <button 
              onClick={clearCart}
              className="clear-btn"
            >
              Clear Cart
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
