import { useState } from 'react';
import '../styles/PaymentVerificationForm.css';

const API_BASE_URL = 'http://localhost:8080/api/payments';

export default function PaymentVerificationForm() {
  const [orderId, setOrderId] = useState('');
  const [paymentId, setPaymentId] = useState('');
  const [loading, setLoading] = useState(false);
  const [signature, setSignature] = useState('');
  const [message, setMessage] = useState('');
  const [status, setStatus] = useState(''); // 'success', 'error', 'generating', 'verifying'

  // Step 1: Generate signature
  const handleGenerateSignature = async () => {
    if (!orderId.trim() || !paymentId.trim()) {
      setMessage('❌ Please enter both Order ID and Payment ID');
      setStatus('error');
      return;
    }

    setLoading(true);
    setStatus('generating');
    setMessage('🔄 Generating signature...');

    try {
      const response = await fetch(`${API_BASE_URL}/test/generate-signature`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          orderId: orderId.trim(),
          paymentId: paymentId.trim(),
        }),
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const data = await response.json();
      setSignature(data.signature);
      setMessage(`✅ Signature generated successfully!`);
      setStatus('success');
    } catch (error) {
      setMessage(`❌ Error generating signature: ${error.message}`);
      setStatus('error');
      setSignature('');
    } finally {
      setLoading(false);
    }
  };

  // Step 2: Verify payment
  const handleVerifyPayment = async () => {
    if (!signature) {
      setMessage('❌ Please generate a signature first');
      setStatus('error');
      return;
    }

    setLoading(true);
    setStatus('verifying');
    setMessage('🔄 Verifying payment with backend...');

    try {
      const response = await fetch(`${API_BASE_URL}/verify`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          orderId: orderId.trim(),
          paymentId: paymentId.trim(),
          signature: signature,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        setMessage(`❌ Payment verification failed: ${data.message}`);
        setStatus('error');
        return;
      }

      setMessage(
        `✅ Payment verified successfully!\n\n` +
        `Order ID: ${orderId}\n` +
        `Payment ID: ${paymentId}\n\n` +
        `✅ Email confirmation sent\n` +
        `✅ Cart cleared\n` +
        `✅ Order status updated`
      );
      setStatus('success');

      // Clear form after successful verification
      setTimeout(() => {
        setOrderId('');
        setPaymentId('');
        setSignature('');
      }, 2000);
    } catch (error) {
      setMessage(`❌ Error verifying payment: ${error.message}`);
      setStatus('error');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setOrderId('');
    setPaymentId('');
    setSignature('');
    setMessage('');
    setStatus('');
  };

  return (
    <div className="payment-form-container">
      <div className="payment-form-card">
        <h1>💳 Payment Verification</h1>
        <p className="subtitle">Secure payment verification with Razorpay</p>

        <div className="form-group">
          <label htmlFor="orderId">Order ID *</label>
          <input
            id="orderId"
            type="text"
            value={orderId}
            onChange={(e) => setOrderId(e.target.value)}
            placeholder="e.g., order_123456789"
            disabled={loading}
          />
        </div>

        <div className="form-group">
          <label htmlFor="paymentId">Payment ID *</label>
          <input
            id="paymentId"
            type="text"
            value={paymentId}
            onChange={(e) => setPaymentId(e.target.value)}
            placeholder="e.g., pay_987654321"
            disabled={loading}
          />
        </div>

        {signature && (
          <div className="form-group">
            <label>Generated Signature</label>
            <div className="signature-display">
              <code>{signature}</code>
              <button
                className="copy-button"
                onClick={() => {
                  navigator.clipboard.writeText(signature);
                  alert('Signature copied to clipboard!');
                }}
              >
                📋 Copy
              </button>
            </div>
          </div>
        )}

        <div className="button-group">
          <button
            onClick={handleGenerateSignature}
            disabled={loading || !orderId.trim() || !paymentId.trim()}
            className="btn btn-primary"
          >
            {loading && status === 'generating' ? '⏳ Generating...' : '🔐 Generate Signature'}
          </button>

          <button
            onClick={handleVerifyPayment}
            disabled={loading || !signature}
            className="btn btn-success"
          >
            {loading && status === 'verifying' ? '⏳ Verifying...' : '✅ Verify Payment'}
          </button>

          <button
            onClick={handleReset}
            disabled={loading}
            className="btn btn-secondary"
          >
            🔄 Reset
          </button>
        </div>

        {message && (
          <div className={`message ${status}`}>
            <pre>{message}</pre>
          </div>
        )}

        <div className="info-box">
          <h3>📋 How it works:</h3>
          <ol>
            <li>Enter your Order ID and Payment ID</li>
            <li>Click "Generate Signature" to create HMAC-SHA256 signature</li>
            <li>Click "Verify Payment" to verify the signature with backend</li>
            <li>Backend will send order confirmation email and clear cart</li>
          </ol>
        </div>

        <div className="security-notice">
          <p>🔒 <strong>Security Notice:</strong> Signatures are generated on the backend and verified server-to-server. Keys never leave the server.</p>
        </div>
      </div>
    </div>
  );
}
