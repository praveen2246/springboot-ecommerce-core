package com.ecommerce.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import java.util.logging.Logger;

@Service
public class EmailService {
    
    private static final Logger logger = Logger.getLogger(EmailService.class.getName());
    
    @Autowired(required = false)
    private JavaMailSender javaMailSender;
    
    @Value("${spring.mail.from:noreply@ecommerce.com}")
    private String fromEmail;
    
    /**
     * Send order confirmation email after successful payment verification
     * 
     * @param toEmail Customer email address
     * @param orderId Order ID
     * @param paymentId Payment ID
     * @param totalAmount Order total amount
     */
    public void sendOrderConfirmationEmail(String toEmail, Long orderId, String paymentId, String totalAmount) {
        try {
            if (javaMailSender == null) {
                logger.warning("Mail service not configured! Email not sent to: " + toEmail);
                return;
            }
            
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(toEmail);
            message.setSubject("✅ Order Confirmation - Order #" + orderId);
            
            String emailBody = String.format(
                "Dear Customer,\n\n" +
                "Thank you for your order! Your payment has been verified successfully.\n\n" +
                "ORDER DETAILS:\n" +
                "─────────────────────\n" +
                "Order ID: %d\n" +
                "Payment ID: %s\n" +
                "Total Amount: $%s\n" +
                "Status: ✅ CONFIRMED\n" +
                "─────────────────────\n\n" +
                "Your order will be processed and shipped soon.\n" +
                "You will receive tracking information via email.\n\n" +
                "Questions? Contact our support team.\n\n" +
                "Best regards,\n" +
                "E-Commerce Team",
                orderId, paymentId, totalAmount
            );
            
            message.setText(emailBody);
            javaMailSender.send(message);
            
            logger.info("Order confirmation email sent successfully to: " + toEmail);
            
        } catch (Exception e) {
            logger.severe("Failed to send order confirmation email to " + toEmail + ": " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Send order failure notification email (when payment is rejected)
     * 
     * @param toEmail Customer email address
     * @param orderId Order ID
     * @param reason Reason for failure
     */
    public void sendPaymentFailureEmail(String toEmail, Long orderId, String reason) {
        try {
            if (javaMailSender == null) {
                logger.warning("Mail service not configured! Email not sent to: " + toEmail);
                return;
            }
            
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(toEmail);
            message.setSubject("❌ Payment Failed - Order #" + orderId);
            
            String emailBody = String.format(
                "Dear Customer,\n\n" +
                "Unfortunately, your payment verification failed.\n\n" +
                "ORDER DETAILS:\n" +
                "─────────────────────\n" +
                "Order ID: %d\n" +
                "Status: ❌ PAYMENT FAILED\n" +
                "Reason: %s\n" +
                "─────────────────────\n\n" +
                "Please try again or use a different payment method.\n" +
                "Your order has not been confirmed.\n\n" +
                "If you believe this is an error, please contact our support team.\n\n" +
                "Best regards,\n" +
                "E-Commerce Team",
                orderId, reason
            );
            
            message.setText(emailBody);
            javaMailSender.send(message);
            
            logger.info("Payment failure email sent to: " + toEmail);
            
        } catch (Exception e) {
            logger.severe("Failed to send payment failure email to " + toEmail + ": " + e.getMessage());
        }
    }
}
