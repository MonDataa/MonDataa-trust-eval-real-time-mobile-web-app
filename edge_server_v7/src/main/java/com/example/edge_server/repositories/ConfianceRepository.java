package com.example.edge_server.repositories;

import com.example.edge_server.entites.Confiance;
import com.example.edge_server.entites.Confirmation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConfianceRepository extends JpaRepository<Confiance, Long> {
}
