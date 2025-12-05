package me.devziyad.unipoolbackend.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

import static org.assertj.core.api.Assertions.assertThat;

@AutoConfigureRestTestClient
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class HealthControllerIT {

    @Autowired
    private RestTestClient restClient;

    @Test
    void shouldReturnSuccessfulHealthCheck() {
        restClient
                .get()
                .uri("/api/health")
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$.status").isEqualTo("UP")
                .jsonPath("$.timestamp").exists()
                .jsonPath("$.version").exists();
    }

    @Test
    void healthCheckShouldContainValidFields() {
        byte[] responseBytes = restClient
                .get()
                .uri("/api/health")
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .returnResult()
                .getResponseBody();

        String responseBody = new String(responseBytes);

        assertThat(responseBody)
                .contains("\"status\"")
                .contains("\"timestamp\"")
                .contains("\"version\"");
    }
}

