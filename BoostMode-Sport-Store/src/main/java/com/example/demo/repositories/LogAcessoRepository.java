package com.example.demo.repositories;

import com.example.demo.models.LogAcesso;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LogAcessoRepository extends JpaRepository<LogAcesso, Integer> {
}