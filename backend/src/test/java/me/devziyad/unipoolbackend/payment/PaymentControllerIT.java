package me.devziyad.unipoolbackend.payment;

import me.devziyad.unipoolbackend.common.PaymentMethod;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.payment.dto.InitiatePaymentRequest;
import me.devziyad.unipoolbackend.payment.dto.WalletTopUpRequest;
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
public class PaymentControllerIT {

    @Autowired
    private RestTestClient restClient;

    private String userToken;
    private String driverToken;

    @BeforeEach
    void setUp() {
        // Create regular user
        userToken = TestUtils.registerAndGetToken(
                restClient,
                "user@example.com",
                "user123",
                "User",
                Role.RIDER
        );

        // Create driver user
        driverToken = TestUtils.registerAndGetToken(
                restClient,
                "driver@example.com",
                "driver123",
                "Driver",
                Role.DRIVER
        );
    }

    @Test
    void shouldInitiatePayment() {
        InitiatePaymentRequest request = new InitiatePaymentRequest();
        request.setBookingId(1L);
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
                .jsonPath("$.bookingId").isEqualTo(1)
                .jsonPath("$.method").exists();
    }

    @Test
    void shouldRejectInitiatePaymentWithoutAuth() {
        InitiatePaymentRequest request = new InitiatePaymentRequest();
        request.setBookingId(1L);
        request.setMethod(PaymentMethod.WALLET);

        restClient
                .post()
                .uri("/api/payments/initiate")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isUnauthorized();
    }

    @Test
    void shouldGetPaymentById() {
        restClient
                .get()
                .uri("/api/payments/1")
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.id").exists();
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
                .jsonPath("$.id").exists();
    }

    @Test
    void shouldProcessPayment() {
        restClient
                .post()
                .uri("/api/payments/1/process")
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.id").exists();
    }

    @Test
    void shouldRefundPayment() {
        restClient
                .post()
                .uri("/api/payments/1/refund")
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.id").exists();
    }

    @Test
    void shouldRejectTopUpWalletWithoutAuth() {
        WalletTopUpRequest request = new WalletTopUpRequest();
        request.setAmount(new BigDecimal("50.00"));

        restClient
                .post()
                .uri("/api/payments/wallet/topup")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isUnauthorized();
    }
}

