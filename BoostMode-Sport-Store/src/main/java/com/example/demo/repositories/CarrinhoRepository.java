package com.example.demo.repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.models.Carrinho;
import com.example.demo.models.Cliente;
import com.example.demo.models.Produto;

public interface CarrinhoRepository extends JpaRepository<Carrinho, Integer> {

    List<Carrinho> findByCliente(Cliente cliente);

    Optional<Carrinho> findByClienteAndProduto(Cliente cliente, Produto produto);

    @Transactional
    void deleteByCliente(Cliente cliente);
}