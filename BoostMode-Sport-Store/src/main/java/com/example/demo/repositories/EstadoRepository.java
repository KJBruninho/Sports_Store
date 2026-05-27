package com.example.demo.repositories;

import com.example.demo.models.Estado;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EstadoRepository extends JpaRepository<Estado, Integer> {
    Estado findByNome(String nome);
}