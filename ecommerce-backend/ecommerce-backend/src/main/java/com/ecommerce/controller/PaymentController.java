package com.ecommerce.controller;

import com.ecommerce.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/payments")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000"})
public class PaymentController {
    
    @Autowired
    private PaymentService paymentService;
    
    /**
     * Create Razorpay Order for payment
     * URL: POST /api/payments/razorpay/create-order
     * Body: {
     *   "orderId": 1,
     *   "userId": 1
     * }
     */
    @PostMapping("/razorpay/create-order")
    public ResponseEntity<?> createRazorpayOrder(
            @RequestBody Map<String, Object> request,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            if (request.get("orderId") == null || request.get("userId") == null) {
                return ResponseEntity.badRequest()
                        .body(new HashMap<String, String>() {{
                            put("error", "Missing required fields: orderId and userId");
                        }});
            }
            
            Long orderId = Long.parseLong(request.get("orderId").toString());
            Long userId = Long.parseLong(request.get("userId").toString());
            
            Map<String, Object> response = paymentService.createRazorpayOrder(orderId, userId);
            return ResponseEntity.ok(response);
        } catch (NumberFormatException e) {
            return ResponseEntity.badRequest()
                    .body(new HashMap<String, String>() {{
                        put("error", "Invalid orderId or userId format: " + e.getMessage());
                    }});
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new HashMap<String, String>() {{
                        put("error", "Failed to create Razorpay order: " + e.getMessage());
                    }});
        }
    }
    
    /**
     * Verify Razorpay Payment
     * URL: POST /api/payments/razorpay/verify
     * Body: {
     *   "razorpayOrderId": "order_xxxxx",
     *   "razorpayPaymentId": "pay_xxxxx",
     *   "razorpaySignature": "signature_xxxxx"
     * }
     */
    @PostMapping("/razorpay/verify")
    public ResponseEntity<?> verifyRazorpayPayment(
            @RequestBody Map<String, String> request) {
        try {
            String razorpayOrderId = request.get("razorpayOrderId");
            String razorpayPaymentId = request.get("razorpayPaymentId");
            String razorpaySignature = request.get("razorpaySignature");
            
            if (razorpayOrderId == null || razorpayPaymentId == null || razorpaySignature == null) {
                return ResponseEntity.badRequest()
                        .body(new HashMap<String, String>() {{
                            put("error", "Missing required fields: razorpayOrderId, razorpayPaymentId, razorpaySignature");
                        }});
            }
            
            Map<String, Object> response = paymentService.verifyPayment(razorpayOrderId, razorpayPaymentId, razorpaySignature);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new HashMap<String, String>() {{
                        put("error", e.getMessage());
                    }});
        }
    }
    
    /**
     * Get payment status for an order
     * URL: GET /api/payments/order/{orderId}
     */
    @GetMapping("/order/{orderId}")
    public ResponseEntity<?> getPaymentByOrder(
            @PathVariable Long orderId) {
        try {
            var payment = paymentService.getPaymentByOrder(orderId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("id", payment.getId());
            response.put("status", payment.getStatus());
            response.put("amount", payment.getAmount());
            response.put("currency", payment.getCurrency());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new HashMap<String, String>() {{
                        put("error", e.getMessage());
                    }});
        }
    }
}
