package me.devziyad.unipoolbackend.user;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    boolean existsByEmail(String email);
    boolean existsByUniversityId(String universityId);
    Optional<User> findByEmail(String email);
}