package com.example.edge_server.repositories;

import com.example.edge_server.entites.Category;
import com.example.edge_server.entites.Event;
import com.example.edge_server.entites.EventStatus;
import com.example.edge_server.entites.Useer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {

    @Query("SELECT e FROM Event e WHERE e.eventTime > CURRENT_TIMESTAMP AND e.id NOT IN " +
            "(SELECT c.event.id FROM Confirmation c WHERE c.client.id = :clientId AND c.status = true)")
    List<Event> findUpcomingEventsForClient(@Param("clientId") Long clientId);
    Page<Event> findByTitleContainingIgnoreCase(String title, Pageable pageable);

    List<Event> findByEventTimeBetweenAndLocation_Zone(
            LocalDateTime startDate,
            LocalDateTime endDate,
            String zone);
    Page<Event> findAll(Pageable pageable);
    Page<Event> findByExpirationTimeAfter(LocalDateTime now, Pageable pageable);
    boolean existsByTitle(String title);

    List<Event> findByExpirationTimeAfterAndStatus(LocalDateTime now, EventStatus status);

    // ✅ Même chose mais avec pagination
    Page<Event> findByExpirationTimeAfterAndStatus(LocalDateTime now, EventStatus status, Pageable pageable);

    @Query("SELECT e FROM Event e LEFT JOIN FETCH e.confirmations")
    List<Event> findAllWithConfirmations();

    List<Event> findByLocation_Id(Long locationId);
    List<Event> findByLocation_Nom(String locationNom);
}
