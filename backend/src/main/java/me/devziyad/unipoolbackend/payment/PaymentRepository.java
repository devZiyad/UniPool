package me.devziyad.unipoolbackend.payment;

import lombok.NonNull;
import me.devziyad.unipoolbackend.common.PaymentStatus;
import me.devziyad.unipoolbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface PaymentRepository extends JpaRepository<@NonNull Payment, @NonNull Long> {

    @NonNull
    List<@NonNull Payment> findByPayer(User payer);

    @NonNull
    List<@NonNull Payment> findByBookingId(Long bookingId);

    @NonNull
    List<@NonNull Payment> findByPayerId(Long payerId);

    @NonNull
    List<@NonNull Payment> findByDriverId(Long driverId);

    @NonNull
    List<@NonNull Payment> findByStatus(PaymentStatus status);

    @Query("SELECT SUM(p.driverEarnings) FROM Payment p WHERE p.driver.id = :driverId AND p.status = 'SETTLED'")
    @NonNull
    BigDecimal getTotalEarningsByDriverId(@Param("driverId") Long driverId);
}