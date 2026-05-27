package com.example.demo.models;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
@Table(
    name = "carrinho",
    uniqueConstraints = {
        @UniqueConstraint(columnNames = {"idCliente", "idProduto"})
    }
)
public class Carrinho {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idItemCarrinho")
    private Integer idItemCarrinho;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "idCliente", nullable = false)
    private Cliente cliente;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "idProduto", nullable = false)
    private Produto produto;

    @Column(nullable = false)
    private Integer quantidade;

    @Column(name = "dataAdicao", nullable = false)
    private LocalDateTime dataAdicao;

    @PrePersist
    public void prePersist() {
        if (dataAdicao == null) {
            dataAdicao = LocalDateTime.now();
        }

        if (quantidade == null) {
            quantidade = 1;
        }
    }
    
    public BigDecimal getSubtotal() {
        if (produto == null || produto.getPreco() == null || quantidade == null) {
            return BigDecimal.ZERO;
        }

        return produto.getPreco().multiply(BigDecimal.valueOf(quantidade));
    }

    public Integer getIdItemCarrinho() {
        return idItemCarrinho;
    }

    public void setIdItemCarrinho(Integer idItemCarrinho) {
        this.idItemCarrinho = idItemCarrinho;
    }

    public Cliente getCliente() {
        return cliente;
    }

    public void setCliente(Cliente cliente) {
        this.cliente = cliente;
    }

    public Produto getProduto() {
        return produto;
    }

    public void setProduto(Produto produto) {
        this.produto = produto;
    }

    public Integer getQuantidade() {
        return quantidade;
    }

    public void setQuantidade(Integer quantidade) {
        this.quantidade = quantidade;
    }

    public LocalDateTime getDataAdicao() {
        return dataAdicao;
    }

    public void setDataAdicao(LocalDateTime dataAdicao) {
        this.dataAdicao = dataAdicao;
    }
}