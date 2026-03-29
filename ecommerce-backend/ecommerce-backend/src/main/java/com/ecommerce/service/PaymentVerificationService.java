package com.ecommerce.service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.HexFormat;

/**
 * Service for verifying Razorpay payment signatures
 * 
 * Security: This service implements HMAC SHA256 signature verification
 * to ensure payment data hasn't been tampered with
 */
public class PaymentVerificationService {
    
    /**
     * Verify Razorpay signature using HMAC SHA256
     * 
     * Formula: SHA256(orderId|paymentId, apiSecret)
     * 
     * @param orderId Razorpay order ID
     * @param paymentId Razorpay payment ID
     * @param receivedSignature Signature received from frontend
     * @param apiSecret Your Razorpay API secret
     * @return true if signature is valid, false otherwise
     * 
     * Example:
     * boolean isValid = PaymentVerificationService.verifySignature(
     *     "order_123",
     *     "pay_456",
     *     "signature_hash",
     *     "your_api_secret"
     * );
     */
    public static boolean verifySignature(
            String orderId, 
            String paymentId, 
            String receivedSignature, 
            String apiSecret) {
        
        try {
            // Validate inputs
            if (orderId == null || orderId.isEmpty() ||
                paymentId == null || paymentId.isEmpty() ||
                receivedSignature == null || receivedSignature.isEmpty() ||
                apiSecret == null || apiSecret.isEmpty()) {
                
                System.err.println("❌ Invalid input parameters for signature verification");
                return false;
            }
            
            // Step 1: Create the payload string (orderId|paymentId)
            String payload = orderId + "|" + paymentId;
            System.out.println("[VERIFICATION] Payload: " + payload);
            
            // Step 2: Create HMAC SHA256 hash generator
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKey = new SecretKeySpec(
                apiSecret.getBytes(StandardCharsets.UTF_8),
                0,
                apiSecret.getBytes(StandardCharsets.UTF_8).length,
                "HmacSHA256"
            );
            mac.init(secretKey);
            
            // Step 3: Generate hash from payload
            byte[] hash = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
            
            // Step 4: Convert to hexadecimal string
            String computedSignature = HexFormat.of().formatHex(hash);
            
            // Step 5: Compare with received signature (case-insensitive)
            boolean isValid = computedSignature.equalsIgnoreCase(receivedSignature);
            
            // Log verification result
            if (isValid) {
                System.out.println("✅ [VERIFICATION] Signature is VALID");
            } else {
                System.out.println("❌ [VERIFICATION] Signature is INVALID");
                System.out.println("   Computed: " + computedSignature);
                System.out.println("   Received: " + receivedSignature);
            }
            
            return isValid;
            
        } catch (Exception e) {
            System.err.println("❌ Signature verification error: " + e.getMessage());
            e.printStackTrace();
            return false; // If error occurs, treat as invalid for security
        }
    }
    
    /**
     * Helper method: Generate signature for testing purposes
     * 
     * @param orderId Order ID
     * @param paymentId Payment ID
     * @param apiSecret API secret
     * @return Generated signature
     */
    public static String generateSignature(
            String orderId,
            String paymentId,
            String apiSecret) {
        
        try {
            String payload = orderId + "|" + paymentId;
            
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKey = new SecretKeySpec(
                apiSecret.getBytes(StandardCharsets.UTF_8),
                "HmacSHA256"
            );
            mac.init(secretKey);
            
            byte[] hash = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
            
        } catch (Exception e) {
            System.err.println("❌ Error generating signature: " + e.getMessage());
            return null;
        }
    }
}
