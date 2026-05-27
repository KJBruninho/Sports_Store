package com.example.demo.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.example.demo.models.User;

public interface UserRepository extends JpaRepository<User, Integer> {

    User findByEmail(String email);

    @Query("""
        SELECT u
        FROM User u
        JOIN FETCH u.estado
        ORDER BY u.idUser ASC
    """)
    List<User> findAllWithEstado();
}