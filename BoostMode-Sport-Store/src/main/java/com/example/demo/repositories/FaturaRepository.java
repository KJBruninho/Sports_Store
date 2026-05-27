package com.example.demo.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.example.demo.models.Fatura;

@Repository
public interface FaturaRepository extends JpaRepository<Fatura, Integer> {

    @Query("""
        SELECT f
        FROM Fatura f
        JOIN FETCH f.venda v
        JOIN FETCH v.cliente c
        WHERE f.idFatura = :id
    """)
    Optional<Fatura> findByIdWithVendaAndCliente(Integer id);
    
    Optional<Fatura> findByVenda_IdVenda(Integer idVenda);
}