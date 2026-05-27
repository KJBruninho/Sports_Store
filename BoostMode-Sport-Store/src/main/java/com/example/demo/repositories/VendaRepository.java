package com.example.demo.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.models.Cliente;
import com.example.demo.models.Venda;

public interface VendaRepository extends JpaRepository<Venda, Integer> {

    List<Venda> findByCliente(Cliente cliente);

	List<Venda> findByClienteOrderByDataDesc(Cliente cliente);
}