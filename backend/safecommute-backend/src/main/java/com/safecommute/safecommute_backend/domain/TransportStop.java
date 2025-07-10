package com.safecommute.safecommute_backend.domain;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.index.GeoSpatialIndexType;
import org.springframework.data.mongodb.core.index.GeoSpatialIndexed;

import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Document(collection = "transport_stops")
public class TransportStop {

    @Id
    private String id;

    @Field("stop_id")
    @Indexed(unique = true)
    private String stopId;

    @Field("name")
    private String name;

    @Field("type")
    private String type; // taxi, bus, train

    @Field("location")
    @GeoSpatialIndexed(type = GeoSpatialIndexType.GEO_2DSPHERE)
    private Location location;

    @Field("safety_level")
    private String safetyLevel; // green, yellow, orange, red

    @Field("recent_reports_count")
    private int recentReportsCount = 0;

    @Field("average_rating")
    private double averageRating = 0.0;

    @Field("operating_hours")
    private List<String> operatingHours = new ArrayList<>();

    @CreatedDate
    @Field("created_at")
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Field("updated_at")
    private LocalDateTime updatedAt;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Location {
        @Field("latitude")
        private double latitude;

        @Field("longitude")
        private double longitude;

        @Field("address")
        private String address;

        @Field("type")
        private String type = "Point";

        @Field("coordinates")
        private double[] coordinates; // [longitude, latitude] for GeoJSON
    }
}
