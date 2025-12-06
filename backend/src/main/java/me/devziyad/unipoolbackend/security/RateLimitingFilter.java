package me.devziyad.unipoolbackend.security;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Order(1)
@Slf4j
public class RateLimitingFilter extends OncePerRequestFilter {

    // Rate limit buckets per IP address
    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

    // General API rate limit: 100 requests per minute
    private static final int GENERAL_LIMIT = 100;
    private static final Duration GENERAL_WINDOW = Duration.ofMinutes(1);

    // Auth endpoints rate limit: 5 requests per minute
    private static final int AUTH_LIMIT = 5;
    private static final Duration AUTH_WINDOW = Duration.ofMinutes(1);

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String clientIp = getClientIpAddress(request);
        String path = request.getRequestURI();

        // Determine rate limit based on endpoint
        int limit;
        Duration window;
        if (path.startsWith("/api/auth/login") || path.startsWith("/api/auth/register")) {
            limit = AUTH_LIMIT;
            window = AUTH_WINDOW;
        } else {
            limit = GENERAL_LIMIT;
            window = GENERAL_WINDOW;
        }

        Bucket bucket = buckets.computeIfAbsent(clientIp, key -> createBucket(limit, window));

        if (bucket.tryConsume(1)) {
            filterChain.doFilter(request, response);
        } else {
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Too many requests. Please try again later.\"}");
            log.warn("Rate limit exceeded for IP: {} on path: {}", clientIp, path);
        }
    }

    private Bucket createBucket(int limit, Duration window) {
        Bandwidth bandwidth = Bandwidth.builder()
                .capacity(limit)
                .refillIntervally(limit, window)
                .build();
        return Bucket.builder()
                .addLimit(bandwidth)
                .build();
    }

    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        return request.getRemoteAddr();
    }
}

