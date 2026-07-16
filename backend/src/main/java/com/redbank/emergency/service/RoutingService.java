package com.redbank.emergency.service;

public interface RoutingService {
    /**
     * Calculates the estimated travel time in minutes between two geographic points.
     * @param originLat Latitude of the origin
     * @param originLng Longitude of the origin
     * @param destLat Latitude of the destination
     * @param destLng Longitude of the destination
     * @return Estimated travel time in minutes
     */
    int calculateEstimatedTravelTimeMins(double originLat, double originLng, double destLat, double destLng);
}
