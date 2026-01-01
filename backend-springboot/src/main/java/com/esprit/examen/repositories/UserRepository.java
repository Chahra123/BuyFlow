package com.esprit.examen.repositories;

import com.esprit.examen.entities.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    @Query("SELECT CASE WHEN COUNT(u) > 0 THEN true ELSE false END FROM User u WHERE u.email = :email AND u.deleted = false")
    boolean existsByEmail(String email);

    // Optional: for verification token
    Optional<User> findByVerificationToken(String verificationToken);
    
    @Query("SELECT u FROM User u WHERE u.deleted = false AND (LOWER(u.firstName) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(u.lastName) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(u.email) LIKE LOWER(CONCAT('%', :query, '%')))")
    Page<User> searchUsers(String query, Pageable pageable);

    long countByEnabledTrue();
    long countByRole(com.esprit.examen.entities.Role role);
    long countByCreatedAtAfter(java.time.LocalDateTime date);
}
