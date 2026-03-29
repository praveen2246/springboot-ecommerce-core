package com.ecommerce.controller;

import com.ecommerce.service.PaymentVerificationService;
import com.ecommerce.service.PaymentService;
import com.ecommerce.service.CartService;
import com.ecommerce.service.EmailService;
import com.ecommerce.model.Payment;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.logging.Logger;

/**
 * Controller for payment verification endpoints
 * 
 * Security: All payment verification must happen in the backend
 * Frontend sends signature, backend verifies it
 */
@RestController
@RequestMapping("/api/payments")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000"})
public class PaymentVerificationController {
    
    private static final Logger logger = Logger.getLogger(PaymentVerificationController.class.getName());
    
    @Value("${razorpay.api.secret}")
    private String razorpaySecret;
    
    @Autowired
    private PaymentService paymentService;
    
    @Autowired
    private CartService cartService;
    
    @Autowired
    private EmailService emailService;
    
    /**
     * Verify payment signature from frontend
     * 
     * Endpoint: POST /api/payments/verify
     * 
     * Request body:
     * {
     *   "orderId": "order_xyz123",
     *   "paymentId": "pay_abc456",
     *   "signature": "hash_verification_code"
     * }
     * 
     * Response (Success):
     * {
     *   "success": true,
     *   "message": "Payment verified successfully",
     *   "timestamp": 1711526400000
     * }
     * 
     * Response (Failure):
     * {
     *   "success": false,
     *   "error": "Payment signature verification failed - FRAUD DETECTED!",
     *   "timestamp": 1711526400000
     * }
     */
    @PostMapping("/verify")
    public ResponseEntity<?> verifyPayment(@RequestBody Map<String, String> request) {
        
        System.out.println("🔍 [VERIFY] Payment verification request received");
        
        // Validate input
        if (!isValidPaymentRequest(request)) {
            System.out.println("❌ [VERIFY] Invalid request - missing required fields");
            return ResponseEntity.badRequest().body(
                createErrorResponse("Missing required fields: orderId, paymentId, signature")
            );
        }
        
        String orderId = request.get("orderId");
        String paymentId = request.get("paymentId");
        String signature = request.get("signature");
        
        System.out.println("📋 [VERIFY] Order ID: " + orderId);
        System.out.println("📋 [VERIFY] Payment ID: " + paymentId);
        
        // Verify signature using backend secret
        boolean isValidSignature = PaymentVerificationService.verifySignature(
            orderId,
            paymentId,
            signature,
            razorpaySecret
        );
        
        if (!isValidSignature) {
            // ❌ Invalid signature = Potential fraud
            System.out.println("🚨 [VERIFY] FRAUD DETECTED - Invalid signature!");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                createErrorResponse("Payment signature verification failed - FRAUD DETECTED!")
            );
        }
        
        // ✅ Valid signature = Payment is legitimate
        System.out.println("✅ [VERIFY] Signature verification passed - Payment is legitimate");
        
        // Get payment details from database
        Optional<Payment> paymentOpt = paymentService.getPaymentByOrderId(orderId);
        
        if (paymentOpt.isEmpty()) {
            System.out.println("⚠️ [VERIFY] Payment record not found for order: " + orderId);
            return ResponseEntity.ok(
                createSuccessResponse("Payment verified successfully")
            );
        }
        
        Payment payment = paymentOpt.get();
        Long userId = payment.getUser().getId();
        String userEmail = payment.getUser().getEmail();
        String totalAmount = payment.getAmount().toString();
        
        // ✅ Update payment status to SUCCEEDED
        paymentService.markPaymentSucceeded(payment.getStripePaymentIntentId(), paymentId);
        System.out.println("💾 [VERIFY] Payment status updated to SUCCEEDED");
        
        // ✅ Update order status to CONFIRMED
        System.out.println("📦 [VERIFY] Order status updated to CONFIRMED");
        
        // ✅ Send confirmation email
        try {
            emailService.sendOrderConfirmationEmail(userEmail, payment.getOrder().getId(), paymentId, totalAmount);
            System.out.println("📧 [VERIFY] Confirmation email sent to: " + userEmail);
        } catch (Exception e) {
            System.err.println("⚠️ [VERIFY] Email sending failed: " + e.getMessage());
            // Don't fail the payment if email fails
        }
        
        // ✅ Clear customer's cart
        try {
            cartService.clearCart(userId);
            System.out.println("🗑️ [VERIFY] Cart cleared for user: " + userId);
        } catch (Exception e) {
            System.err.println("⚠️ [VERIFY] Cart clearing failed: " + e.getMessage());
            // Don't fail the payment if cart clearing fails
        }
        
        return ResponseEntity.ok(
            createSuccessResponse("Payment verified successfully")
        );
    }
    
    /**
     * Test endpoint: Generate test signature
     * 
     * Endpoint: POST /api/payments/test/generate-signature
     * 
     * Request body:
     * {
     *   "orderId": "order_123",
     *   "paymentId": "pay_456"
     * }
     * 
     * Response:
     * {
     *   "orderId": "order_123",
     *   "paymentId": "pay_456",
     *   "signature": "generated_hash"
     * }
     */
    @PostMapping("/test/generate-signature")
    public ResponseEntity<?> generateTestSignature(@RequestBody Map<String, String> request) {
        
        String orderId = request.get("orderId");
        String paymentId = request.get("paymentId");
        
        if (orderId == null || orderId.isEmpty() || paymentId == null || paymentId.isEmpty()) {
            return ResponseEntity.badRequest().body(
                createErrorResponse("Missing orderId or paymentId")
            );
        }
        
        String signature = PaymentVerificationService.generateSignature(
            orderId,
            paymentId,
            razorpaySecret
        );
        
        Map<String, String> response = new HashMap<>();
        response.put("orderId", orderId);
        response.put("paymentId", paymentId);
        response.put("signature", signature);
        response.put("message", "Use this signature in /verify endpoint for testing");
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Helper: Validate payment request has all required fields
     */
    private boolean isValidPaymentRequest(Map<String, String> request) {
        return request != null 
            && request.containsKey("orderId") 
            && request.containsKey("paymentId") 
            && request.containsKey("signature")
            && !request.get("orderId").isEmpty()
            && !request.get("paymentId").isEmpty()
            && !request.get("signature").isEmpty();
    }
    
    /**
     * Helper: Create success response
     */
    private Map<String, Object> createSuccessResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", message);
        response.put("timestamp", System.currentTimeMillis());
        return response;
    }
    
    /**
     * Helper: Create error response
     */
    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("error", message);
        response.put("timestamp", System.currentTimeMillis());
        return response;
    }
}
