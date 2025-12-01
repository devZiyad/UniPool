package me.devziyad.springbootbackend.location;

import me.devziyad.springbootbackend.location.Location;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LocationRepository extends JpaRepository<Location, Long> {
}