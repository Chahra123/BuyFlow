package com.esprit.examen.repositories;

import com.esprit.examen.entities.CustomerOrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CustomerOrderItemRepository extends JpaRepository<CustomerOrderItem, Long> {
    boolean existsByProduit_IdProduit(Long idProduit);
}
