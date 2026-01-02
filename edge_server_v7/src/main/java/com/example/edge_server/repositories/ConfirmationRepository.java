package com.example.edge_server.repositories;

import com.example.edge_server.entites.Confirmation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ConfirmationRepository extends JpaRepository<Confirmation, Long> {

    Optional<Confirmation> findByEventId(Long eventId);

    boolean existsByEventId(Long eventId);

    Optional<Confirmation> findByClientIdAndEventId(Long clientId, Long eventId);
    List<Confirmation> findByClientId(Long clientId);

}
