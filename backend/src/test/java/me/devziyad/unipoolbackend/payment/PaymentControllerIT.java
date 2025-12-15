package me.devziyad.unipoolbackend.payment;

import me.devziyad.unipoolbackend.common.PaymentMethod;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.payment.dto.InitiatePaymentRequest;
import me.devziyad.unipoolbackend.payment.dto.WalletTopUpRequest;
import me.devziyad.unipoolbackend.user.UserRepository;
import me.devziyad.unipoolbackend.util.TestUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

import java.math.BigDecimal;

@AutoConfigureRestTestClient
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@org.springframework.test.context.ActiveProfiles("test")
public class PaymentControllerIT {

    @Autowired
    private RestTestClient restClient;

    @Autowired
    private UserRepository userRepository;

    private String userToken;
    private String driverToken;
    private Long rideId;
    private Long bookingId;
    private Long paymentId;

    @BeforeEach
    void setUp() {
        // Create regular user
        TestUtils.RegistrationResult userResult = TestUtils.registerAndGetResult(
                restClient,
                "user@example.com",
                "user123",
                "User",
                Role.RIDER
        );
        userToken = userResult.getToken();
        
        // Verify the user's university ID so they can book rides
        TestUtils.verifyUniversityIdByEmailDirectly(userRepository, userResult.getEmail());

        // Create driver user
        TestUtils.RegistrationResult driverResult = TestUtils.registerAndGetResult(
                restClient,
                "driver@example.com",
                "driver123",
                "Driver",
                Role.DRIVER
        );
        driverToken = driverResult.getToken();
        
        // Verify the driver so they can create rides
        TestUtils.verifyDriverByEmailDirectly(userRepository, driverResult.getEmail());
        
        // Create vehicle, locations, and ride for payment tests
        me.devziyad.unipoolbackend.vehicle.dto.VehicleResponse vehicle = TestUtils.createVehicle(restClient, driverToken);
        me.devziyad.unipoolbackend.location.dto.LocationResponse pickupLocation = TestUtils.createLocation(restClient, driverToken, "Pickup", 40.7128, -74.0060);
        me.devziyad.unipoolbackend.location.dto.LocationResponse destinationLocation = TestUtils.createLocation(restClient, driverToken, "Destination", 40.7589, -73.9851);
        me.devziyad.unipoolbackend.ride.dto.RideResponse ride = TestUtils.createRide(
                restClient,
                driverToken,
                vehicle.getId(),
                pickupLocation.getId(),
                destinationLocation.getId()
        );
        rideId = ride.getRideId();
        
        // Create a booking for payment tests
        bookingId = TestUtils.createBooking(restClient, userToken, rideId, 2);
        
        // Top up user's wallet before creating payment (users start with 0 balance)
        WalletTopUpRequest topUpRequest = new WalletTopUpRequest();
        topUpRequest.setAmount(new BigDecimal("100.00")); // Top up with enough to cover booking cost
        restClient
                .post()
                .uri("/api/payments/wallet/topup")
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(topUpRequest)
                .exchange()
                .expectStatus()
                .isOk();
        
        // Create a payment for tests that need it
        me.devziyad.unipoolbackend.payment.dto.InitiatePaymentRequest paymentRequest = new me.devziyad.unipoolbackend.payment.dto.InitiatePaymentRequest();
        paymentRequest.setBookingId(bookingId);
        paymentRequest.setMethod(me.devziyad.unipoolbackend.common.PaymentMethod.WALLET);
        
        byte[] paymentResponseBytes = restClient
                .post()
                .uri("/api/payments/initiate")
                .header("Authorization", "Bearer " + userToken)
                .contentType(org.springframework.http.MediaType.APPLICATION_JSON)
                .body(paymentRequest)
                .exchange()
                .expectStatus()
                .isCreated()
                .expectBody()
                .returnResult()
                .getResponseBody();
        
        try {
            String paymentResponseBody = new String(paymentResponseBytes);
            @SuppressWarnings("unchecked")
            java.util.Map<String, Object> payment = TestUtils.getObjectMapper().readValue(paymentResponseBody, java.util.Map.class);
            paymentId = Long.valueOf(payment.get("id").toString());
        } catch (Exception e) {
            throw new RuntimeException("Failed to get payment ID", e);
        }
    }

    @Test
    void shouldInitiatePayment() {
        // Create a new ride and booking for this test (user already has a booking for rideId)
        // Use hoursOffset=25 to avoid overlapping with the ride from setUp (which uses 2 hours)
        me.devziyad.unipoolbackend.vehicle.dto.VehicleResponse testVehicle = TestUtils.createVehicle(restClient, driverToken);
        me.devziyad.unipoolbackend.location.dto.LocationResponse testPickup = TestUtils.createLocation(restClient, driverToken, "Test Pickup", 40.7000, -74.0000);
        me.devziyad.unipoolbackend.location.dto.LocationResponse testDestination = TestUtils.createLocation(restClient, driverToken, "Test Destination", 40.7500, -73.9800);
        me.devziyad.unipoolbackend.ride.dto.RideResponse testRide = TestUtils.createRide(
                restClient,
                driverToken,
                testVehicle.getId(),
                testPickup.getId(),
                testDestination.getId(),
                25 // Use 25 hours offset to avoid overlap (rides can be up to 24 hours long)
        );
        
        // Create a new booking for the new ride
        Long testBookingId = TestUtils.createBooking(restClient, userToken, testRide.getRideId(), 1);
        
        InitiatePaymentRequest request = new InitiatePaymentRequest();
        request.setBookingId(testBookingId);
        request.setMethod(PaymentMethod.WALLET);

        restClient
                .post()
                .uri("/api/payments/initiate")
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isCreated()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$.id").exists()
                .jsonPath("$.bookingId").isEqualTo(testBookingId.intValue())
                .jsonPath("$.method").exists();
    }

    @Test
    void shouldRejectInitiatePaymentWithoutAuth() {
        InitiatePaymentRequest request = new InitiatePaymentRequest();
        request.setBookingId(bookingId);
        request.setMethod(PaymentMethod.WALLET);

        // Spring Security returns 403 FORBIDDEN when no authentication token is provided
        restClient
                .post()
                .uri("/api/payments/initiate")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isForbidden();
    }

    @Test
    void shouldGetPaymentById() {
        // This endpoint requires authentication per security config
        restClient
                .get()
                .uri("/api/payments/" + paymentId)
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(paymentId.intValue())
                .jsonPath("$.bookingId").exists();
    }

    @Test
    void shouldGetMyPayments() {
        restClient
                .get()
                .uri("/api/payments/me")
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$").isArray();
    }

    @Test
    void shouldGetMyDriverPayments() {
        restClient
                .get()
                .uri("/api/payments/me/driver")
                .header("Authorization", "Bearer " + driverToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$").isArray();
    }

    @Test
    void shouldGetWalletBalance() {
        restClient
                .get()
                .uri("/api/payments/wallet/balance")
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$.balance").exists();
    }

    @Test
    void shouldTopUpWallet() {
        WalletTopUpRequest request = new WalletTopUpRequest();
        request.setAmount(new BigDecimal("50.00"));

        restClient
                .post()
                .uri("/api/payments/wallet/topup")
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.transactionRef").exists() // topUpWallet returns transactionRef, not id
                .jsonPath("$.amount").isEqualTo(50.00);
    }

    @Test
    void shouldProcessPayment() {
        // Create a new payment for this test since the one from setUp may have been auto-processed
        // Create a new booking first
        // Use hoursOffset=50 to avoid overlapping with other rides (setUp uses 2, shouldInitiatePayment uses 25)
        me.devziyad.unipoolbackend.vehicle.dto.VehicleResponse testVehicle = TestUtils.createVehicle(restClient, driverToken);
        me.devziyad.unipoolbackend.location.dto.LocationResponse testPickup = TestUtils.createLocation(restClient, driverToken, "Process Pickup", 40.7000, -74.0000);
        me.devziyad.unipoolbackend.location.dto.LocationResponse testDestination = TestUtils.createLocation(restClient, driverToken, "Process Destination", 40.7500, -73.9800);
        me.devziyad.unipoolbackend.ride.dto.RideResponse testRide = TestUtils.createRide(
                restClient,
                driverToken,
                testVehicle.getId(),
                testPickup.getId(),
                testDestination.getId(),
                50 // Use 50 hours offset to avoid overlap with other rides
        );
        Long testBookingId = TestUtils.createBooking(restClient, userToken, testRide.getRideId(), 1);
        
        // Create a payment with CARD_SIMULATED method
        // Note: All non-CASH payments are auto-processed asynchronously after 2 seconds
        // We'll try to process it immediately, but if async processing already started, that's also valid
        InitiatePaymentRequest paymentRequest = new InitiatePaymentRequest();
        paymentRequest.setBookingId(testBookingId);
        paymentRequest.setMethod(PaymentMethod.CARD_SIMULATED);
        
        byte[] paymentResponseBytes = restClient
                .post()
                .uri("/api/payments/initiate")
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(paymentRequest)
                .exchange()
                .expectStatus()
                .isCreated()
                .expectBody()
                .returnResult()
                .getResponseBody();
        
        try {
            String paymentResponseBody = new String(paymentResponseBytes);
            @SuppressWarnings("unchecked")
            java.util.Map<String, Object> payment = TestUtils.getObjectMapper().readValue(paymentResponseBody, java.util.Map.class);
            Long testPaymentId = Long.valueOf(payment.get("id").toString());
            
            // Try to process the payment immediately
            // If async processing already started/completed, we'll get an error, which is acceptable
            // In that case, we'll verify the payment is already SETTLED
            try {
                restClient
                        .post()
                        .uri("/api/payments/" + testPaymentId + "/process")
                        .header("Authorization", "Bearer " + userToken)
                        .exchange()
                        .expectStatus()
                        .isOk()
                        .expectBody()
                        .jsonPath("$.id").isEqualTo(testPaymentId.intValue())
                        .jsonPath("$.status").isEqualTo("SETTLED");
            } catch (AssertionError e) {
                // If processing failed (payment already processed by async), verify it's SETTLED
                byte[] getPaymentBytes = restClient
                        .get()
                        .uri("/api/payments/" + testPaymentId)
                        .header("Authorization", "Bearer " + userToken)
                        .exchange()
                        .expectStatus()
                        .isOk()
                        .expectBody()
                        .returnResult()
                        .getResponseBody();
                
                String getPaymentBody = new String(getPaymentBytes);
                @SuppressWarnings("unchecked")
                java.util.Map<String, Object> paymentStatus = TestUtils.getObjectMapper().readValue(getPaymentBody, java.util.Map.class);
                String status = paymentStatus.get("status").toString();
                
                // Payment should be SETTLED (either by our manual process or by async)
                if (!"SETTLED".equals(status)) {
                    throw new AssertionError("Payment should be SETTLED but was: " + status + ". Original error: " + e.getMessage());
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to process payment", e);
        }
    }

    @Test
    void shouldRefundPayment() {
        restClient
                .post()
                .uri("/api/payments/" + paymentId + "/refund")
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(paymentId.intValue());
    }

    @Test
    void shouldRejectTopUpWalletWithoutAuth() {
        WalletTopUpRequest request = new WalletTopUpRequest();
        request.setAmount(new BigDecimal("50.00"));

        // Spring Security returns 403 FORBIDDEN when no authentication token is provided
        restClient
                .post()
                .uri("/api/payments/wallet/topup")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isForbidden();
    }
}

