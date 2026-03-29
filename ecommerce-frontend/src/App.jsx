import { useContext, useEffect } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider, AuthContext } from './context/AuthContext'
import { ThemeProvider } from './context/ThemeContext'
import './styles/colors.css'
import './styles/theme.css'
import './styles/navbar.css'
import './styles/products.css'
import './styles/cart.css'
import './styles/auth.css'
import './styles/orders.css'
import './styles/hero.css'
import './styles/footer.css'
import './styles/landing.css'
import './App.css'
import NavBar from './components/NavBar'
import Footer from './components/Footer'
import LandingPage from './components/LandingPage'
import ProductPage from './pages/ProductPage'
import CartPage from './pages/CartPage'
import OrderHistoryPage from './pages/OrderHistoryPage'
import CheckoutPage from './components/CheckoutPage'
import OrderConfirmationPage from './components/OrderConfirmationPage'
import Login from './components/Login'
import Register from './components/Register'
import PaymentVerificationForm from './components/PaymentVerificationForm'

function AppContent() {
  const { isAuthenticated, user } = useContext(AuthContext)

  return (
    <div className="app">
      <NavBar />
      <main className="main-content">
        <Routes>
          <Route path="/" element={<LandingPage />} />
          <Route path="/products" element={<ProductPage />} />
          <Route path="/login" element={isAuthenticated ? <Navigate to="/products" /> : <Login />} />
          <Route path="/register" element={isAuthenticated ? <Navigate to="/products" /> : <Register />} />
          <Route path="/cart" element={isAuthenticated ? <CartPage /> : <Navigate to="/login" />} />
          <Route path="/checkout" element={isAuthenticated ? <CheckoutPage /> : <Navigate to="/login" />} />
          <Route path="/order-confirmation/:orderId" element={isAuthenticated ? <OrderConfirmationPage /> : <Navigate to="/login" />} />
          <Route path="/orders" element={isAuthenticated ? <OrderHistoryPage /> : <Navigate to="/login" />} />
          <Route path="/payment-verify" element={<PaymentVerificationForm />} />
        </Routes>
      </main>
      <Footer />
    </div>
  )
}

export default function App() {
  return (
    <ThemeProvider>
      <Router>
        <AuthProvider>
          <AppContent />
        </AuthProvider>
      </Router>
    </ThemeProvider>
  )
}
