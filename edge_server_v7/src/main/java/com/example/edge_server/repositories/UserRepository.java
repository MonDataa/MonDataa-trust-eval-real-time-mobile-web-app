package com.example.edge_server.repositories;

import com.example.edge_server.entites.Useer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<Useer, Long> {
    Useer findByUsername(String username);

    boolean existsByUsername(String name);
    boolean existsByEmail(String email);
    Optional<Useer> findByEmail(String email);
}