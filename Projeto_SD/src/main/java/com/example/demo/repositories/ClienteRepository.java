package com.example.demo.repositories;

import com.example.demo.models.Cliente;
import com.example.demo.models.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClienteRepository extends JpaRepository<Cliente, Long> {
    
    // Declarar este método para encontrar cliente pelo user associado
    Cliente findByUser(User user);
}
