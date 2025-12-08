package me.devziyad.unipoolbackend.user;

import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<@NonNull User, @NonNull Long> {
    boolean existsByEmail(String email);
    boolean existsByUniversityId(String universityId);
    Optional<User> findByEmail(String email);
    boolean existsByPhoneNumberAndIdNot(String phoneNumber, Long id);
    Optional<User> findByPhoneNumber(String phoneNumber);
}