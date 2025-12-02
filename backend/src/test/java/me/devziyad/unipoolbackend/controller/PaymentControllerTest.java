package me.devziyad.unipoolbackend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.common.PaymentMethod;
import me.devziyad.unipoolbackend.config.TestSecurityConfig;
import me.devziyad.unipoolbackend.payment.PaymentController;
import me.devziyad.unipoolbackend.payment.PaymentService;
import me.devziyad.unipoolbackend.payment.dto.InitiatePaymentRequest;
import me.devziyad.unipoolbackend.payment.dto.PaymentResponse;
import me.devziyad.unipoolbackend.payment.dto.WalletTopUpRequest;
import me.devziyad.unipoolbackend.user.User;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(controllers = PaymentController.class)
@Import(TestSecurityConfig.class)
@DisplayName("PaymentController Tests")
class PaymentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private PaymentService paymentService;

    @MockitoBean
    private AuthService authService;

    private static final Long TEST_USER_ID = 1L;
    private static final Long TEST_PAYMENT_ID = 1L;

    @Test
    @DisplayName("POST /api/payments/initiate should return 201 with payment")
    void initiatePayment_shouldReturn201_withPayment() throws Exception {
        InitiatePaymentRequest request = new InitiatePaymentRequest();
        request.setBookingId(1L);
        request.setMethod(PaymentMethod.CARD_SIMULATED);

        PaymentResponse response = PaymentResponse.builder()
                .id(TEST_PAYMENT_ID)
                .payerId(TEST_USER_ID)
                .bookingId(1L)
                .amount(BigDecimal.valueOf(25.00))
                .method(PaymentMethod.CARD_SIMULATED)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(paymentService.initiatePayment(any(InitiatePaymentRequest.class), eq(TEST_USER_ID)))
                .thenReturn(response);

        mockMvc.perform(post("/api/payments/initiate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.payerId").value(TEST_USER_ID))
                .andExpect(jsonPath("$.method").value("CARD_SIMULATED"));
    }

    @Test
    @DisplayName("GET /api/payments/{id} should return 200 with payment")
    void getPayment_shouldReturn200_withPayment() throws Exception {
        PaymentResponse response = PaymentResponse.builder()
                .id(TEST_PAYMENT_ID)
                .payerId(TEST_USER_ID)
                .amount(BigDecimal.valueOf(25.00))
                .build();

        when(paymentService.getPaymentById(TEST_PAYMENT_ID)).thenReturn(response);

        mockMvc.perform(get("/api/payments/" + TEST_PAYMENT_ID))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(TEST_PAYMENT_ID));
    }

    @Test
    @DisplayName("GET /api/payments/me should return 200 with user payments")
    void getMyPayments_shouldReturn200_withUserPayments() throws Exception {
        PaymentResponse payment1 = PaymentResponse.builder()
                .id(1L)
                .payerId(TEST_USER_ID)
                .build();

        PaymentResponse payment2 = PaymentResponse.builder()
                .id(2L)
                .payerId(TEST_USER_ID)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(paymentService.getPaymentsForUser(TEST_USER_ID))
                .thenReturn(List.of(payment1, payment2));

        mockMvc.perform(get("/api/payments/me"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].payerId").value(TEST_USER_ID));
    }

    @Test
    @DisplayName("GET /api/payments/wallet/balance should return 200 with balance")
    void getWalletBalance_shouldReturn200_withBalance() throws Exception {
        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(paymentService.getWalletBalance(TEST_USER_ID))
                .thenReturn(BigDecimal.valueOf(100.00));

        mockMvc.perform(get("/api/payments/wallet/balance"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.balance").value(100.00));
    }

    @Test
    @DisplayName("POST /api/payments/wallet/topup should return 200 with payment")
    void topUpWallet_shouldReturn200_withPayment() throws Exception {
        WalletTopUpRequest request = new WalletTopUpRequest();
        request.setAmount(BigDecimal.valueOf(50.00));

        PaymentResponse response = PaymentResponse.builder()
                .id(TEST_PAYMENT_ID)
                .amount(BigDecimal.valueOf(50.00))
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(paymentService.topUpWallet(any(WalletTopUpRequest.class), eq(TEST_USER_ID)))
                .thenReturn(response);

        mockMvc.perform(post("/api/payments/wallet/topup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.amount").value(50.00));
    }
}
