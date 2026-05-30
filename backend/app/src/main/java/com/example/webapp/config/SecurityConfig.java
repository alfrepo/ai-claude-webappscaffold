package com.example.webapp.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

/**
 * WHY THIS FILE EXISTS: Central security configuration.
 * DENY-ALL by default — explicitly permit only what is needed.
 * CORS is locked to the frontend origin set via FRONTEND_ORIGIN env var.
 * To permit a new endpoint:
 *   1. Add an ADR if it changes the security boundary
 *   2. Add the path to the permitAll() list below with a comment explaining why
 *   3. Write a security integration test proving unauthenticated access is rejected elsewhere
 *
 * The backend is stateless (JWT). No server-side sessions are created.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Value("${app.security.frontend-origin}")
    private String frontendOrigin;

    /**
     * Configures the security filter chain with deny-all defaults.
     *
     * @param http the HttpSecurity builder
     * @return the configured SecurityFilterChain
     * @throws Exception if configuration fails
     */
    @Bean
    public SecurityFilterChain securityFilterChain(final HttpSecurity http) throws Exception {
        return http
            .csrf(AbstractHttpConfigurer::disable)
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // Actuator health: public — needed for ECS/ALB health checks
                .requestMatchers("/actuator/health").permitAll()
                // Actuator info: public — version info for monitoring dashboards
                .requestMatchers("/actuator/info").permitAll()
                // OpenAPI spec: public — consumed by frontend generator and docs
                .requestMatchers("/v3/api-docs/**", "/swagger-ui/**").permitAll()
                // Actuator metrics: secured — Prometheus scraper uses a dedicated role
                .requestMatchers("/actuator/**").hasRole("ACTUATOR")
                // DENY ALL by default — add explicit permits above as features are added
                .anyRequest().authenticated()
            )
            .build();
    }

    /**
     * Configures CORS to allow requests only from the declared frontend origin.
     * The origin is injected from the FRONTEND_ORIGIN environment variable.
     *
     * @return the CORS configuration source
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(List.of(frontendOrigin));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("Authorization", "Content-Type", "X-Requested-With"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
