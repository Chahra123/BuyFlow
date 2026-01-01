package com.esprit.examen.security;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class RateLimitFilter extends OncePerRequestFilter {

    private final Map<String, RequestLog> requestCounts = new ConcurrentHashMap<>();
    private static final int MAX_REQUESTS = 5;
    private static final int TIME_WINDOW_MINUTES = 15;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        
        System.out.println("DEBUG: RateLimitFilter - " + request.getMethod() + " " + request.getRequestURI());

        if ("/api/auth/login".equals(request.getRequestURI()) && "POST".equalsIgnoreCase(request.getMethod())) {
            String clientIp = request.getRemoteAddr();
            cleanUpOldEntries();

            RequestLog log = requestCounts.computeIfAbsent(clientIp, k -> new RequestLog(0, LocalDateTime.now()));

            if (log.timestamp.isBefore(LocalDateTime.now().minusMinutes(TIME_WINDOW_MINUTES))) {
                // Reset window
                requestCounts.put(clientIp, new RequestLog(1, LocalDateTime.now()));
            } else {
                if (log.count >= MAX_REQUESTS) {
                    response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
                    response.getWriter().write("Too many login attempts. Please try again later.");
                    return;
                }
                log.count++;
            }
        }

        filterChain.doFilter(request, response);
    }

    private void cleanUpOldEntries() {
        LocalDateTime cutoff = LocalDateTime.now().minusMinutes(TIME_WINDOW_MINUTES);
        requestCounts.entrySet().removeIf(entry -> entry.getValue().timestamp.isBefore(cutoff));
    }

    private static class RequestLog {
        int count;
        LocalDateTime timestamp;

        RequestLog(int count, LocalDateTime timestamp) {
            this.count = count;
            this.timestamp = timestamp;
        }
    }
}
