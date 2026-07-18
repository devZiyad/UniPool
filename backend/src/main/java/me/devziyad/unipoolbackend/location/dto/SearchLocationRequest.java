package me.devziyad.unipoolbackend.location.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SearchLocationRequest {
    @NotBlank(message = "Query is required")
    private String query;
}