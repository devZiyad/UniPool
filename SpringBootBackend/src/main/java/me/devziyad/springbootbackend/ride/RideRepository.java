package me.devziyad.springbootbackend.ride;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface RideRepository extends JpaRepository<Ride, Long> {

    List<Ride> findByDepartureTimeBetween(LocalDateTime from, LocalDateTime to);

    // later you can add queries with location filters
}