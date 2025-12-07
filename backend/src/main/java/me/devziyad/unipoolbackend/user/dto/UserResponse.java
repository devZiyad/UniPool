package me.devziyad.unipoolbackend.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import me.devziyad.unipoolbackend.common.Role;

import java.math.BigDecimal;
import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    private Long id;
    private String universityId;
    private String email;
    private String fullName;
    private String phoneNumber;
    private Role role;
    private Boolean enabled;
    private Instant createdAt;
    private BigDecimal walletBalance;
    private BigDecimal avgRatingAsDriver;
    private Integer ratingCountAsDriver;
    private BigDecimal avgRatingAsRider;
    private Integer ratingCountAsRider;
}