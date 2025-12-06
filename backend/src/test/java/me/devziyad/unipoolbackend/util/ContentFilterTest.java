package me.devziyad.unipoolbackend.util;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.test.util.ReflectionTestUtils;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ContentFilterTest {

    @Mock
    private ResourceLoader resourceLoader;

    @Mock
    private Resource resource;

    private ContentFilter contentFilter;

    @BeforeEach
    void setUp() throws Exception {
        // Create a test profanity list
        String testProfanityList = """
            # Test profanity list
            damn
            hell
            crap
            ass
            bitch
            fuck
            shit
            # Obfuscated variants
            f*ck
            sh*t
            a$$hole
            """;

        InputStream inputStream = new ByteArrayInputStream(testProfanityList.getBytes(StandardCharsets.UTF_8));
        
        when(resourceLoader.getResource(anyString())).thenReturn(resource);
        when(resource.exists()).thenReturn(true);
        when(resource.isReadable()).thenReturn(true);
        when(resource.getInputStream()).thenReturn(inputStream);

        contentFilter = new ContentFilter(resourceLoader, "");
        ReflectionTestUtils.invokeMethod(contentFilter, "initialize");
    }

    @Test
    void testContainsProfanity_DetectsDirectProfanity() {
        assertTrue(contentFilter.containsProfanity("This is a damn test"));
        assertTrue(contentFilter.containsProfanity("What the hell"));
        assertTrue(contentFilter.containsProfanity("That's crap"));
        assertTrue(contentFilter.containsProfanity("You're an ass"));
        assertTrue(contentFilter.containsProfanity("That's a bitch"));
        assertTrue(contentFilter.containsProfanity("Fuck this"));
        assertTrue(contentFilter.containsProfanity("Oh shit"));
    }

    @Test
    void testContainsProfanity_DetectsCaseVariations() {
        assertTrue(contentFilter.containsProfanity("DAMN"));
        assertTrue(contentFilter.containsProfanity("Hell"));
        assertTrue(contentFilter.containsProfanity("CRAP"));
        assertTrue(contentFilter.containsProfanity("FUCK"));
        assertTrue(contentFilter.containsProfanity("ShIt"));
    }

    @Test
    void testContainsProfanity_DetectsObfuscatedVariants() {
        assertTrue(contentFilter.containsProfanity("f*ck this"));
        assertTrue(contentFilter.containsProfanity("sh*t happens"));
        assertTrue(contentFilter.containsProfanity("a$$hole"));
    }

    @Test
    void testContainsProfanity_DoesNotDetectCleanContent() {
        assertFalse(contentFilter.containsProfanity("This is a clean message"));
        assertFalse(contentFilter.containsProfanity("Hello world"));
        assertFalse(contentFilter.containsProfanity("Testing 123"));
        assertFalse(contentFilter.containsProfanity(""));
    }

    @Test
    void testContainsProfanity_HandlesNullAndEmpty() {
        assertFalse(contentFilter.containsProfanity(null));
        assertFalse(contentFilter.containsProfanity(""));
        assertFalse(contentFilter.containsProfanity("   "));
    }

    @Test
    void testFilterProfanity_ReplacesProfanityWithAsterisks() {
        assertEquals("This is a **** test", contentFilter.filterProfanity("This is a damn test"));
        assertEquals("What the ****", contentFilter.filterProfanity("What the hell"));
        assertEquals("That's ****", contentFilter.filterProfanity("That's crap"));
        assertEquals("You're an ***", contentFilter.filterProfanity("You're an ass"));
        assertEquals("That's a *****", contentFilter.filterProfanity("That's a bitch"));
        assertEquals("**** this", contentFilter.filterProfanity("Fuck this"));
        assertEquals("Oh ****", contentFilter.filterProfanity("Oh shit"));
    }

    @Test
    void testFilterProfanity_PreservesCaseInReplacement() {
        String result = contentFilter.filterProfanity("DAMN it");
        assertTrue(result.contains("****"));
        assertFalse(result.contains("damn"));
    }

    @Test
    void testFilterProfanity_HandlesMultipleOccurrences() {
        String result = contentFilter.filterProfanity("damn this damn thing");
        assertEquals("**** this **** thing", result);
    }

    @Test
    void testFilterProfanity_HandlesNullAndEmpty() {
        assertNull(contentFilter.filterProfanity(null));
        assertEquals("", contentFilter.filterProfanity(""));
        assertEquals("   ", contentFilter.filterProfanity("   "));
    }

    @Test
    void testSanitize_EscapesHtmlTags() {
        assertEquals("&lt;script&gt;alert(&#x27;xss&#x27;)&lt;/script&gt;", 
                contentFilter.sanitize("<script>alert('xss')</script>"));
        assertEquals("&lt;div&gt;content&lt;/div&gt;", 
                contentFilter.sanitize("<div>content</div>"));
    }

    @Test
    void testSanitize_EscapesQuotes() {
        assertEquals("&quot;quoted text&quot;", contentFilter.sanitize("\"quoted text\""));
        assertEquals("&#x27;single quote&#x27;", contentFilter.sanitize("'single quote'"));
    }

    @Test
    void testSanitize_EscapesSpecialCharacters() {
        assertEquals("test&#x2F;path", contentFilter.sanitize("test/path"));
        assertEquals("back&#x5C;slash", contentFilter.sanitize("back\\slash"));
        assertEquals("equals&#x3D;sign", contentFilter.sanitize("equals=sign"));
        assertEquals("backtick&#x60;test", contentFilter.sanitize("backtick`test"));
    }

    @Test
    void testSanitize_EscapesAmpersand() {
        assertEquals("test&amp;result", contentFilter.sanitize("test&result"));
        assertEquals("&amp;&amp;", contentFilter.sanitize("&&"));
    }

    @Test
    void testSanitize_TrimsWhitespace() {
        assertEquals("test", contentFilter.sanitize("  test  "));
        assertEquals("test", contentFilter.sanitize("\ttest\n"));
    }

    @Test
    void testSanitize_HandlesNull() {
        assertNull(contentFilter.sanitize(null));
    }

    @Test
    void testSanitize_HandlesComplexXssAttempt() {
        String xss = "<img src=x onerror=alert('XSS')>";
        String sanitized = contentFilter.sanitize(xss);
        assertFalse(sanitized.contains("<"));
        assertFalse(sanitized.contains(">"));
        assertTrue(sanitized.contains("&lt;"));
        assertTrue(sanitized.contains("&gt;"));
    }

    @Test
    void testContainsProfanity_DetectsRepeatedCharacters() {
        // Test normalization handles repeated characters
        assertTrue(contentFilter.containsProfanity("shitttt"));
        assertTrue(contentFilter.containsProfanity("fuuuuck"));
    }

    @Test
    void testFilterProfanity_WithObfuscatedVariants() {
        String result = contentFilter.filterProfanity("f*ck this sh*t");
        assertTrue(result.contains("****"));
        assertTrue(result.contains("****"));
        assertFalse(result.contains("f*ck"));
        assertFalse(result.contains("sh*t"));
    }

    @Test
    void testGetProfanityWordCount() {
        int count = contentFilter.getProfanityWordCount();
        assertTrue(count > 0, "Should have loaded profanity words");
    }

    @Test
    void testHandlesMissingProfanityFile() throws Exception {
        when(resource.exists()).thenReturn(false);
        
        ContentFilter filterWithMissingFile = new ContentFilter(resourceLoader, "");
        ReflectionTestUtils.invokeMethod(filterWithMissingFile, "initialize");
        
        // Should not throw exception, just use empty list
        assertFalse(filterWithMissingFile.containsProfanity("damn"));
        assertEquals(0, filterWithMissingFile.getProfanityWordCount());
    }

    @Test
    void testHandlesEmptyProfanityFile() throws Exception {
        String emptyList = "# Empty list\n# No words here\n";
        InputStream emptyStream = new ByteArrayInputStream(emptyList.getBytes(StandardCharsets.UTF_8));
        
        when(resource.getInputStream()).thenReturn(emptyStream);
        
        ContentFilter filterWithEmptyFile = new ContentFilter(resourceLoader, "");
        ReflectionTestUtils.invokeMethod(filterWithEmptyFile, "initialize");
        
        assertFalse(filterWithEmptyFile.containsProfanity("damn"));
        assertEquals(0, filterWithEmptyFile.getProfanityWordCount());
    }

    @Test
    void testIgnoresCommentsAndBlankLines() throws Exception {
        String listWithComments = """
            # This is a comment
            damn
            
            # Another comment
            hell
            # Inline comment test
            crap
            """;
        
        InputStream stream = new ByteArrayInputStream(listWithComments.getBytes(StandardCharsets.UTF_8));
        when(resource.getInputStream()).thenReturn(stream);
        
        ContentFilter filter = new ContentFilter(resourceLoader, "");
        ReflectionTestUtils.invokeMethod(filter, "initialize");
        
        assertTrue(filter.containsProfanity("damn"));
        assertTrue(filter.containsProfanity("hell"));
        assertTrue(filter.containsProfanity("crap"));
    }
}

