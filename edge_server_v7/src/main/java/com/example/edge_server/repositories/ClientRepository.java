package com.example.edge_server.repositories;

import com.example.edge_server.entites.Client;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

@Repository
public interface ClientRepository extends JpaRepository<Client, Long> {
    Page<Client> findAll(Pageable pageable);
    Page<Client> findByUsernameContainingIgnoreCase(String username, Pageable pageable);
    @Query("SELECT c FROM Client c WHERE c.position IS NOT NULL")
    Page<Client> findAllWithPosition(Pageable pageable);
    @Query("SELECT c FROM Client c WHERE c.position IS NOT NULL")
    List<Client> findAllWithPosition();

    @EntityGraph(attributePaths = {"confirmations.event"})
    List<Client> findAll();
}
