package me.devziyad.unipoolbackend.auth;

import me.devziyad.unipoolbackend.auth.dto.AuthResponse;
import me.devziyad.unipoolbackend.auth.dto.LoginRequest;
import me.devziyad.unipoolbackend.auth.dto.RegisterRequest;
import me.devziyad.unipoolbackend.user.User;

public interface AuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
    User getCurrentUser();
}