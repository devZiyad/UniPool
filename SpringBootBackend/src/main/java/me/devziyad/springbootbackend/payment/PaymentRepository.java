package me.devziyad.springbootbackend.payment;

import me.devziyad.springbootbackend.payment.Payment;
import me.devziyad.springbootbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PaymentRepository extends JpaRepository<Payment, Long> {

    List<Payment> findByPayer(User payer);

    List<Payment> findByBookingId(Long bookingId);

    List<Payment> findByPayerId(Long payerId);
}