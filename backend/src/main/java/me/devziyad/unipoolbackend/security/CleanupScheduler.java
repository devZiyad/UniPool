package me.devziyad.unipoolbackend.security;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
@Slf4j
public class CleanupScheduler {

    private final TokenBlacklistRepository tokenBlacklistRepository;
    private final FailedLoginAttemptRepository failedLoginAttemptRepository;

    @Scheduled(cron = "0 0 * * * *") // Run every hour
    @Transactional
    public void cleanupExpiredTokens() {
        LocalDateTime now = LocalDateTime.now();
        tokenBlacklistRepository.deleteExpiredTokens(now);
        log.info("Cleaned up expired tokens");
    }

    @Scheduled(cron = "0 0 0 * * *") // Run daily at midnight
    @Transactional
    public void cleanupOldFailedAttempts() {
        LocalDateTime oneDayAgo = LocalDateTime.now().minusDays(1);
        failedLoginAttemptRepository.deleteOldAttempts(oneDayAgo);
        log.info("Cleaned up old failed login attempts");
    }
}

