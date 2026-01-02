package com.example.edge_server;

import com.example.edge_server.entites.*;
import com.example.edge_server.repositories.*;
import jakarta.transaction.Transactional;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Stream;

@SpringBootApplication
public class EdgeServerApplication {

	public static void main(String[] args) {
		SpringApplication.run(EdgeServerApplication.class, args);
	}
    @Bean
    @Transactional
    CommandLineRunner start(
            LocationRepository locationRepository
            ) {
        return args -> {

            // --- Définition des intervalles pour la latitude et la longitude autour de Mountain View ---
            // Ces intervalles sont choisis pour être proches de la coordonnée centrale 37.4219983, -122.084.
            List<List<Double>> latIntervals = Arrays.asList(
                    Arrays.asList(50.3292,50.3308),
                    Arrays.asList(50.3276,50.3292),
                    Arrays.asList(50.3260,50.3276)
            );

            List<List<Double>> lonIntervals = Arrays.asList(
                    Arrays.asList(3.5125,3.5170),
                    Arrays.asList(3.5125,3.5170),
                    Arrays.asList(3.5125,3.5170)
            );

            // Choix aléatoire d'un intervalle pour latitude et longitude
            String latIntervalStr = latIntervals.get(0).get(0) + "," + latIntervals.get(0).get(1);
            String lonIntervalStr = lonIntervals.get(0).get(0) + "," + lonIntervals.get(0).get(1);

            // --- Création de la Location pour le client ---
            Location location = new Location();
            location.setNom("Nord ");
            location.setZone("Zone de nord ");
            location.setLatitude(latIntervalStr);
            location.setLongitude(lonIntervalStr);

            locationRepository.save(location);

            // Choix aléatoire d'un intervalle pour latitude et longitude
            String latIntervalStr2 = latIntervals.get(1).get(0) + "," + latIntervals.get(1).get(1);
            String lonIntervalStr2 = lonIntervals.get(1).get(0) + "," + lonIntervals.get(1).get(1);

            // --- Création de la Location pour le client ---
            Location location2 = new Location();
            location2.setNom("Centre ");
            location2.setZone("Zone de Centre ");
            location2.setLatitude(latIntervalStr2);
            location2.setLongitude(lonIntervalStr2);

            locationRepository.save(location2);

            // Choix aléatoire d'un intervalle pour latitude et longitude
            String latIntervalStr3 = latIntervals.get(2).get(0) + "," + latIntervals.get(2).get(1);
            String lonIntervalStr3 = lonIntervals.get(2).get(0) + "," + lonIntervals.get(2).get(1);

            // --- Création de la Location pour le client ---
            Location location3 = new Location();
            location3.setNom("Sud ");
            location3.setZone("Zone de Sud ");
            location3.setLatitude(latIntervalStr3);
            location3.setLongitude(lonIntervalStr3);

            locationRepository.save(location3);

        };
    }

}
