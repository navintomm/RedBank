package com.redbank.core.constants;

public final class AppConstants {
    
    private AppConstants() {
        // Prevent instantiation
    }

    public static final String API_V1_PREFIX = "/api/v1";
    
    // Spatial Matching
    public static final int MATCH_RADIUS_CRITICAL_KM = 5;
    public static final int MATCH_RADIUS_HIGH_KM = 15;
    
    // Auth
    public static final String ROLE_DONOR = "ROLE_DONOR";
    public static final String ROLE_REQUESTER = "ROLE_REQUESTER";
    public static final String ROLE_ADMIN = "ROLE_ADMIN";
}
