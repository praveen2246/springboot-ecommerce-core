import { useContext, useState, useEffect } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import { AuthContext } from '../context/AuthContext'
import { ThemeContext } from '../context/ThemeContext'
import './NavBar.css'

export default function NavBar() {
  const navigate = useNavigate()
  const location = useLocation()
  const { isAuthenticated, user, logout } = useContext(AuthContext)
  const { isDarkMode, toggleTheme } = useContext(ThemeContext)
  const [showUserMenu, setShowUserMenu] = useState(false)
  const [cartCount, setCartCount] = useState(0)
  const [isAnimating, setIsAnimating] = useState(false)

  useEffect(() => {
    // Get cart count from localStorage
    try {
      const cart = JSON.parse(localStorage.getItem('cart')) || []
      setCartCount(cart.length)
    } catch (error) {
      setCartCount(0)
    }
  }, [])

  useEffect(() => {
    // Close user menu if authentication state changes
    setShowUserMenu(false)
  }, [isAuthenticated])

  // Listen for storage changes to update cart count
  useEffect(() => {
    const handleStorageChange = () => {
      try {
        const cart = JSON.parse(localStorage.getItem('cart')) || []
        setCartCount(cart.length)
      } catch (error) {
        setCartCount(0)
      }
    }
    window.addEventListener('storage', handleStorageChange)
    return () => window.removeEventListener('storage', handleStorageChange)
  }, [])

  const isActive = (path) => location.pathname === path

  const handleLogout = () => {
    logout()
    setShowUserMenu(false)
    navigate('/login')
  }

  const handleThemeToggle = () => {
    setIsAnimating(true)
    toggleTheme()
    setTimeout(() => setIsAnimating(false), 600)
  }

  return (
    <nav className="navbar">
      <div className="navbar-brand">
        <div className="logo-icon">🛍️</div>
        <h1 onClick={() => navigate('/')}>TechStore</h1>
      </div>
      
      <div className="nav-buttons">
        <button 
          className={isActive('/products') ? 'nav-btn active' : 'nav-btn'} 
          onClick={() => navigate('/products')}
        >
          📦 Products
        </button>
        
        {isAuthenticated && (
          <>
            <button 
              className={isActive('/cart') ? 'nav-btn active' : 'nav-btn cart-btn'} 
              onClick={() => navigate('/cart')}
            >
              🛒 Cart
              {cartCount > 0 && <span className="cart-badge">{cartCount}</span>}
            </button>
            <button 
              className={isActive('/orders') ? 'nav-btn active' : 'nav-btn'} 
              onClick={() => navigate('/orders')}
            >
              📋 Orders
            </button>
          </>
        )}

        {isAuthenticated ? (
          <div className="user-menu">
            <button 
              className="user-btn"
              onClick={() => setShowUserMenu(!showUserMenu)}
            >
              <span className="user-avatar">👤</span>
              <span className="user-name">{user?.username || 'User'}</span>
            </button>
            {showUserMenu && (
              <div className="dropdown-menu">
                <div className="menu-header">{user?.email}</div>
                <button onClick={handleLogout} className="logout-btn">
                  🚪 Logout
                </button>
              </div>
            )}
          </div>
        ) : (
          <>
            <button 
              className={isActive('/login') ? 'nav-btn active' : 'nav-btn'} 
              onClick={() => navigate('/login')}
            >
              🔑 Login
            </button>
            <button 
              className={isActive('/register') ? 'nav-btn active signup' : 'nav-btn signup'} 
              onClick={() => navigate('/register')}
            >
              ✏️ Sign Up
            </button>
          </>
        )}

        <button 
          className={`theme-toggle ${isAnimating ? 'theme-toggle-animate' : ''}`}
          onClick={handleThemeToggle}
          title={isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
        >
          {isDarkMode ? '☀️' : '🌙'}
        </button>
      </div>
    </nav>
  )
}
