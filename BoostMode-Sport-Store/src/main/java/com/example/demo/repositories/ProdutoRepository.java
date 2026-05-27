package com.example.demo.repositories;

import com.example.demo.models.Categoria;
import com.example.demo.models.Produto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface ProdutoRepository extends JpaRepository<Produto, Integer> {
	
	List<Produto> findByAtivoTrue();

    List<Produto> findByCategoriaNomeIgnoreCase(String nome);
    
    @Query("SELECT COALESCE(SUM(p.stock), 0) FROM Produto p")
    Integer getTotalStock();
    
    List<Produto> findByCategoria(Categoria categoria);

    Long countByCategoria(Categoria categoria);
    
    @Query(value = "CALL sp_top_8_produtos_mais_vendidos()", nativeQuery = true)
    List<Produto> findTop8ProdutosMaisVendidos();
    
    @Modifying
    @Transactional
    @Query(value = "CALL sp_remover_produto(:idProduto)", nativeQuery = true)
    void removerProduto(@Param("idProduto") Integer idProduto);

    @Query(value = """
    	    CALL sp_pesquisar_produtos(
    	        :termo,
    	        :categoria,
    	        :precoMin,
    	        :precoMax,
    	        :comStock
    	    )
    	""", nativeQuery = true)
    List<Produto> filtrarProdutos(@Param("termo") String termo,
    		@Param("categoria") Integer categoria,
    		@Param("precoMin") Double precoMin,
    		@Param("precoMax") Double precoMax,
    		@Param("comStock") boolean comStock);
}