package com.example.demo.repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.example.demo.models.Cliente;
import com.example.demo.models.Favorito;
import com.example.demo.models.Produto;

public interface FavoritoRepository extends JpaRepository<Favorito, Integer> {

    List<Favorito> findByCliente(Cliente cliente);

    Optional<Favorito> findByClienteAndProduto(Cliente cliente, Produto produto);

    boolean existsByClienteAndProduto(Cliente cliente, Produto produto);

    @Query("""
        SELECT f
        FROM Favorito f
        JOIN FETCH f.produto p
        LEFT JOIN FETCH p.categoria
        WHERE f.cliente = :cliente
    """)
    List<Favorito> findByClienteWithProdutoAndCategoria(Cliente cliente);
}