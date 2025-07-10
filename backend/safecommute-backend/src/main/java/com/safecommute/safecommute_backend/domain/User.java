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

import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

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

import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Document(collection = "users")
public class User {

    @Id
    private String id;

    @Field("email")
    @Indexed(unique = true)
    private String email;

    @Field("name")
    private String name;

    @Field("phone")
    private String phone;

    @Field("gender")
    private String gender;

    @Field("emergency_contacts")
    private List<EmergencyContact> emergencyContacts = new ArrayList<>();

    @Field("preferences")
    private UserPreferences preferences;

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
    public static class EmergencyContact {
        @Field("name")
        private String name;

        @Field("phone")
        private String phone;

        @Field("email")
        private String email;

        @Field("relationship")
        private String relationship;

        @Field("is_primary")
        private boolean isPrimary;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class UserPreferences {
        @Field("safety_alerts_enabled")
        private boolean safetyAlertsEnabled = true;

        @Field("emergency_sharing_enabled")
        private boolean emergencySharingEnabled = true;

        @Field("preferred_transport_types")
        private List<String> preferredTransportTypes = new ArrayList<>();

        @Field("max_walking_distance")
        private int maxWalkingDistance = 500; // meters

        @Field("notification_settings")
        private String notificationSettings = "ALL";
    }
}