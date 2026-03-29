import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import '../styles/landing.css'

export default function LandingPage() {
  const [email, setEmail] = useState('')
  const [subscribed, setSubscribed] = useState(false)
  const navigate = useNavigate()

  const handleSubscribe = (e) => {
    e.preventDefault()
    if (email) {
      setSubscribed(true)
      setEmail('')
      setTimeout(() => setSubscribed(false), 3000)
    }
  }

  const handleShopNow = () => {
    navigate('/products')
  }

  return (
    <div className="landing-page">
      {/* Enhanced Hero Section */}
      <section className="hero-enhanced">
        <div className="hero-background-enhanced">
          <div className="gradient-blur blur-1"></div>
          <div className="gradient-blur blur-2"></div>
          <div className="gradient-blur blur-3"></div>
        </div>

        <div className="hero-content-enhanced">
          <h1 className="hero-title-large">
            Premium Tech Products,
            <span className="gradient-text"> Starting Today</span>
          </h1>
          
          <p className="hero-description">
            Discover our carefully curated collection of premium electronics and accessories. 
            Fast shipping, secure payments, and exceptional quality guaranteed.
          </p>

          <div className="cta-buttons-enhance">
            <button className="btn btn-primary btn-large" onClick={handleShopNow}>
              🛍️ Shop Now
            </button>
            <button className="btn btn-outline btn-large" onClick={handleShopNow}>
              ▶️ View Products
            </button>
          </div>

          <div className="hero-stats">
            <div className="stat-item">
              <div className="stat-number">10K+</div>
              <div className="stat-label">Happy Customers</div>
            </div>
            <div className="stat-item">
              <div className="stat-number">500+</div>
              <div className="stat-label">Products</div>
            </div>
            <div className="stat-item">
              <div className="stat-number">98%</div>
              <div className="stat-label">Satisfaction</div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="features-section">
        <div className="container">
          <h2 className="section-title">Why Choose Us?</h2>
          <p className="section-subtitle">Everything you need for a perfect shopping experience</p>

          <div className="features-grid">
            <div className="feature-card">
              <div className="feature-icon">⚡</div>
              <h3>Lightning Fast</h3>
              <p>Experience blazing fast load times and instant checkout. No waiting, just shopping.</p>
            </div>

            <div className="feature-card">
              <div className="feature-icon">🔒</div>
              <h3>Secure & Safe</h3>
              <p>Military-grade encryption protects your personal and payment information always.</p>
            </div>

            <div className="feature-card">
              <div className="feature-icon">🚀</div>
              <h3>Fast Delivery</h3>
              <p>Get your orders delivered quickly with real-time tracking and updates.</p>
            </div>

            <div className="feature-card">
              <div className="feature-icon">💬</div>
              <h3>24/7 Support</h3>
              <p>Our dedicated support team is always ready to help with any questions or concerns.</p>
            </div>

            <div className="feature-card">
              <div className="feature-icon">💳</div>
              <h3>Multiple Payments</h3>
              <p>Pay with credit cards, digital wallets, and popular payment methods globally.</p>
            </div>

            <div className="feature-card">
              <div className="feature-icon">🎁</div>
              <h3>Special Offers</h3>
              <p>Enjoy exclusive deals, discounts, and rewards for loyal customers every day.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section className="testimonials-section">
        <div className="container">
          <h2 className="section-title">Customer Love</h2>
          <p className="section-subtitle">What our customers are saying about their experience</p>

          <div className="testimonials-grid">
            <div className="testimonial-card">
              <div className="stars">⭐⭐⭐⭐⭐</div>
              <p className="testimonial-text">
                "The best online shopping experience I've had. Fast delivery, great products, and excellent customer service!"
              </p>
              <div className="testimonial-author">
                <div className="author-avatar">👤</div>
                <div>
                  <p className="author-name">Sarah Johnson</p>
                  <p className="author-title">Verified Buyer</p>
                </div>
              </div>
            </div>

            <div className="testimonial-card">
              <div className="stars">⭐⭐⭐⭐⭐</div>
              <p className="testimonial-text">
                "Premium quality products at great prices. My orders always arrive on time and perfectly packaged."
              </p>
              <div className="testimonial-author">
                <div className="author-avatar">👨</div>
                <div>
                  <p className="author-name">Mike Chen</p>
                  <p className="author-title">Verified Buyer</p>
                </div>
              </div>
            </div>

            <div className="testimonial-card">
              <div className="stars">⭐⭐⭐⭐⭐</div>
              <p className="testimonial-text">
                "Outstanding selection and competitive prices. I've recommended this store to all my friends!"
              </p>
              <div className="testimonial-author">
                <div className="author-avatar">👩</div>
                <div>
                  <p className="author-name">Emma Rodriguez</p>
                  <p className="author-title">Verified Buyer</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Trust Badges Section */}
      <section className="trust-section">
        <div className="container">
          <h2 className="section-title">Trusted By Millions</h2>
          
          <div className="trust-grid">
            <div className="trust-badge">
              <div className="badge-icon">✓</div>
              <h3>100% Authentic</h3>
              <p>All products are genuine and sourced directly from authorized distributors</p>
            </div>

            <div className="trust-badge">
              <div className="badge-icon">🛡️</div>
              <h3>Money-Back Guarantee</h3>
              <p>Not satisfied? Get a full refund within 30 days, no questions asked</p>
            </div>

            <div className="trust-badge">
              <div className="badge-icon">🔐</div>
              <h3>Secure Checkout</h3>
              <p>SSL encrypted transactions and PCI compliant payment processing</p>
            </div>

            <div className="trust-badge">
              <div className="badge-icon">📦</div>
              <h3>Free Shipping</h3>
              <p>Free shipping on orders over ₹500. Track your package in real time</p>
            </div>
          </div>
        </div>
      </section>

      {/* Newsletter Section */}
      <section className="newsletter-section">
        <div className="container">
          <div className="newsletter-content">
            <h2>Stay Updated</h2>
            <p>Get exclusive deals, new product launches, and insider tips delivered to your inbox</p>

            <form className="newsletter-form" onSubmit={handleSubscribe}>
              <input
                type="email"
                placeholder="Enter your email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <button type="submit" className="btn btn-primary">
                Subscribe Now
              </button>
            </form>

            {subscribed && (
              <div className="success-message">
                ✓ Thank you for subscribing! Check your email for exclusive offers.
              </div>
            )}

            <p className="newsletter-note">
              We respect your privacy. Unsubscribe anytime.
            </p>
          </div>
        </div>
      </section>

      {/* FAQ Section */}
      <section className="faq-section">
        <div className="container">
          <h2 className="section-title">Frequently Asked Questions</h2>

          <div className="faq-grid">
            <div className="faq-item">
              <h3>How quickly does shipping work?</h3>
              <p>Most orders ship within 24 hours. Delivery typically takes 3-5 business days depending on your location.</p>
            </div>

            <div className="faq-item">
              <h3>What's your return policy?</h3>
              <p>We offer a hassle-free 30-day return policy. If you're not satisfied, return your items for a full refund.</p>
            </div>

            <div className="faq-item">
              <h3>Is my payment information safe?</h3>
              <p>Yes! We use industry-leading SSL encryption and are PCI compliant. Your data is always protected.</p>
            </div>

            <div className="faq-item">
              <h3>Do you offer international shipping?</h3>
              <p>Currently we ship within India. We're expanding internationally soon. Subscribe for updates!</p>
            </div>

            <div className="faq-item">
              <h3>How can I track my order?</h3>
              <p>You'll receive a tracking number via email once your order ships. Track it in real time from your account.</p>
            </div>

            <div className="faq-item">
              <h3>What payment methods do you accept?</h3>
              <p>We accept all major credit cards, debit cards, net banking, wallets, and UPI payments.</p>
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}
