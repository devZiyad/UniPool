package me.devziyad.unipoolbackend.audit;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuditService {

    private final AuditLogRepository auditLogRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    // Public method that extracts request data before async execution
    public void logAction(ActionType actionType, Long userId, Map<String, Object> metadata, HttpServletRequest request) {
        // Extract request data synchronously before async execution
        String ipAddress = getClientIpAddress(request);
        String userAgent = request != null ? request.getHeader("User-Agent") : null;
        // Truncate user agent if needed
        if (userAgent != null && userAgent.length() > 500) {
            userAgent = userAgent.substring(0, 500);
        }
        // Call async method with extracted data
        logActionAsync(actionType, userId, metadata, ipAddress, userAgent);
    }

    @Async
    @Transactional
    private void logActionAsync(ActionType actionType, Long userId, Map<String, Object> metadata, String ipAddress, String userAgent) {
        try {
            String metadataJson = metadata != null ? objectMapper.writeValueAsString(metadata) : null;

            AuditLog auditLog = AuditLog.builder()
                    .userId(userId)
                    .actionType(actionType)
                    .timestamp(Instant.now())
                    .metadata(metadataJson)
                    .ipAddress(ipAddress)
                    .userAgent(userAgent)
                    .build();

            auditLogRepository.save(auditLog);
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize audit log metadata", e);
        } catch (Exception e) {
            log.error("Failed to create audit log", e);
        }
    }

    public void logAction(ActionType actionType, Long userId, HttpServletRequest request) {
        logAction(actionType, userId, null, request);
    }

    public void logAction(ActionType actionType, Long userId, String metadataKey, Object metadataValue, HttpServletRequest request) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put(metadataKey, metadataValue);
        logAction(actionType, userId, metadata, request);
    }

    private String getClientIpAddress(HttpServletRequest request) {
        if (request == null) {
            return null;
        }
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

