package me.devziyad.unipoolbackend.auth;

import jakarta.servlet.http.HttpServletRequest;
import me.devziyad.unipoolbackend.auth.dto.AuthResponse;
import me.devziyad.unipoolbackend.auth.dto.LoginRequest;
import me.devziyad.unipoolbackend.auth.dto.RegisterRequest;
import me.devziyad.unipoolbackend.user.User;

public interface AuthService {
    AuthResponse register(RegisterRequest request, HttpServletRequest httpRequest);
    AuthResponse login(LoginRequest request, HttpServletRequest httpRequest);
    void logout(String token, Long userId, HttpServletRequest request);
    User getCurrentUser();
}