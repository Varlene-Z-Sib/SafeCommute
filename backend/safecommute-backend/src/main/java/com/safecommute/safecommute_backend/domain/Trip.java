package com.safecommute.safecommute_backend.domain;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Document(collection = "trips")
public class Trip {

    @Id
    private String id;

    @Field("user_id")
    private String userId;

    @Field("start_stop_id")
    private String startStopId;

    @Field("end_stop_id")
    private String endStopId;

    @Field("start_time")
    private LocalDateTime startTime;

    @Field("end_time")
    private LocalDateTime endTime;

    @Field("status")
    private String status = "PLANNED"; // PLANNED, IN_PROGRESS, COMPLETED, CANCELLED

    @Field("safety_score")
    private double safetyScore = 0.0;

    @Field("rating")
    private int rating; // 1-5 stars

    @Field("feedback")
    private String feedback;

    @Field("route_taken")
    private List<RouteStep> routeTaken = new ArrayList<>();

    @CreatedDate
    @Field("created_at")
    private LocalDateTime createdAt;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RouteStep {
        @Field("stop_id")
        private String stopId;

        @Field("transport_type")
        private String transportType;

        @Field("departure_time")
        private LocalDateTime departureTime;

        @Field("arrival_time")
        private LocalDateTime arrivalTime;

        @Field("safety_score")
        private double safetyScore;
    }
}