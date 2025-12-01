package me.devziyad.springbootbackend.auth;

import me.devziyad.springbootbackend.auth.dto.AuthResponse;
import me.devziyad.springbootbackend.auth.dto.LoginRequest;
import me.devziyad.springbootbackend.auth.dto.RegisterRequest;
import me.devziyad.springbootbackend.user.User;

public interface AuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
    User getCurrentUser();
}

