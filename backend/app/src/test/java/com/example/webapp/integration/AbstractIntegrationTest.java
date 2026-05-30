package com.example.webapp.integration;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

/**
 * WHY THIS FILE EXISTS: Base class for all integration tests that require a database.
 * Uses Testcontainers to spin up a real PostgreSQL instance — never use H2 or mocks
 * for integration tests (see ADR-0003). The container is shared across all test classes
 * that extend this base (via static field) to avoid startup overhead.
 *
 * To write an integration test:
 *   1. Extend this class
 *   2. Add @Autowired fields for services/repositories under test
 *   3. Write @Test methods that exercise real database operations
 *   4. Use @Sql to set up test data (prefer @Transactional for rollback)
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
@ActiveProfiles("test")
public abstract class AbstractIntegrationTest {

    @Container
    static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>("postgres:16-alpine")
        .withDatabaseName("webapp_test")
        .withUsername("test")
        .withPassword("test");

    @DynamicPropertySource
    static void configureProperties(final DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
        registry.add("spring.datasource.username", POSTGRES::getUsername);
        registry.add("spring.datasource.password", POSTGRES::getPassword);
    }
}
