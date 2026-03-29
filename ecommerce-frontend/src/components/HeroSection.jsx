import React from 'react'
import '../styles/hero.css'

export default function HeroSection() {
  return (
    <section className="hero-section">
      <div className="hero-background">
        <div className="hero-shapes">
          <div className="shape shape-1"></div>
          <div className="shape shape-2"></div>
          <div className="shape shape-3"></div>
        </div>
      </div>
      
      <div className="hero-content">
        <h1 className="hero-title">
          <span className="highlight">Premium Quality</span>
          <br />
          Tech Products
        </h1>
        
        <p className="hero-subtitle">
          Discover our collection of high-quality electronics and accessories
        </p>
        
        <div className="hero-buttons">
          <button className="btn btn-primary">
            ✨ Explore Now
          </button>
          <button className="btn btn-secondary">
            📚 Learn More
          </button>
        </div>
        
        <div className="hero-features">
          <div className="feature">
            <span className="feature-icon">🚚</span>
            <span className="feature-text">Fast Delivery</span>
          </div>
          <div className="feature">
            <span className="feature-icon">🛡️</span>
            <span className="feature-text">Secure Payment</span>
          </div>
          <div className="feature">
            <span className="feature-icon">⭐</span>
            <span className="feature-text">Quality Assured</span>
          </div>
        </div>
      </div>
    </section>
  )
}
