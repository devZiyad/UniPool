package me.devziyad.unipoolbackend.security;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Component
@RequiredArgsConstructor
@Slf4j
public class CleanupScheduler {

    private final TokenBlacklistRepository tokenBlacklistRepository;
    private final FailedLoginAttemptRepository failedLoginAttemptRepository;

    @Scheduled(cron = "0 0 * * * *") // Run every hour
    @Transactional
    public void cleanupExpiredTokens() {
        Instant now = Instant.now();
        tokenBlacklistRepository.deleteExpiredTokens(now);
        log.info("Cleaned up expired tokens");
    }

    @Scheduled(cron = "0 0 0 * * *") // Run daily at midnight
    @Transactional
    public void cleanupOldFailedAttempts() {
        Instant oneDayAgo = Instant.now().minusSeconds(24L * 60 * 60);
        failedLoginAttemptRepository.deleteOldAttempts(oneDayAgo);
        log.info("Cleaned up old failed login attempts");
    }
}

