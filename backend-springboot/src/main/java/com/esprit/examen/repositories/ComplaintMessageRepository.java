package com.esprit.examen.repositories;

import com.esprit.examen.entities.Complaint;
import com.esprit.examen.entities.ComplaintMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ComplaintMessageRepository extends JpaRepository<ComplaintMessage, Long> {
    List<ComplaintMessage> findByComplaintOrderBySentAtAsc(Complaint complaint);
}
