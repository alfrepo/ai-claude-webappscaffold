package com.example.webapp.integration;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * WHY THIS FILE EXISTS: Integration test verifying the health endpoint returns
 * a valid response with a real PostgreSQL database (via Testcontainers).
 * This is the minimum viable integration test for a new project.
 * Add tests here when the health endpoint evolves (e.g., custom health indicators).
 */
class HealthEndpointIntegrationTest extends AbstractIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void healthEndpoint_withDatabaseUp_returnsStatusUp() {
        ResponseEntity<String> response = restTemplate.getForEntity("/actuator/health", String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).contains("UP");
    }
}
