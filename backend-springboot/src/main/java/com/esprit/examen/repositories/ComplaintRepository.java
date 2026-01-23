package com.esprit.examen.repositories;

import com.esprit.examen.entities.Complaint;
import com.esprit.examen.entities.CustomerOrder;
import com.esprit.examen.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ComplaintRepository extends JpaRepository<Complaint, Long> {
    List<Complaint> findByUserOrderByCreatedAtDesc(User user);
    List<Complaint> findByOrderOrderByCreatedAtDesc(CustomerOrder order);
}
