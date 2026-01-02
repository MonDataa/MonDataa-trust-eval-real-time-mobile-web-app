package com.example.edge_server.repositories;

import com.example.edge_server.entites.Event;
import com.example.edge_server.entites.Location;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LocationRepository extends JpaRepository<Location, Long> {
    List<Event> findLocationByNom(String nom);
    List<Location> findByNom(String nom);
    @Query("SELECT DISTINCT l.zone FROM Location l")
    List<String> findDistinctZones();
    Optional<Location> findByNomAndZone(String nom, String zone);

}
