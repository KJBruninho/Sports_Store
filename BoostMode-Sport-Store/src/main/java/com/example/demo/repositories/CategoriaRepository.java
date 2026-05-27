package com.example.demo.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.models.Categoria;

public interface CategoriaRepository extends JpaRepository<Categoria, Integer> {
	
	List<Categoria> findByAtivoTrue();

    Categoria findByNomeIgnoreCase(String nome);
    
    @Query(value = "CALL sp_top_9_categorias_mais_vendidas()", nativeQuery = true)
    List<Categoria> findTop8CategoriasMaisVendidas();
    

    @Query(value = "CALL sp_categoria_mais_vendida()", nativeQuery = true)
    Categoria findCategoriaMaisVendida();
    
    @Modifying
    @Transactional
    @Query(value = "CALL sp_remover_categoria(:idCategoria)", nativeQuery = true)
    void removerCategoria(@Param("idCategoria") Integer idCategoria);
}