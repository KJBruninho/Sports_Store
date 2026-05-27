package com.example.demo.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;

import com.example.demo.models.Venda;

public interface AdminRelatorioRepository extends Repository<Venda, Integer> {

    @Query(value = "CALL sp_relatorio_kpis()", nativeQuery = true)
    List<Object[]> buscarKpis();

    @Query(value = "CALL sp_relatorio_produtos_mais_vendidos()", nativeQuery = true)
    List<Object[]> buscarProdutosMaisVendidos();

    @Query(value = "CALL sp_relatorio_categorias_mais_vendidas()", nativeQuery = true)
    List<Object[]> buscarCategoriasMaisVendidas();

    @Query(value = "CALL sp_relatorio_vendas_ultimos_7_dias()", nativeQuery = true)
    List<Object[]> buscarVendasUltimos7Dias();

    @Query(value = "CALL sp_relatorio_vendas_recentes()", nativeQuery = true)
    List<Object[]> buscarVendasRecentes();

    @Query(value = "CALL sp_relatorio_logs_acesso_recentes()", nativeQuery = true)
    List<Object[]> buscarLogsAcessoRecentes();
}