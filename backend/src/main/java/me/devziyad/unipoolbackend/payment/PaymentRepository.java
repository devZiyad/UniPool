package me.devziyad.unipoolbackend.payment;

import me.devziyad.unipoolbackend.common.PaymentStatus;
import me.devziyad.unipoolbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;

public interface PaymentRepository extends JpaRepository<Payment, Long> {

    List<Payment> findByPayer(User payer);

    List<Payment> findByBookingId(Long bookingId);

    List<Payment> findByPayerId(Long payerId);

    List<Payment> findByDriverId(Long driverId);

    List<Payment> findByStatus(PaymentStatus status);

    @Query("SELECT SUM(p.driverEarnings) FROM Payment p WHERE p.driver.id = :driverId AND p.status = 'SETTLED'")
    BigDecimal getTotalEarningsByDriverId(@Param("driverId") Long driverId);
}