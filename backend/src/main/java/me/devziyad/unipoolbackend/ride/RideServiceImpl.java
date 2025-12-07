package me.devziyad.unipoolbackend.ride;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.audit.ActionType;
import me.devziyad.unipoolbackend.audit.AuditService;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.exception.BusinessException;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.location.LocationRepository;
import me.devziyad.unipoolbackend.booking.Booking;
import me.devziyad.unipoolbackend.booking.dto.BookingResponse;
import me.devziyad.unipoolbackend.ride.dto.*;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import me.devziyad.unipoolbackend.util.DistanceUtil;
import me.devziyad.unipoolbackend.util.RoutingService;
import me.devziyad.unipoolbackend.util.RoutingService.RouteInfo;
import me.devziyad.unipoolbackend.vehicle.Vehicle;
import me.devziyad.unipoolbackend.vehicle.VehicleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RideServiceImpl implements RideService {

    private final RideRepository rideRepository;
    private final VehicleRepository vehicleRepository;
    private final LocationRepository locationRepository;
    private final UserRepository userRepository;
    private final RoutingService routingService;
    private final AuditService auditService;

    private HttpServletRequest getCurrentRequest() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        return attributes != null ? attributes.getRequest() : null;
    }

    private RideResponse toResponse(Ride ride) {
        // Map bookings to BookingResponse
        List<BookingResponse> bookings = new ArrayList<>();
        if (ride.getBookings() != null && !ride.getBookings().isEmpty()) {
            bookings = ride.getBookings().stream()
                    .map(this::toBookingResponse)
                    .collect(Collectors.toList());
        }

        return RideResponse.builder()
                .rideId(ride.getId())
                .driverId(ride.getDriver().getId())
                .driverName(ride.getDriver().getFullName())
                .driverRating(ride.getDriver().getAvgRatingAsDriver())
                .vehicleId(ride.getVehicle().getId())
                .vehicleMake(ride.getVehicle().getMake())
                .vehicleModel(ride.getVehicle().getModel())
                .vehiclePlateNumber(ride.getVehicle().getPlateNumber())
                .vehicleSeatCount(ride.getVehicle().getSeatCount())
                .pickupLocationId(ride.getPickupLocation().getId())
                .pickupLocationLabel(ride.getPickupLocation().getLabel())
                .pickupLatitude(ride.getPickupLocation().getLatitude())
                .pickupLongitude(ride.getPickupLocation().getLongitude())
                .destinationLocationId(ride.getDestinationLocation().getId())
                .destinationLocationLabel(ride.getDestinationLocation().getLabel())
                .destinationLatitude(ride.getDestinationLocation().getLatitude())
                .destinationLongitude(ride.getDestinationLocation().getLongitude())
                .departureTimeStart(ride.getDepartureTimeStart())
                .departureTimeEnd(ride.getDepartureTimeEnd())
                .totalSeats(ride.getTotalSeats())
                .availableSeats(ride.getAvailableSeats())
                .estimatedDistanceKm(ride.getEstimatedDistanceKm())
                .routeDistanceKm(ride.getRouteDistanceKm())
                .estimatedDurationMinutes(ride.getEstimatedDurationMinutes())
                .basePrice(ride.getBasePrice())
                .pricePerSeat(ride.getPricePerSeat())
                .status(ride.getStatus())
                .createdAt(ride.getCreatedAt())
                .routePolyline(ride.getRoutePolyline())
                .bookings(bookings)
                .build();
    }

    private BookingResponse toBookingResponse(Booking booking) {
        return BookingResponse.builder()
                .bookingId(booking.getId())
                .passengerId(booking.getRider().getId())
                .passengerName(booking.getRider().getFullName())
                .seatsBooked(booking.getSeatsBooked())
                .pickupLocationId(booking.getPickupLocation().getId())
                .pickupLocationLabel(booking.getPickupLocation().getLabel())
                .pickupLatitude(booking.getPickupLocation().getLatitude())
                .pickupLongitude(booking.getPickupLocation().getLongitude())
                .dropoffLocationId(booking.getDropoffLocation().getId())
                .dropoffLocationLabel(booking.getDropoffLocation().getLabel())
                .dropoffLatitude(booking.getDropoffLocation().getLatitude())
                .dropoffLongitude(booking.getDropoffLocation().getLongitude())
                .pickupTimeStart(booking.getPickupTimeStart())
                .pickupTimeEnd(booking.getPickupTimeEnd())
                .createdAt(booking.getCreatedAt())
                .status(booking.getStatus())
                .costForThisRider(booking.getCostForThisRider())
                .cancelledAt(booking.getCancelledAt())
                .build();
    }

    @Override
    @Transactional
    public RideResponse createRide(CreateRideRequest request, Long driverId) {
        User driver = userRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException("Driver not found"));

        Vehicle vehicle = vehicleRepository.findById(request.getVehicleId())
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found"));

        if (!vehicle.getOwner().getId().equals(driverId)) {
            throw new ForbiddenException("You can only use your own vehicles");
        }

        if (!vehicle.getActive()) {
            throw new BusinessException("Vehicle is not active");
        }

        Location pickupLocation = locationRepository.findById(request.getPickupLocationId())
                .orElseThrow(() -> new ResourceNotFoundException("Pickup location not found"));

        Location destinationLocation = locationRepository.findById(request.getDestinationLocationId())
                .orElseThrow(() -> new ResourceNotFoundException("Destination location not found"));

        // Validate coordinates
        if (pickupLocation.getLatitude() < -90 || pickupLocation.getLatitude() > 90 ||
            pickupLocation.getLongitude() < -180 || pickupLocation.getLongitude() > 180) {
            throw new BusinessException("Invalid pickup location coordinates");
        }

        if (destinationLocation.getLatitude() < -90 || destinationLocation.getLatitude() > 90 ||
            destinationLocation.getLongitude() < -180 || destinationLocation.getLongitude() > 180) {
            throw new BusinessException("Invalid destination location coordinates");
        }

        // Validation is handled in the time range validation below

        // Validate departure time range
        if (request.getDepartureTimeStart().isAfter(request.getDepartureTimeEnd())) {
            throw new BusinessException("Departure time start must be before departure time end");
        }

        if (request.getDepartureTimeStart().isBefore(Instant.now())) {
            throw new BusinessException("Departure time start must be in the future");
        }

        if (request.getDepartureTimeEnd().isAfter(Instant.now().plusSeconds(365L * 24 * 60 * 60))) {
            throw new BusinessException("Departure time end cannot be more than 1 year in the future");
        }

        // Validate time range is reasonable (not more than 24 hours)
        long hoursBetween = java.time.Duration.between(request.getDepartureTimeStart(), request.getDepartureTimeEnd()).toHours();
        if (hoursBetween > 24) {
            throw new BusinessException("Departure time range cannot exceed 24 hours");
        }

        if (request.getTotalSeats() > vehicle.getSeatCount()) {
            throw new BusinessException("Total seats cannot exceed vehicle capacity");
        }

        if (request.getTotalSeats() < 1) {
            throw new BusinessException("Total seats must be at least 1");
        }

        // Calculate distance and route
        double haversineDistance = DistanceUtil.haversineDistance(
                pickupLocation.getLatitude(), pickupLocation.getLongitude(),
                destinationLocation.getLatitude(), destinationLocation.getLongitude()
        );

        RouteInfo routeInfo = routingService.getRouteInfo(
                pickupLocation.getLatitude(), pickupLocation.getLongitude(),
                destinationLocation.getLatitude(), destinationLocation.getLongitude()
        );

        // Validate distance is reasonable (not negative or unrealistic)
        if (routeInfo.getDistanceKm() < 0) {
            throw new BusinessException("Invalid route distance");
        }
        if (routeInfo.getDistanceKm() > 10000) { // 10,000 km max
            throw new BusinessException("Route distance exceeds maximum allowed distance");
        }

        // Calculate pricing
        BigDecimal basePrice = request.getBasePrice();
        if (basePrice == null) {
            // Default pricing: 0.5 per km
            basePrice = BigDecimal.valueOf(routeInfo.getDistanceKm() * 0.5)
                    .setScale(2, RoundingMode.HALF_UP);
        } else {
            // Validate provided price is positive and reasonable
            if (basePrice.compareTo(BigDecimal.ZERO) <= 0) {
                throw new BusinessException("Base price must be positive");
            }
            if (basePrice.compareTo(BigDecimal.valueOf(10000)) > 0) {
                throw new BusinessException("Base price cannot exceed 10000.00");
            }
        }

        BigDecimal pricePerSeat = request.getPricePerSeat();
        if (pricePerSeat == null) {
            pricePerSeat = basePrice.divide(BigDecimal.valueOf(request.getTotalSeats()), 2, RoundingMode.HALF_UP);
        } else {
            // Validate provided price per seat is positive and reasonable
            if (pricePerSeat.compareTo(BigDecimal.ZERO) <= 0) {
                throw new BusinessException("Price per seat must be positive");
            }
            if (pricePerSeat.compareTo(BigDecimal.valueOf(5000)) > 0) {
                throw new BusinessException("Price per seat cannot exceed 5000.00");
            }
        }

        // Check for overlapping departure times with existing active rides
        List<Ride> activeRides = rideRepository.findActiveRidesByDriver(driverId);
        Instant newDepartureTimeStart = request.getDepartureTimeStart();
        Instant newDepartureTimeEnd = request.getDepartureTimeEnd();
        int newEstimatedDuration = routeInfo.getDurationMinutes();
        Instant newEndTime = newDepartureTimeEnd.plusSeconds(newEstimatedDuration * 60L);

        for (Ride existingRide : activeRides) {
            Instant existingDepartureTimeStart = existingRide.getDepartureTimeStart();
            Instant existingDepartureTimeEnd = existingRide.getDepartureTimeEnd();
            Instant existingEndTime = existingDepartureTimeEnd.plusSeconds(existingRide.getEstimatedDurationMinutes() * 60L);

            // Check if time ranges overlap
            // Two time ranges overlap if: newStart < existingEnd AND newEnd > existingStart
            if (newDepartureTimeStart.isBefore(existingEndTime) && newEndTime.isAfter(existingDepartureTimeStart)) {
                throw new BusinessException("Cannot create ride with overlapping departure time. You have another active ride scheduled during this time period.");
            }
        }

        Ride ride = Ride.builder()
                .driver(driver)
                .vehicle(vehicle)
                .pickupLocation(pickupLocation)
                .destinationLocation(destinationLocation)
                .departureTimeStart(request.getDepartureTimeStart())
                .departureTimeEnd(request.getDepartureTimeEnd())
                .totalSeats(request.getTotalSeats())
                .availableSeats(request.getTotalSeats())
                .estimatedDistanceKm(haversineDistance)
                .routeDistanceKm(routeInfo.getDistanceKm())
                .estimatedDurationMinutes(routeInfo.getDurationMinutes())
                .basePrice(basePrice)
                .pricePerSeat(pricePerSeat)
                .status(RideStatus.POSTED)
                .routePolyline(routeInfo.getPolyline())
                .build();

        ride = rideRepository.save(ride);

        // Audit log
        java.util.Map<String, Object> metadata = new java.util.HashMap<>();
        metadata.put("rideId", ride.getId());
        metadata.put("vehicleId", vehicle.getId());
        metadata.put("departureTimeStart", request.getDepartureTimeStart().toString());
        metadata.put("departureTimeEnd", request.getDepartureTimeEnd().toString());
        auditService.logAction(ActionType.RIDE_CREATE, driverId, metadata, getCurrentRequest());

        return toResponse(ride);
    }

    @Override
    @Transactional(readOnly = true)
    public RideResponse getRideById(Long id) {
        Ride ride = rideRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));
        // Initialize bookings if lazy loaded
        if (ride.getBookings() != null) {
            ride.getBookings().size(); // Force initialization
        }
        return toResponse(ride);
    }

    @Override
    @Transactional(readOnly = true)
    public List<RideResponse> searchRides(SearchRidesRequest request) {
        List<Ride> rides = rideRepository.findAvailableRidesWithBookings(
                request.getMinAvailableSeats() != null ? request.getMinAvailableSeats() : 1,
                request.getDepartureTimeFrom() != null ? request.getDepartureTimeFrom() : Instant.now()
        );

        // Filter by pickup location
        if (request.getPickupLocationId() != null) {
            rides = rides.stream()
                    .filter(r -> r.getPickupLocation().getId().equals(request.getPickupLocationId()))
                    .collect(Collectors.toList());
        } else if (request.getPickupLatitude() != null && request.getPickupLongitude() != null) {
            double radius = request.getPickupRadiusKm() != null ? request.getPickupRadiusKm() : 5.0;
            rides = rides.stream()
                    .filter(r -> DistanceUtil.isWithinRadius(
                            request.getPickupLatitude(), request.getPickupLongitude(),
                            r.getPickupLocation().getLatitude(), r.getPickupLocation().getLongitude(),
                            radius))
                    .collect(Collectors.toList());
        }

        // Filter by destination location
        if (request.getDestinationLocationId() != null) {
            rides = rides.stream()
                    .filter(r -> r.getDestinationLocation().getId().equals(request.getDestinationLocationId()))
                    .collect(Collectors.toList());
        } else if (request.getDestinationLatitude() != null && request.getDestinationLongitude() != null) {
            double radius = request.getDestinationRadiusKm() != null ? request.getDestinationRadiusKm() : 5.0;
            rides = rides.stream()
                    .filter(r -> DistanceUtil.isWithinRadius(
                            request.getDestinationLatitude(), request.getDestinationLongitude(),
                            r.getDestinationLocation().getLatitude(), r.getDestinationLocation().getLongitude(),
                            radius))
                    .collect(Collectors.toList());
        }

        // Filter by time window
        if (request.getDepartureTimeTo() != null) {
            rides = rides.stream()
                    .filter(r -> r.getDepartureTimeStart().isBefore(request.getDepartureTimeTo()))
                    .collect(Collectors.toList());
        }

        // Filter by price
        if (request.getMaxPrice() != null) {
            rides = rides.stream()
                    .filter(r -> r.getPricePerSeat().compareTo(request.getMaxPrice()) <= 0)
                    .collect(Collectors.toList());
        }

        // Sort
        if (request.getSortBy() != null) {
            switch (request.getSortBy().toLowerCase()) {
                case "price":
                    rides.sort(Comparator.comparing(Ride::getPricePerSeat));
                    break;
                case "departuretime":
                    rides.sort(Comparator.comparing(Ride::getDepartureTimeStart));
                    break;
                case "distance":
                default:
                    // Already sorted by relevance
                    break;
            }
        }

        return rides.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<RideResponse> getRidesByDriver(Long driverId) {
        return rideRepository.findByDriverIdWithBookings(driverId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<RideResponse> getMyRidesAsDriver(Long driverId) {
        return getRidesByDriver(driverId);
    }

    @Override
    @Transactional
    public RideResponse updateRide(Long id, UpdateRideRequest request, Long driverId) {
        Ride ride = rideRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));

        if (!ride.getDriver().getId().equals(driverId)) {
            throw new ForbiddenException("You can only update your own rides");
        }

        if (ride.getStatus() != RideStatus.POSTED) {
            throw new BusinessException("Cannot update ride that is not in POSTED status");
        }

        if (request.getPickupLocationId() != null) {
            Location location = locationRepository.findById(request.getPickupLocationId())
                    .orElseThrow(() -> new ResourceNotFoundException("Pickup location not found"));
            ride.setPickupLocation(location);
        }

        if (request.getDestinationLocationId() != null) {
            Location location = locationRepository.findById(request.getDestinationLocationId())
                    .orElseThrow(() -> new ResourceNotFoundException("Destination location not found"));
            ride.setDestinationLocation(location);
        }

        if (request.getPickupLocationId() != null) {
            Location location = locationRepository.findById(request.getPickupLocationId())
                    .orElseThrow(() -> new ResourceNotFoundException("Pickup location not found"));
            // Validate coordinates
            if (location.getLatitude() < -90 || location.getLatitude() > 90 ||
                location.getLongitude() < -180 || location.getLongitude() > 180) {
                throw new BusinessException("Invalid pickup location coordinates");
            }
            ride.setPickupLocation(location);
        }

        if (request.getDestinationLocationId() != null) {
            Location location = locationRepository.findById(request.getDestinationLocationId())
                    .orElseThrow(() -> new ResourceNotFoundException("Destination location not found"));
            // Validate coordinates
            if (location.getLatitude() < -90 || location.getLatitude() > 90 ||
                location.getLongitude() < -180 || location.getLongitude() > 180) {
                throw new BusinessException("Invalid destination location coordinates");
            }
            ride.setDestinationLocation(location);
        }

        // Departure time range update is handled above

        if (request.getTotalSeats() != null) {
            if (request.getTotalSeats() < 1) {
                throw new BusinessException("Total seats must be at least 1");
            }
            if (request.getTotalSeats() > ride.getVehicle().getSeatCount()) {
                throw new BusinessException("Total seats cannot exceed vehicle capacity");
            }
            if (request.getTotalSeats() < ride.getTotalSeats() - ride.getAvailableSeats()) {
                throw new BusinessException("Cannot reduce seats below booked seats");
            }
            int bookedSeats = ride.getTotalSeats() - ride.getAvailableSeats();
            ride.setTotalSeats(request.getTotalSeats());
            ride.setAvailableSeats(request.getTotalSeats() - bookedSeats);
        }

        if (request.getBasePrice() != null) {
            if (request.getBasePrice().compareTo(BigDecimal.ZERO) <= 0) {
                throw new BusinessException("Base price must be positive");
            }
            if (request.getBasePrice().compareTo(BigDecimal.valueOf(10000)) > 0) {
                throw new BusinessException("Base price cannot exceed 10000.00");
            }
            ride.setBasePrice(request.getBasePrice());
            if (request.getPricePerSeat() == null) {
                ride.setPricePerSeat(ride.getBasePrice().divide(
                        BigDecimal.valueOf(ride.getTotalSeats()), 2, RoundingMode.HALF_UP));
            }
        }

        if (request.getPricePerSeat() != null) {
            if (request.getPricePerSeat().compareTo(BigDecimal.ZERO) <= 0) {
                throw new BusinessException("Price per seat must be positive");
            }
            if (request.getPricePerSeat().compareTo(BigDecimal.valueOf(5000)) > 0) {
                throw new BusinessException("Price per seat cannot exceed 5000.00");
            }
            ride.setPricePerSeat(request.getPricePerSeat());
        }

        // Recalculate route if locations changed
        if (request.getPickupLocationId() != null || request.getDestinationLocationId() != null) {
            RouteInfo routeInfo = routingService.getRouteInfo(
                    ride.getPickupLocation().getLatitude(), ride.getPickupLocation().getLongitude(),
                    ride.getDestinationLocation().getLatitude(), ride.getDestinationLocation().getLongitude()
            );
            ride.setRouteDistanceKm(routeInfo.getDistanceKm());
            ride.setEstimatedDurationMinutes(routeInfo.getDurationMinutes());
            ride.setRoutePolyline(routeInfo.getPolyline());
        }

        return toResponse(rideRepository.save(ride));
    }

    @Override
    @Transactional
    public RideResponse updateRideStatus(Long id, RideStatus status, Long driverId) {
        Ride ride = rideRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));

        if (!ride.getDriver().getId().equals(driverId)) {
            throw new ForbiddenException("You can only update your own rides");
        }

        // Validate status transitions
        if (ride.getStatus() == RideStatus.COMPLETED || ride.getStatus() == RideStatus.CANCELLED) {
            throw new BusinessException("Cannot change status of completed or cancelled ride");
        }

        ride.setStatus(status);
        ride = rideRepository.save(ride);

        // Audit log
        java.util.Map<String, Object> metadata = new java.util.HashMap<>();
        metadata.put("rideId", ride.getId());
        metadata.put("status", status.name());
        auditService.logAction(ActionType.RIDE_UPDATE, driverId, metadata, getCurrentRequest());

        return toResponse(ride);
    }

    @Override
    @Transactional
    public void cancelRide(Long id, Long driverId) {
        Ride ride = rideRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));

        if (!ride.getDriver().getId().equals(driverId)) {
            throw new ForbiddenException("You can only cancel your own rides");
        }

        if (ride.getStatus() == RideStatus.COMPLETED) {
            throw new BusinessException("Cannot cancel completed ride");
        }

        ride.setStatus(RideStatus.CANCELLED);
        rideRepository.save(ride);

        // Audit log
        java.util.Map<String, Object> metadata = new java.util.HashMap<>();
        metadata.put("rideId", ride.getId());
        auditService.logAction(ActionType.RIDE_CANCEL, driverId, metadata, getCurrentRequest());
    }

    @Override
    public Integer getAvailableSeats(Long id) {
        Ride ride = rideRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));
        return ride.getAvailableSeats();
    }
}

