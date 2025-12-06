package me.devziyad.unipoolbackend.util;

import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashSet;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Component
@Slf4j
public class ContentFilter {

    private static final String PROFANITY_FILE = "classpath:profanity.txt";
    private static final String PROFANITY_FILE_PATH = "src/main/resources/profanity.txt";
    
    private final ResourceLoader resourceLoader;
    private final boolean isDevMode;
    
    private Pattern profanityPattern;
    private Set<String> profanityWords;
    private long lastModified = 0;

    public ContentFilter(ResourceLoader resourceLoader,
                        @Value("${spring.profiles.active:}") String activeProfiles) {
        this.resourceLoader = resourceLoader;
        this.isDevMode = activeProfiles.contains("dev");
    }

    @PostConstruct
    public void initialize() {
        loadProfanityList();
    }

    /**
     * Loads profanity list from external file
     */
    private void loadProfanityList() {
        try {
            Set<String> words = new HashSet<>();
            
            // Try to load from classpath first
            Resource resource = resourceLoader.getResource(PROFANITY_FILE);
            if (resource.exists() && resource.isReadable()) {
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8))) {
                    words = loadWordsFromReader(reader);
                }
                
                // In dev mode, check for file changes
                if (isDevMode) {
                    try {
                        Path filePath = Paths.get(PROFANITY_FILE_PATH);
                        if (Files.exists(filePath)) {
                            long currentModified = Files.getLastModifiedTime(filePath).toMillis();
                            if (currentModified > lastModified) {
                                log.info("Profanity file changed, reloading...");
                                lastModified = currentModified;
                                // Reload from file system in dev mode
                                try (BufferedReader fileReader = Files.newBufferedReader(filePath, StandardCharsets.UTF_8)) {
                                    words = loadWordsFromReader(fileReader);
                                }
                            }
                        }
                    } catch (Exception e) {
                        log.debug("Could not check file modification time in dev mode: {}", e.getMessage());
                    }
                }
            } else {
                log.warn("Profanity file not found at {}. Using empty blocklist.", PROFANITY_FILE);
            }

            this.profanityWords = words;
            buildPattern();
            log.info("Loaded {} profanity words from blocklist", words.size());
            
        } catch (IOException e) {
            log.error("Error loading profanity file: {}", e.getMessage(), e);
            this.profanityWords = new HashSet<>();
            buildPattern();
        }
    }

    /**
     * Loads words from a BufferedReader, handling comments and blank lines
     */
    private Set<String> loadWordsFromReader(BufferedReader reader) throws IOException {
        Set<String> words = new HashSet<>();
        String line;
        
        while ((line = reader.readLine()) != null) {
            // Trim whitespace
            line = line.trim();
            
            // Skip blank lines and comments
            if (line.isEmpty() || line.startsWith("#")) {
                continue;
            }
            
            // Normalize word (lowercase, remove extra spaces)
            String normalized = normalizeWord(line);
            if (!normalized.isEmpty()) {
                words.add(normalized);
            }
        }
        
        return words;
    }

    /**
     * Builds the compiled regex pattern from profanity words
     */
    private void buildPattern() {
        if (profanityWords.isEmpty()) {
            // Create a pattern that never matches
            this.profanityPattern = Pattern.compile("(?!)");
            return;
        }

        // Quote each word to treat it as literal, then join with |
        String patternString = profanityWords.stream()
                .map(Pattern::quote)
                .collect(Collectors.joining("|"));
        
        // Use word boundaries to match whole words only, case-insensitive
        this.profanityPattern = Pattern.compile("\\b(" + patternString + ")\\b", Pattern.CASE_INSENSITIVE);
    }

    /**
     * Normalizes a word for matching (lowercase, remove repeated characters, trim)
     */
    private String normalizeWord(String word) {
        if (word == null || word.isEmpty()) {
            return "";
        }
        
        // Convert to lowercase
        String normalized = word.toLowerCase().trim();
        
        // Remove excessive repeated characters (e.g., "shitttt" -> "shitt")
        // Keep up to 3 consecutive identical characters
        normalized = normalized.replaceAll("(.)\\1{3,}", "$1$1$1");
        
        return normalized;
    }

    /**
     * Normalizes content for profanity checking
     */
    private String normalizeContent(String content) {
        if (content == null || content.isEmpty()) {
            return "";
        }
        
        // Convert to lowercase
        String normalized = content.toLowerCase();
        
        // Remove excessive repeated characters
        normalized = normalized.replaceAll("(.)\\1{3,}", "$1$1$1");
        
        // Remove common obfuscation characters (keep letters, numbers, and basic punctuation)
        normalized = normalized.replaceAll("[^a-z0-9\\s]", "");
        
        // Normalize whitespace
        normalized = normalized.replaceAll("\\s+", " ").trim();
        
        return normalized;
    }

    /**
     * Checks if content contains profanity
     */
    public boolean containsProfanity(String content) {
        if (content == null || content.trim().isEmpty()) {
            return false;
        }
        
        // Reload in dev mode if file changed
        if (isDevMode) {
            try {
                Path filePath = Paths.get(PROFANITY_FILE_PATH);
                if (Files.exists(filePath)) {
                    long currentModified = Files.getLastModifiedTime(filePath).toMillis();
                    if (currentModified > lastModified) {
                        loadProfanityList();
                    }
                }
            } catch (Exception e) {
                // Ignore errors in hot-reload check
            }
        }
        
        // Normalize content
        String normalized = normalizeContent(content);
        
        // Check against pattern
        Matcher matcher = profanityPattern.matcher(normalized);
        return matcher.find();
    }

    /**
     * Filters profanity from content by replacing with asterisks
     */
    public String filterProfanity(String content) {
        if (content == null || content.trim().isEmpty()) {
            return content;
        }
        
        // Reload in dev mode if file changed
        if (isDevMode) {
            try {
                Path filePath = Paths.get(PROFANITY_FILE_PATH);
                if (Files.exists(filePath)) {
                    long currentModified = Files.getLastModifiedTime(filePath).toMillis();
                    if (currentModified > lastModified) {
                        loadProfanityList();
                    }
                }
            } catch (Exception e) {
                // Ignore errors in hot-reload check
            }
        }
        
        String filtered = content;
        
        // Create a pattern that matches each word individually for replacement
        for (String word : profanityWords) {
            // Match word boundaries, case-insensitive
            Pattern wordPattern = Pattern.compile("\\b" + Pattern.quote(word) + "\\b", Pattern.CASE_INSENSITIVE);
            Matcher matcher = wordPattern.matcher(filtered);
            
            // Replace with asterisks matching word length
            filtered = matcher.replaceAll(matchResult -> "*".repeat(matchResult.group().length()));
        }
        
        return filtered;
    }

    /**
     * Sanitizes user input to prevent XSS and other attacks
     */
    public String sanitize(String input) {
        if (input == null) {
            return null;
        }
        
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;")
                .replace("/", "&#x2F;")
                .replace("\\", "&#x5C;")
                .replace("`", "&#x60;")
                .replace("=", "&#x3D;")
                .trim();
    }

    /**
     * Gets the current number of profanity words loaded
     */
    public int getProfanityWordCount() {
        return profanityWords != null ? profanityWords.size() : 0;
    }
}
