import './ProductList.css'

export default function ProductList({ products, loading, onAddToCart }) {
  if (loading) {
    return <div className="loading">⏳ Loading products...</div>
  }

  if (!products || products.length === 0) {
    return <div className="loading">📦 No products available</div>
  }

  return (
    <div className="product-list">
      <div className="product-list-header">
        <h2>🛍️ Our Products</h2>
        <p className="product-count">Showing {products.length} products</p>
      </div>
      <div className="products-grid">
        {products.map(product => (
          <div key={product.id} className="product-card">
            <div className="product-image-container">
              <div className="product-icon">📱</div>
              <div className="product-badge">Popular</div>
            </div>
            <div className="product-header">
              <h3>{product.name}</h3>
            </div>
            <p className="description">{product.description}</p>
            <div className="product-meta">
              <span className={`stock ${product.stock > 0 ? 'in-stock' : 'out-of-stock'}`}>
                {product.stock > 0 ? `✓ ${product.stock} in stock` : '✗ Out of stock'}
              </span>
            </div>
            <div className="product-footer">
              <div className="price-container">
                <span className="price">₹{product.price}</span>
              </div>
              <button 
                className="add-btn"
                onClick={() => onAddToCart(product)}
                disabled={product.stock === 0}
              >
                {product.stock > 0 ? '🛒 Add to Cart' : 'Out of Stock'}
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
