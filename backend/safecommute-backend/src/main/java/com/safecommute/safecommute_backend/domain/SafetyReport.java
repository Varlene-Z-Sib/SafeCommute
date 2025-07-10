package com.safecommute.safecommute_backend.domain;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.index.GeoSpatialIndexType;
import org.springframework.data.mongodb.core.index.GeoSpatialIndexed;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Document(collection = "safety_reports")
public class SafetyReport {

    @Id
    private String id;

    @Field("user_id")
    private String userId;

    @Field("stop_id")
    private String stopId;

    @Field("incident_type")
    private String incidentType; // theft, harassment, assault, vandalism, other

    @Field("severity")
    private String severity; // low, medium, high, critical

    @Field("description")
    private String description;

    @Field("location")
    @GeoSpatialIndexed(type = GeoSpatialIndexType.GEO_2DSPHERE)
    private TransportStop.Location location;

    @Field("incident_time")
    private LocalDateTime incidentTime;

    @CreatedDate
    @Field("reported_at")
    private LocalDateTime reportedAt;

    @Field("status")
    private String status = "PENDING"; // PENDING, VERIFIED, DISMISSED

    @Field("upvotes")
    private int upvotes = 0;

    @Field("downvotes")
    private int downvotes = 0;

    @Field("is_anonymous")
    private boolean isAnonymous = false;

    @Field("image_url")
    private String imageUrl;
}