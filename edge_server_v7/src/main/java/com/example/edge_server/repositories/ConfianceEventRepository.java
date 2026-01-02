package com.example.edge_server.repositories;

import com.example.edge_server.entites.ConfianceEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ConfianceEventRepository extends JpaRepository<ConfianceEvent, Long> {
}
