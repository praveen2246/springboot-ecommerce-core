import React from 'react'
import '../styles/footer.css'

export default function Footer() {
  return (
    <footer className="footer">
      <div className="footer-content">
        <div className="footer-section">
          <h3>About Us</h3>
          <p>Your trusted online store for premium quality electronics and accessories.</p>
          <div className="social-links">
            <a href="#" className="social-link">f</a>
            <a href="#" className="social-link">𝕏</a>
            <a href="#" className="social-link">in</a>
            <a href="#" className="social-link">📧</a>
          </div>
        </div>

        <div className="footer-section">
          <h3>Quick Links</h3>
          <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/products">Products</a></li>
            <li><a href="/">About</a></li>
            <li><a href="/">Contact</a></li>
          </ul>
        </div>

        <div className="footer-section">
          <h3>Support</h3>
          <ul>
            <li><a href="/">Shipping Info</a></li>
            <li><a href="/">Returns</a></li>
            <li><a href="/">FAQ</a></li>
            <li><a href="/">Contact Us</a></li>
          </ul>
        </div>

        <div className="footer-section">
          <h3>Legal</h3>
          <ul>
            <li><a href="/">Privacy Policy</a></li>
            <li><a href="/">Terms of Service</a></li>
            <li><a href="/">Cookies</a></li>
            <li><a href="/">Disclaimer</a></li>
          </ul>
        </div>
      </div>

      <div className="footer-bottom">
        <p>&copy; 2026 Premium Store. All rights reserved.</p>
        <p>Built with ❤️ using React & Spring Boot</p>
      </div>
    </footer>
  )
}
