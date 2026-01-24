package com.esprit.examen.repositories;

import com.esprit.examen.entities.CustomerOrder;
import com.esprit.examen.entities.OrderStatus;
import com.esprit.examen.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CustomerOrderRepository extends JpaRepository<CustomerOrder, Long> {
    List<CustomerOrder> findByUserOrderByCreatedAtDesc(User user);

    List<CustomerOrder> findByAssignedCourierAndStatusInOrderByUpdatedAtDesc(User courier, List<OrderStatus> statuses);

    List<CustomerOrder> findAllByOrderByCreatedAtDesc();
}
