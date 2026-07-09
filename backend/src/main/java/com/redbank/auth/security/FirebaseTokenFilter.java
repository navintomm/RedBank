package com.redbank.auth.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class FirebaseTokenFilter extends OncePerRequestFilter {

    private final JwtProvider jwtProvider;
    private final CustomUserDetailsService userDetailsService;

    public FirebaseTokenFilter(JwtProvider jwtProvider, CustomUserDetailsService userDetailsService) {
        this.jwtProvider = jwtProvider;
        this.userDetailsService = userDetailsService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        
        // Skip filter for non-protected endpoints like /login and /verify
        String path = request.getRequestURI();
        if (path.startsWith("/api/v1/auth/verify") || path.startsWith("/api/v1/auth/refresh")) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            String jwt = parseJwt(request);
            if (jwt != null && jwtProvider.validateJwtToken(jwt)) {
                String firebaseUid = jwtProvider.getUserNameFromJwtToken(jwt);

                UserDetails userDetails = userDetailsService.loadUserByUsername(firebaseUid);
                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        userDetails, null, userDetails.getAuthorities());
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception e) {
            // Cannot set user authentication
            logger.error("Cannot set user authentication: {}", e);
        }

        filterChain.doFilter(request, response);
    }

    private String parseJwt(HttpServletRequest request) {
        String headerAuth = request.getHeader("Authorization");

        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }

        return null;
    }
}
