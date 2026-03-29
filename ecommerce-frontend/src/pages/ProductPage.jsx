import { useState, useEffect, useContext } from 'react'
import { useNavigate } from 'react-router-dom'
import { AuthContext } from '../context/AuthContext'
import API from '../services/api'
import ProductList from '../components/ProductList'
import HeroSection from '../components/HeroSection'
import './ProductPage.css'

export default function ProductPage() {
  const { user } = useContext(AuthContext)
  const navigate = useNavigate()
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(false)
  const [searchKeyword, setSearchKeyword] = useState('')
  const [minPrice, setMinPrice] = useState('')
  const [maxPrice, setMaxPrice] = useState('')
  const [filterError, setFilterError] = useState('')

  useEffect(() => {
    fetchProducts()
  }, [])

  const fetchProducts = async () => {
    try {
      setLoading(true)
      setFilterError('')
      const response = await API.get('/api/products')
      setProducts(Array.isArray(response.data) ? response.data : response.data.products || [])
    } catch (error) {
      console.error('Error fetching products:', error)
      setFilterError('Failed to fetch products')
    } finally {
      setLoading(false)
    }
  }

  const handleSearch = async (e) => {
    e.preventDefault()
    if (!searchKeyword.trim()) {
      fetchProducts()
      return
    }
    
    try {
      setLoading(true)
      setFilterError('')
      const response = await API.get('/api/products/search', {
        params: { keyword: searchKeyword }
      })
      setProducts(Array.isArray(response.data) ? response.data : response.data.products || [])
    } catch (error) {
      console.error('Error searching products:', error)
      setFilterError('No products found matching your search')
      setProducts([])
    } finally {
      setLoading(false)
    }
  }

  const handleFilterPrice = async (e) => {
    e.preventDefault()
    
    if (!minPrice || !maxPrice) {
      setFilterError('Please enter both minimum and maximum price')
      return
    }

    if (parseFloat(minPrice) > parseFloat(maxPrice)) {
      setFilterError('Minimum price cannot be greater than maximum price')
      return
    }
    
    try {
      setLoading(true)
      setFilterError('')
      const response = await API.get('/api/products/filter/price', {
        params: { minPrice, maxPrice }
      })
      setProducts(Array.isArray(response.data) ? response.data : response.data.products || [])
    } catch (error) {
      console.error('Error filtering products:', error)
      setFilterError(error.response?.data?.error || 'Failed to filter products')
      setProducts([])
    } finally {
      setLoading(false)
    }
  }

  const handleReset = () => {
    setSearchKeyword('')
    setMinPrice('')
    setMaxPrice('')
    setFilterError('')
    fetchProducts()
  }

  const addToCart = async (product) => {
    try {
      if (!user) {
        alert('Please login first')
        window.location.href = '/login'
        return
      }

      await API.post('/api/cart/items', {
        userId: user.id,
        productId: product.id,
        quantity: 1
      })
      alert('Added to cart!')
    } catch (error) {
      console.error('Error adding to cart:', error)
      alert('Failed to add to cart: ' + (error.response?.data?.message || error.message))
    }
  }

  return (
    <>
      <HeroSection />
      <div className="product-page-container">
        <div className="filters-section">
          <h3>🔍 Search & Filter Products</h3>
          
          {/* Search Bar */}
          <form onSubmit={handleSearch} className="search-form">
            <input
              type="text"
              placeholder="Search by product name..."
              value={searchKeyword}
              onChange={(e) => setSearchKeyword(e.target.value)}
              className="search-input"
            />
            <button type="submit" className="btn-search">
              🔍 Search
            </button>
          </form>

          {/* Price Filter */}
          <form onSubmit={handleFilterPrice} className="filter-form">
            <div className="price-inputs">
              <div className="input-group">
                <label>Min Price (₹)</label>
                <input
                  type="number"
                  placeholder="0"
                  value={minPrice}
                  onChange={(e) => setMinPrice(e.target.value)}
                  className="price-input"
                  min="0"
                  step="100"
                />
              </div>
              <div className="input-group">
                <label>Max Price (₹)</label>
                <input
                  type="number"
                  placeholder="1000000"
                  value={maxPrice}
                  onChange={(e) => setMaxPrice(e.target.value)}
                  className="price-input"
                  min="0"
                  step="100"
                />
              </div>
            </div>
            <button type="submit" className="btn-filter">
              💰 Filter by Price
            </button>
          </form>

          {/* Reset Button */}
          <button onClick={handleReset} className="btn-reset">
            🔄 Reset Filters
          </button>

          {/* Error Message */}
          {filterError && (
            <div className="filter-error">
              ⚠️ {filterError}
            </div>
          )}
        </div>

        <ProductList products={products} loading={loading} onAddToCart={addToCart} />
      </div>
    </>
  )
}
