package com.example.webapp.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.net.URI;
import java.util.List;
import java.util.Map;

/**
 * WHY THIS FILE EXISTS: Centralized exception-to-HTTP-response mapping.
 * All exceptions thrown from controllers or services land here.
 * Responses follow RFC 7807 Problem Details (ProblemDetail is native in Spring 6+).
 * To add a new error case:
 *   1. Define a domain exception in the domain/ module (extends RuntimeException)
 *   2. Add an @ExceptionHandler method here
 *   3. Add the corresponding 4xx/5xx response to the OpenAPI spec
 *   4. Write a controller integration test that verifies the error response shape
 * NEVER expose stack traces, internal class names, or DB error messages to clients.
 */
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    private static final String PROBLEMS_BASE_URI = "https://example.com/problems";

    /**
     * Handles Bean Validation errors from @Valid-annotated request bodies.
     * Returns HTTP 400 with a list of field-level errors.
     *
     * @param ex the validation exception
     * @return RFC 7807 problem detail with field errors
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ProblemDetail handleValidationException(final MethodArgumentNotValidException ex) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(
            HttpStatus.BAD_REQUEST,
            "Request validation failed"
        );
        problem.setType(URI.create(PROBLEMS_BASE_URI + "/validation-error"));
        problem.setTitle("Validation Error");

        List<Map<String, String>> fieldErrors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(error -> Map.of(
                "field", error.getField(),
                "message", defaultString(error.getDefaultMessage()),
                "rejectedValue", String.valueOf(error.getRejectedValue())
            ))
            .toList();

        problem.setProperty("errors", fieldErrors);
        return problem;
    }

    /**
     * Catch-all handler for unexpected exceptions.
     * Logs the full exception but returns a safe generic message to the client.
     *
     * @param ex the unexpected exception
     * @return RFC 7807 problem detail with generic message
     */
    @ExceptionHandler(Exception.class)
    public ProblemDetail handleUnexpectedException(final Exception ex) {
        log.error("Unexpected error", ex);
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(
            HttpStatus.INTERNAL_SERVER_ERROR,
            "An unexpected error occurred. Please try again later."
        );
        problem.setType(URI.create(PROBLEMS_BASE_URI + "/internal-error"));
        problem.setTitle("Internal Server Error");
        return problem;
    }

    private String defaultString(final String value) {
        return value != null ? value : "";
    }
}
