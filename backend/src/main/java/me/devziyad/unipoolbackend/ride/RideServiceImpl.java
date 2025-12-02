package me.devziyad.unipoolbackend.ride;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.exception.BusinessException;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.location.LocationRepository;
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

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
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

    private RideResponse toResponse(Ride ride) {
        return RideResponse.builder()
                .id(ride.getId())
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
                .departureTime(ride.getDepartureTime())
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

        if (request.getDepartureTime().isBefore(LocalDateTime.now())) {
            throw new BusinessException("Departure time must be in the future");
        }

        if (request.getTotalSeats() > vehicle.getSeatCount()) {
            throw new BusinessException("Total seats cannot exceed vehicle capacity");
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

        // Calculate pricing
        BigDecimal basePrice = request.getBasePrice();
        if (basePrice == null) {
            // Default pricing: 0.5 per km
            basePrice = BigDecimal.valueOf(routeInfo.getDistanceKm() * 0.5)
                    .setScale(2, RoundingMode.HALF_UP);
        }

        BigDecimal pricePerSeat = request.getPricePerSeat();
        if (pricePerSeat == null) {
            pricePerSeat = basePrice.divide(BigDecimal.valueOf(request.getTotalSeats()), 2, RoundingMode.HALF_UP);
        }

        Ride ride = Ride.builder()
                .driver(driver)
                .vehicle(vehicle)
                .pickupLocation(pickupLocation)
                .destinationLocation(destinationLocation)
                .departureTime(request.getDepartureTime())
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

        return toResponse(rideRepository.save(ride));
    }

    @Override
    public RideResponse getRideById(Long id) {
        Ride ride = rideRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));
        return toResponse(ride);
    }

    @Override
    public List<RideResponse> searchRides(SearchRidesRequest request) {
        List<Ride> rides = rideRepository.findAvailableRides(
                request.getMinAvailableSeats() != null ? request.getMinAvailableSeats() : 1,
                request.getDepartureTimeFrom() != null ? request.getDepartureTimeFrom() : LocalDateTime.now()
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
                    .filter(r -> r.getDepartureTime().isBefore(request.getDepartureTimeTo()))
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
                    rides.sort(Comparator.comparing(Ride::getDepartureTime));
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
    public List<RideResponse> getRidesByDriver(Long driverId) {
        return rideRepository.findByDriverId(driverId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
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

        if (request.getDepartureTime() != null) {
            if (request.getDepartureTime().isBefore(LocalDateTime.now())) {
                throw new BusinessException("Departure time must be in the future");
            }
            ride.setDepartureTime(request.getDepartureTime());
        }

        if (request.getTotalSeats() != null) {
            if (request.getTotalSeats() < ride.getTotalSeats() - ride.getAvailableSeats()) {
                throw new BusinessException("Cannot reduce seats below booked seats");
            }
            int bookedSeats = ride.getTotalSeats() - ride.getAvailableSeats();
            ride.setTotalSeats(request.getTotalSeats());
            ride.setAvailableSeats(request.getTotalSeats() - bookedSeats);
        }

        if (request.getBasePrice() != null) {
            ride.setBasePrice(request.getBasePrice());
            if (request.getPricePerSeat() == null) {
                ride.setPricePerSeat(ride.getBasePrice().divide(
                        BigDecimal.valueOf(ride.getTotalSeats()), 2, RoundingMode.HALF_UP));
            }
        }

        if (request.getPricePerSeat() != null) {
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
        return toResponse(rideRepository.save(ride));
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
    }

    @Override
    public Integer getAvailableSeats(Long id) {
        Ride ride = rideRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));
        return ride.getAvailableSeats();
    }
}

