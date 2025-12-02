package me.devziyad.unipoolbackend.controller;

import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;

@RestController
@RequestMapping("/api/health")
@CrossOrigin(origins = "*")
public class HealthController {

    @Value("${app.version:0.0.1-SNAPSHOT}")
    private String version;

    @GetMapping
    public ResponseEntity<HealthResponse> health() {
        HealthResponse response = new HealthResponse();
        response.setStatus("UP");
        response.setTimestamp(Instant.now().toString());
        response.setVersion(version);
        return ResponseEntity.ok(response);
    }

    @Data
    public static class HealthResponse {
        private String status;
        private String timestamp;
        private String version;
    }
}

