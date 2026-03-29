package com.ecommerce.service;

import com.ecommerce.model.Payment;
import com.ecommerce.model.Order;
import com.ecommerce.repository.PaymentRepository;
import com.ecommerce.repository.OrderRepository;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.logging.Logger;

@Service
@Transactional
public class PaymentService {
    
    private static final Logger logger = Logger.getLogger(PaymentService.class.getName());
    
    @Autowired
    private PaymentRepository paymentRepository;
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired(required = false)
    private EmailService emailService;
    
    @Value("${razorpay.api.key:}")
    private String razorpayKeyId;
    
    @Value("${razorpay.api.secret:}")
    private String razorpayKeySecret;
    
    private RazorpayClient razorpayClient;
    
    @jakarta.annotation.PostConstruct
    public void initializeRazorpay() {
        try {
            if (razorpayKeyId != null && !razorpayKeyId.isEmpty() && 
                razorpayKeySecret != null && !razorpayKeySecret.isEmpty()) {
                razorpayClient = new RazorpayClient(razorpayKeyId, razorpayKeySecret);
                logger.info("✅ Razorpay client initialized with real API credentials");
            } else {
                logger.warning("⚠️ Razorpay credentials not configured. Using mock orders.");
            }
        } catch (RazorpayException e) {
            logger.severe("Failed to initialize Razorpay: " + e.getMessage());
        }
    }
    
    /**
     * Get payment status for an order
     */
    public Payment getPaymentByOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        return paymentRepository.findByOrder(order)
                .orElse(null);
    }
    
    /**
     * Create a payment record for an order
     */
    public Payment createPaymentRecord(Long orderId, String razorpayOrderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        
        Payment payment = new Payment();
        payment.setOrder(order);
        payment.setUser(order.getUser());
        payment.setStripePaymentIntentId(razorpayOrderId); // Store Razorpay order ID
        payment.setAmount(order.getTotalPrice());
        payment.setCurrency("INR");
        payment.setStatus(Payment.PaymentStatus.PENDING);
        
        return paymentRepository.save(payment);
    }
    
    /**
     * Update payment status to succeeded after successful verification
     */
    public void markPaymentSucceeded(String razorpayOrderId, String razorpayPaymentId) {
        Optional<Payment> paymentOpt = paymentRepository.findByStripePaymentIntentId(razorpayOrderId);
        
        if (paymentOpt.isPresent()) {
            Payment payment = paymentOpt.get();
            payment.setStatus(Payment.PaymentStatus.SUCCEEDED);
            payment.setStripeClientSecret(razorpayPaymentId); // Store actual payment ID
            paymentRepository.save(payment);
            
            // Update order status to confirmed
            Order order = payment.getOrder();
            order.setStatus(Order.OrderStatus.CONFIRMED);
            orderRepository.save(order);
            
            logger.info("Payment marked as succeeded for order: " + order.getId());
            
            // Send order confirmation email
            if (emailService != null) {
                try {
                    emailService.sendOrderConfirmationEmail(
                        order.getUser().getEmail(),
                        order.getId(),
                        razorpayPaymentId,
                        order.getTotalPrice().toString()
                    );
                    logger.info("✅ Order confirmation email sent to: " + order.getUser().getEmail());
                } catch (Exception e) {
                    logger.warning("Failed to send confirmation email: " + e.getMessage());
                }
            }
        }
    }
    
    /**
     * Update payment status to failed
     */
    public void markPaymentFailed(String razorpayOrderId, String reason) {
        Optional<Payment> paymentOpt = paymentRepository.findByStripePaymentIntentId(razorpayOrderId);
        
        if (paymentOpt.isPresent()) {
            Payment payment = paymentOpt.get();
            payment.setStatus(Payment.PaymentStatus.FAILED);
            paymentRepository.save(payment);
            
            logger.warning("Payment marked as failed for order: " + payment.getOrder().getId() + 
                          ". Reason: " + reason);
        }
    }
    
    /**
     * Create Razorpay Order using real Razorpay API or mock for testing
     */
    public Map<String, Object> createRazorpayOrder(Long orderId, Long userId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found with ID: " + orderId));
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Create order with real Razorpay API if credentials are available
            if (razorpayClient != null) {
                JSONObject orderRequest = new JSONObject();
                long amountInPaise = order.getTotalPrice().multiply(BigDecimal.valueOf(100)).longValue();
                orderRequest.put("amount", amountInPaise); // Amount in paise
                orderRequest.put("currency", "INR");
                orderRequest.put("receipt", "order_" + orderId + "_" + System.currentTimeMillis());
                
                com.razorpay.Order razorpayOrder = razorpayClient.orders.create(orderRequest);
                String razorpayOrderId = razorpayOrder.get("id");
                
                // Create payment record in database
                Payment payment = new Payment();
                payment.setOrder(order);
                payment.setUser(order.getUser());
                payment.setStripePaymentIntentId(razorpayOrderId); // Store real Razorpay order ID
                payment.setAmount(order.getTotalPrice());
                payment.setCurrency("INR");
                payment.setStatus(Payment.PaymentStatus.PENDING);
                
                Payment savedPayment = paymentRepository.save(payment);
                
                response.put("orderId", razorpayOrderId);
                response.put("amount", order.getTotalPrice());
                response.put("amountInPaise", amountInPaise);
                response.put("currency", "INR");
                response.put("keyId", razorpayKeyId);
                response.put("userEmail", order.getUser().getEmail());
                response.put("userName", order.getUser().getFirstName() + " " + order.getUser().getLastName());
                response.put("message", "✅ Real Razorpay order created successfully");
                
                logger.info("✅ Razorpay order created: " + razorpayOrderId + " for order: " + orderId);
            } else {
                // Create mock Razorpay order for testing/development
                String mockOrderId = "order_" + orderId + "_mock_" + System.currentTimeMillis();
                long amountInPaise = order.getTotalPrice().multiply(BigDecimal.valueOf(100)).longValue();
                
                // Create payment record in database
                Payment payment = new Payment();
                payment.setOrder(order);
                payment.setUser(order.getUser());
                payment.setStripePaymentIntentId(mockOrderId);
                payment.setAmount(order.getTotalPrice());
                payment.setCurrency("INR");
                payment.setStatus(Payment.PaymentStatus.PENDING);
                
                Payment savedPayment = paymentRepository.save(payment);
                
                response.put("orderId", mockOrderId);
                response.put("amount", order.getTotalPrice());
                response.put("amountInPaise", amountInPaise);
                response.put("currency", "INR");
                response.put("keyId", "pk_test_mock_key_for_development");
                response.put("userEmail", order.getUser().getEmail());
                response.put("userName", order.getUser().getFirstName() + " " + order.getUser().getLastName());
                response.put("message", "✅ Mock Razorpay order created (development mode)");
                response.put("isMockMode", true);
                
                logger.info("✅ Mock Razorpay order created: " + mockOrderId + " for order: " + orderId);
            }
        } catch (RazorpayException e) {
            logger.severe("❌ Razorpay API error: " + e.getMessage());
            throw new RuntimeException("Failed to create Razorpay order: " + e.getMessage());
        } catch (Exception e) {
            logger.severe("❌ Error creating payment: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error creating payment order: " + e.getMessage());
        }
        
        return response;
    }
    
    /**
     * Verify Payment with Razorpay
     */
    public Map<String, Object> verifyPayment(String razorpayOrderId, String razorpayPaymentId, String signature) {
        Optional<Payment> paymentOpt = paymentRepository.findByStripePaymentIntentId(razorpayOrderId);
        
        if (!paymentOpt.isPresent()) {
            throw new RuntimeException("Payment not found for order: " + razorpayOrderId);
        }
        
        try {
            // Check if this is mock mode payment (development)
            if (razorpayOrderId.contains("mock")) {
                logger.info("✅ Mock payment verified (development mode) for order: " + razorpayOrderId);
            } else if (razorpayClient != null) {
                // Verify signature with real Razorpay data
                String generatedSignature = generateSignature(razorpayOrderId, razorpayPaymentId);
                
                if (!generatedSignature.equals(signature)) {
                    throw new RuntimeException("❌ Signature verification failed - FRAUD DETECTED!");
                }
                
                logger.info("✅ Razorpay signature verified successfully for order: " + razorpayOrderId);
            }
            
            // Mark payment as succeeded
            markPaymentSucceeded(razorpayOrderId, razorpayPaymentId);
            
            Payment payment = paymentOpt.get();
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "✅ Payment verified successfully");
            response.put("paymentStatus", Payment.PaymentStatus.SUCCEEDED);
            response.put("orderId", payment.getOrder().getId());
            
            return response;
        } catch (Exception e) {
            logger.severe("❌ Payment verification error: " + e.getMessage());
            throw new RuntimeException("Payment verification failed: " + e.getMessage());
        }
    }
    
    /**
     * Generate Razorpay signature (HMAC-SHA256)
     */
    private String generateSignature(String orderId, String paymentId) {
        try {
            String payload = orderId + "|" + paymentId;
            javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA256");
            javax.crypto.spec.SecretKeySpec keySpec = new javax.crypto.spec.SecretKeySpec(
                razorpayKeySecret.getBytes(),
                "HmacSHA256"
            );
            mac.init(keySpec);
            byte[] hash = mac.doFinal(payload.getBytes());
            
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException("Signature generation failed: " + e.getMessage());
        }
    }
    
    /**
     * Get payment by Order ID (as stored in database)
     */
    public Optional<Payment> getPaymentByOrderId(String orderId) {
        return paymentRepository.findByStripePaymentIntentId(orderId);
    }
}

