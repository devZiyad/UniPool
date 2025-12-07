package me.devziyad.unipoolbackend.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.FileNotFoundException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Scanner;

/**
 * Loads environment variables from .env file if it exists.
 * This runs before other CommandLineRunner components to ensure env vars are available.
 */
@Component
@Slf4j
@Order(Integer.MIN_VALUE) // Run first
public class EnvFileLoader implements CommandLineRunner {

    private static final String ENV_FILE = ".env";
    private static final String ENV_TEMPLATE = ".env.template";

    @Override
    public void run(String... args) {
        Path envPath = Paths.get(ENV_FILE);
        Path templatePath = Paths.get(ENV_TEMPLATE);

        // Check if .env file exists
        if (!Files.exists(envPath)) {
            log.error("================================================================");
            log.error("ERROR: .env file not found!");
            log.error("================================================================");
            log.error("");
            log.error("The .env file is REQUIRED for the application to start.");
            log.error("Please create a .env file in the project root directory.");
            if (Files.exists(templatePath)) {
                log.error("");
                log.error("A template file (.env.template) is available.");
                log.error("Copy it to .env and fill in your admin credentials:");
                log.error("  cp .env.template .env");
            } else {
                log.error("");
                log.error("Required environment variables:");
                log.error("  - ADMIN_EMAIL");
                log.error("  - ADMIN_PASSWORD");
                log.error("  - ADMIN_UNIVERSITY_ID");
                log.error("  - ADMIN_FULL_NAME");
                log.error("  - ADMIN_PHONE_NUMBER (optional)");
            }
            log.error("");
            log.error("Example .env file:");
            log.error("  ADMIN_EMAIL=admin@unipool.edu");
            log.error("  ADMIN_PASSWORD=your_secure_password");
            log.error("  ADMIN_UNIVERSITY_ID=ADMIN001");
            log.error("  ADMIN_FULL_NAME=System Administrator");
            log.error("  ADMIN_PHONE_NUMBER=");
            log.error("");
            log.error("The application cannot start without a .env file.");
            log.error("================================================================");
            throw new IllegalStateException(".env file is required but not found. Please create it from .env.template");
        }

        // Load .env file
        try {
            loadEnvFile(envPath.toFile());
            log.info("Successfully loaded environment variables from .env file");
        } catch (Exception e) {
            log.error("Failed to load .env file: {}", e.getMessage());
            log.error("The application cannot start without a valid .env file.");
            throw new IllegalStateException("Failed to load .env file: " + e.getMessage(), e);
        }
    }

    private void loadEnvFile(File envFile) throws FileNotFoundException {
        try (Scanner scanner = new Scanner(envFile)) {
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine().trim();
                
                // Skip empty lines and comments
                if (line.isEmpty() || line.startsWith("#")) {
                    continue;
                }

                // Parse KEY=VALUE format
                int equalsIndex = line.indexOf('=');
                if (equalsIndex > 0) {
                    String key = line.substring(0, equalsIndex).trim();
                    String value = line.substring(equalsIndex + 1).trim();
                    
                    // Remove quotes if present
                    if ((value.startsWith("\"") && value.endsWith("\"")) ||
                        (value.startsWith("'") && value.endsWith("'"))) {
                        value = value.substring(1, value.length() - 1);
                    }
                    
                    // Set as system property (Spring Boot will pick it up via @Value)
                    if (!value.isEmpty()) {
                        System.setProperty(key, value);
                    }
                }
            }
        }
    }
}

