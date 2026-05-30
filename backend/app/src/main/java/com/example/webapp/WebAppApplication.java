package com.example.webapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * WHY THIS FILE EXISTS: Spring Boot application entry point.
 * The application starts here. Do not add business logic here.
 * Profile selection is driven by the SPRING_PROFILES_ACTIVE environment variable.
 * Available profiles: local, dev, staging, prod.
 */
@SpringBootApplication
public class WebAppApplication {

    /**
     * Application entry point.
     *
     * @param args command-line arguments (passed to Spring)
     */
    public static void main(final String[] args) {
        SpringApplication.run(WebAppApplication.class, args);
    }
}
