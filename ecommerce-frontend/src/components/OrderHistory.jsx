import { useState, useEffect } from 'react'
import axios from 'axios'
import './OrderHistory.css'

export default function OrderHistory({ userId }) {
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(true)
  const [selectedOrder, setSelectedOrder] = useState(null)
  const [message, setMessage] = useState('')

  useEffect(() => {
    fetchOrders()
  }, [userId])

  const fetchOrders = async () => {
    try {
      setLoading(true)
      const response = await axios.get(`/api/orders/user/${userId}`)
      const ordersData = response.data.orders || response.data || []
      setOrders(Array.isArray(ordersData) ? ordersData : [])
    } catch (error) {
      setMessage('Error loading orders: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const updateOrderStatus = async (orderId, newStatus) => {
    try {
      await axios.put(`/api/orders/${orderId}/status`, { status: newStatus })
      fetchOrders()
      setMessage('Order status updated!')
      setTimeout(() => setMessage(''), 3000)
    } catch (error) {
      setMessage('Error updating order: ' + error.message)
    }
  }

  if (loading) {
    return <div className="loading">Loading orders...</div>
  }

  if (!orders || orders.length === 0) {
    return (
      <div className="no-orders">
        <h2>No Orders Yet</h2>
        <p>Start shopping to place your first order!</p>
      </div>
    )
  }

  return (
    <div className="order-history">
      <h2>Order History</h2>
      
      {message && (
        <div className="message success">
          {message}
        </div>
      )}

      <div className="orders-list">
        {orders.map(order => (
          <div key={order.id} className="order-card">
            <div className="order-header">
              <div>
                <h3>Order #{order.id}</h3>
                <p className="order-date">
                  {new Date(order.createdAt).toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                  })}
                </p>
              </div>
              <div className="order-status">
                <span className={`status-badge ${order.status.toLowerCase()}`}>
                  {order.status}
                </span>
              </div>
            </div>

            <div className="order-summary">
              <div className="summary-item">
                <span className="label">Total:</span>
                <span className="value">₹{order.totalPrice.toFixed(2)}</span>
              </div>
              <div className="summary-item">
                <span className="label">Items:</span>
                <span className="value">{order.totalQuantity}</span>
              </div>
            </div>

            <button 
              className="expand-btn"
              onClick={() => setSelectedOrder(selectedOrder?.id === order.id ? null : order)}
            >
              {selectedOrder?.id === order.id ? 'Hide Details' : 'View Details'}
            </button>

            {selectedOrder?.id === order.id && (
              <div className="order-details">
                <div className="details-section">
                  <h4>Shipping Address</h4>
                  <p>{order.shippingAddress}</p>
                </div>

                {order.notes && (
                  <div className="details-section">
                    <h4>Order Notes</h4>
                    <p>{order.notes}</p>
                  </div>
                )}

                <div className="details-section">
                  <h4>Items ({order.items?.length || 0})</h4>
                  <div className="items-list">
                    {order.items && order.items.map(item => {
                      const productName = typeof item.product === 'string' 
                        ? item.product 
                        : (item.product?.name || 'Product')
                      return (
                        <div key={item.id} className="order-item">
                          <span className="item-info">
                            {productName} x {item.quantity}
                          </span>
                          <span className="item-price">
                            ₹{(item.unitPrice * item.quantity).toFixed(2)}
                          </span>
                        </div>
                      )
                    })}
                  </div>
                </div>

                {order.status !== 'DELIVERED' && (
                  <div className="status-actions">
                    <button 
                      className="status-btn"
                      onClick={() => {
                        const statusFlow = ['PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED']
                        const currentIndex = statusFlow.indexOf(order.status)
                        if (currentIndex < statusFlow.length - 1) {
                          updateOrderStatus(order.id, statusFlow[currentIndex + 1])
                        }
                      }}
                    >
                      Mark as {getNextStatus(order.status)}
                    </button>
                  </div>
                )}
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}

function getNextStatus(currentStatus) {
  const flow = {
    'PENDING': 'Confirmed',
    'CONFIRMED': 'Shipped',
    'SHIPPED': 'Delivered'
  }
  return flow[currentStatus] || 'Confirmed'
}
