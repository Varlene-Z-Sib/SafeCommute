package com.safecommute.safecommute_backend.domain.enumns;

public enum TransportType {
    TAXI("taxi"),
    BUS("bus"),
    TRAIN("train"),
    WALKING("walking");

    private final String value;

    TransportType(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}