package com.redbank.donor.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.locationtech.jts.geom.Point;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;

class LocationServiceTest {

    private LocationService locationService;

    @BeforeEach
    void setUp() {
        locationService = new LocationService();
    }

    @Test
    void testCreatePoint_Success() {
        BigDecimal lat = new BigDecimal("12.9716");
        BigDecimal lng = new BigDecimal("77.5946");
        
        Point point = locationService.createPoint(lat, lng);
        
        assertNotNull(point);
        assertEquals(4326, point.getSRID());
        assertEquals(77.5946, point.getX(), 0.0001); // X is longitude
        assertEquals(12.9716, point.getY(), 0.0001); // Y is latitude
    }

    @Test
    void testCreatePoint_NullInputs() {
        assertNull(locationService.createPoint(null, new BigDecimal("77.5946")));
        assertNull(locationService.createPoint(new BigDecimal("12.9716"), null));
    }
}
