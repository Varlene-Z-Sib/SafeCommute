package com.safecommute.safecommute_backend.domain;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.index.Indexed;

import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Document(collection = "real_time_alerts")
public class RealTimeAlert {

    @Id
    private String id;

    @Field("stop_id")
    private String stopId;

    @Field("alert_type")
    private String alertType; // SAFETY_INCIDENT, TRANSPORT_DELAY, WEATHER, MAINTENANCE

    @Field("message")
    private String message;

    @Field("severity")
    private String severity; // LOW, MEDIUM, HIGH, CRITICAL

    @Field("expires_at")
    @Indexed(expireAfterSeconds = 0)
    private LocalDateTime expiresAt;

    @CreatedDate
    @Field("created_at")
    private LocalDateTime createdAt;

    @Field("is_active")
    private boolean isActive = true;

    @Field("affected_area")
    private AffectedArea affectedArea;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AffectedArea {
        @Field("center_lat")
        private double centerLat;

        @Field("center_lng")
        private double centerLng;

        @Field("radius")
        private double radius; // in meters

        @Field("affected_stops")
        private List<String> affectedStops = new ArrayList<>();
    }
}