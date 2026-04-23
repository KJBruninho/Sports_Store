package com.example.demo.repositories;

import com.example.demo.models.Fatura;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FaturaRepository extends JpaRepository<Fatura, Integer> {
}