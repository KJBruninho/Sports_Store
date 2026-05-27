package com.example.demo.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.example.demo.models.ItemVenda;
import com.example.demo.models.Venda;

@Repository
public interface ItemVendaRepository extends JpaRepository<ItemVenda, Integer> {

    List<ItemVenda> findByVenda(Venda venda);

    @Query("""
        SELECT i
        FROM ItemVenda i
        JOIN FETCH i.produto
        WHERE i.venda = :venda
    """)
    List<ItemVenda> findByVendaWithProduto(Venda venda);
    
    @Query(value = "SELECT COALESCE(SUM(precoUnitario * quantidade), 0) FROM item_venda", nativeQuery = true)
    Double somaTotalPrecosUnitarios();
    
    @Query("""
    	    SELECT COALESCE(SUM(i.quantidade), 0)
    	    FROM ItemVenda i
    	""")
    	Long totalProdutosVendidos();
}