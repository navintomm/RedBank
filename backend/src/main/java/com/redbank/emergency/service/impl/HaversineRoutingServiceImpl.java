package com.redbank.emergency.service.impl;

import com.redbank.emergency.service.RoutingService;
import org.springframework.stereotype.Service;

@Service
public class HaversineRoutingServiceImpl implements RoutingService {

    private static final double AVERAGE_URBAN_SPEED_KMH = 30.0;
    private static final double EARTH_RADIUS_KM = 6371.0;

    @Override
    public int calculateEstimatedTravelTimeMins(double originLat, double originLng, double destLat, double destLng) {
        double dLat = Math.toRadians(destLat - originLat);
        double dLng = Math.toRadians(destLng - originLng);
        
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(originLat)) * Math.cos(Math.toRadians(destLat)) *
                   Math.sin(dLng / 2) * Math.sin(dLng / 2);
                   
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distanceKm = EARTH_RADIUS_KM * c;

        // Apply a routing detour factor (straight line is shorter than roads)
        double routeDistanceKm = distanceKm * 1.3;

        // Time = Distance / Speed
        double timeHours = routeDistanceKm / AVERAGE_URBAN_SPEED_KMH;
        int timeMins = (int) Math.round(timeHours * 60);

        // Minimum 5 minutes if very close
        return Math.max(5, timeMins);
    }
}
