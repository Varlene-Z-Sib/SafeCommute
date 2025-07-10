package com.safecommute.safecommute_backend.domain.enumns;

public enum Severity {
    LOW("low"),
    MEDIUM("medium"),
    HIGH("high"),
    CRITICAL("critical");

    private final String value;

    Severity(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}