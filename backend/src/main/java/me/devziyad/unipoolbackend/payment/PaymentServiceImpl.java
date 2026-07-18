package me.devziyad.unipoolbackend.payment;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.audit.ActionType;
import me.devziyad.unipoolbackend.audit.AuditService;
import me.devziyad.unipoolbackend.booking.Booking;
import me.devziyad.unipoolbackend.booking.BookingRepository;
import me.devziyad.unipoolbackend.common.PaymentMethod;
import me.devziyad.unipoolbackend.common.PaymentStatus;
import me.devziyad.unipoolbackend.exception.BusinessException;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.notification.NotificationService;
import me.devziyad.unipoolbackend.payment.dto.*;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PaymentServiceImpl implements PaymentService {

    private final PaymentRepository paymentRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final AuditService auditService;

    @Value("${payment.platform-fee-percentage:10}")
    private double platformFeePercentage;

    private HttpServletRequest getCurrentRequest() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        return attributes != null ? attributes.getRequest() : null;
    }

    private PaymentResponse toResponse(Payment payment) {
        return PaymentResponse.builder()
                .id(payment.getId())
                .bookingId(payment.getBooking().getId())
                .payerId(payment.getPayer().getId())
                .payerName(payment.getPayer().getFullName())
                .driverId(payment.getDriver() != null ? payment.getDriver().getId() : null)
                .driverName(payment.getDriver() != null ? payment.getDriver().getFullName() : null)
                .amount(payment.getAmount())
                .platformFee(payment.getPlatformFee())
                .driverEarnings(payment.getDriverEarnings())
                .method(payment.getMethod())
                .status(payment.getStatus())
                .transactionRef(payment.getTransactionRef())
                .createdAt(payment.getCreatedAt())
                .updatedAt(payment.getUpdatedAt())
                .build();
    }

    @Override
    @Transactional
    public PaymentResponse initiatePayment(InitiatePaymentRequest request, Long payerId) {
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));

        if (!booking.getRider().getId().equals(payerId)) {
            throw new ForbiddenException("You can only pay for your own bookings");
        }

        if (booking.getStatus() == me.devziyad.unipoolbackend.common.BookingStatus.CANCELLED) {
            throw new BusinessException("Cannot pay for cancelled booking");
        }

        // Check if payment already exists
        paymentRepository.findByBookingId(request.getBookingId())
                .stream()
                .filter(p -> p.getStatus() == PaymentStatus.SETTLED)
                .findFirst()
                .ifPresent(p -> {
                    throw new BusinessException("Payment already completed for this booking");
                });

        User payer = userRepository.findById(payerId)
                .orElseThrow(() -> new ResourceNotFoundException("Payer not found"));

        User driver = booking.getRide().getDriver();

        BigDecimal amount = booking.getCostForThisRider();
        BigDecimal platformFee = amount.multiply(BigDecimal.valueOf(platformFeePercentage / 100.0))
                .setScale(2, RoundingMode.HALF_UP);
        BigDecimal driverEarnings = amount.subtract(platformFee);

        // Handle wallet payment
        if (request.getMethod() == PaymentMethod.WALLET) {
            if (payer.getWalletBalance().compareTo(amount) < 0) {
                throw new BusinessException("Insufficient wallet balance");
            }
            payer.setWalletBalance(payer.getWalletBalance().subtract(amount));
            userRepository.save(payer);
        }

        Payment payment = Payment.builder()
                .booking(booking)
                .payer(payer)
                .driver(driver)
                .amount(amount)
                .platformFee(platformFee)
                .driverEarnings(driverEarnings)
                .method(request.getMethod())
                .status(PaymentStatus.INITIATED)
                .transactionRef("TXN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase())
                .build();

        payment = paymentRepository.save(payment);

        // Audit log
        java.util.Map<String, Object> metadata = new java.util.HashMap<>();
        metadata.put("paymentId", payment.getId());
        metadata.put("bookingId", booking.getId());
        metadata.put("amount", amount.toString());
        metadata.put("method", request.getMethod().name());
        auditService.logAction(ActionType.PAYMENT_INITIATE, payerId, metadata, getCurrentRequest());

        // Simulate async payment processing
        if (request.getMethod() != PaymentMethod.CASH) {
            processPaymentAsync(payment.getId());
        } else {
            // Cash payments are marked as settled immediately
            payment.setStatus(PaymentStatus.SETTLED);
            payment.setUpdatedAt(Instant.now());
            payment = paymentRepository.save(payment);

            // Audit log payment completion
            metadata.put("status", PaymentStatus.SETTLED.name());
            auditService.logAction(ActionType.PAYMENT_COMPLETE, payerId, metadata, getCurrentRequest());

            // Update driver wallet
            driver.setWalletBalance(driver.getWalletBalance().add(driverEarnings));
            userRepository.save(driver);

            // Create notification
            notificationService.createNotification(
                    driver.getId(),
                    "Payment Received",
                    String.format("You received %s from %s", amount, payer.getFullName()),
                    me.devziyad.unipoolbackend.common.NotificationType.PAYMENT_RECEIVED
            );
        }

        return toResponse(payment);
    }

    @Async
    protected CompletableFuture<Void> processPaymentAsync(Long paymentId) {
        try {
            Thread.sleep(2000); // Simulate 2 second processing delay
            processPayment(paymentId);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        return CompletableFuture.completedFuture(null);
    }

    @Override
    @Transactional
    public PaymentResponse processPayment(Long paymentId) {
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found"));

        if (payment.getStatus() != PaymentStatus.INITIATED) {
            throw new BusinessException("Payment is not in INITIATED status");
        }

        payment.setStatus(PaymentStatus.PROCESSING);
        payment.setUpdatedAt(Instant.now());
        payment = paymentRepository.save(payment);

        // Simulate processing delay
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        // Settle payment
        payment.setStatus(PaymentStatus.SETTLED);
        payment.setUpdatedAt(Instant.now());
        payment = paymentRepository.save(payment);

        // Update driver wallet
        User driver = payment.getDriver();
        driver.setWalletBalance(driver.getWalletBalance().add(payment.getDriverEarnings()));
        userRepository.save(driver);

        // Audit log payment completion
        java.util.Map<String, Object> metadata = new java.util.HashMap<>();
        metadata.put("paymentId", payment.getId());
        metadata.put("bookingId", payment.getBooking().getId());
        metadata.put("status", PaymentStatus.SETTLED.name());
        auditService.logAction(ActionType.PAYMENT_COMPLETE, payment.getPayer().getId(), metadata, getCurrentRequest());

        // Create notification
        notificationService.createNotification(
                driver.getId(),
                "Payment Received",
                String.format("You received %s from %s", payment.getAmount(), payment.getPayer().getFullName()),
                me.devziyad.unipoolbackend.common.NotificationType.PAYMENT_RECEIVED
        );

        return toResponse(payment);
    }

    @Override
    @Transactional
    public PaymentResponse refundPayment(Long paymentId, Long userId) {
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found"));

        if (!payment.getPayer().getId().equals(userId) && 
            !payment.getDriver().getId().equals(userId)) {
            throw new ForbiddenException("You can only refund your own payments or payments on your rides");
        }

        if (payment.getStatus() != PaymentStatus.SETTLED) {
            throw new BusinessException("Can only refund settled payments");
        }

        payment.setStatus(PaymentStatus.REFUNDED);
        payment.setUpdatedAt(Instant.now());
        payment = paymentRepository.save(payment);

        // Refund to payer
        User payer = payment.getPayer();
        if (payment.getMethod() == PaymentMethod.WALLET) {
            payer.setWalletBalance(payer.getWalletBalance().add(payment.getAmount()));
        }
        userRepository.save(payer);

        // Deduct from driver
        User driver = payment.getDriver();
        driver.setWalletBalance(driver.getWalletBalance().subtract(payment.getDriverEarnings()));
        userRepository.save(driver);

        return toResponse(payment);
    }

    @Override
    public PaymentResponse getPaymentById(Long id) {
        Payment payment = paymentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found"));
        return toResponse(payment);
    }

    @Override
    public List<PaymentResponse> getPaymentsForUser(Long userId) {
        return paymentRepository.findByPayerId(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PaymentResponse> getPaymentsForBooking(Long bookingId) {
        return paymentRepository.findByBookingId(bookingId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<PaymentResponse> getPaymentsForDriver(Long driverId) {
        return paymentRepository.findByDriverId(driverId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public BigDecimal getWalletBalance(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return user.getWalletBalance();
    }

    @Override
    @Transactional
    public PaymentResponse topUpWallet(WalletTopUpRequest request, Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        user.setWalletBalance(user.getWalletBalance().add(request.getAmount()));
        userRepository.save(user);

        // Wallet top-up doesn't create a payment record
        // Return a simple response
        PaymentResponse response = PaymentResponse.builder()
                .payerId(userId)
                .payerName(user.getFullName())
                .amount(request.getAmount())
                .platformFee(BigDecimal.ZERO)
                .driverEarnings(BigDecimal.ZERO)
                .method(PaymentMethod.WALLET)
                .status(PaymentStatus.SETTLED)
                .transactionRef("TOPUP-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase())
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();
        return response;
    }
}
