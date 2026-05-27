package com.example.demo.repositories;

import com.example.demo.models.Cliente;
import com.example.demo.models.User;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface ClienteRepository extends JpaRepository<Cliente, Long> {
    
    Cliente findByUser(User user);
    
    @Query("""
    	    SELECT COALESCE(COUNT(c), 0)
    	    FROM Cliente c
    	    WHERE c.user.estado.nome = 'ATIVO'
    	""")
    	Long countClientesAtivos();
    
    @Query("""
            SELECT c
            FROM Cliente c
            JOIN FETCH c.user u
            ORDER BY c.idCliente ASC
        """)
        List<Cliente> findAllWithUser();
}
