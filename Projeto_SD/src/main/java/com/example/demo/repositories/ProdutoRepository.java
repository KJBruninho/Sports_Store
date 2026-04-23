package com.example.demo.repositories;

import com.example.demo.models.Produto;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
public interface ProdutoRepository extends JpaRepository<Produto, Integer> {
    List<Produto> findAll();
}