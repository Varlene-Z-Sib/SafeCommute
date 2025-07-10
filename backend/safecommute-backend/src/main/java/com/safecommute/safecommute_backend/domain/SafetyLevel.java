package com.safecommute.safecommute_backend.domain;

public enum SafetyLevel {
    GREEN("green"),
    YELLOW("yellow"), 
    ORANGE("orange"),
    RED("red");

    private final String value;

    SafetyLevel(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}