package com.example.demo.models;

import java.math.BigDecimal;

import jakarta.persistence.*;

@Entity
@Table(name = "produto")
public class Produto {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idProduto;

    @Column(nullable = false)
    private String nome;

    @Column
    private String descricao;
    
    @Column(precision = 10, scale = 2)
    private BigDecimal preco;
    
    @Column(nullable = false)
    private Integer stock;
    
    @Column(name = "imagemUrl")
    private String imagemUrl;


    public void setImagemUrl(String imagemUrl) {
        this.imagemUrl = imagemUrl;
    }

    @ManyToOne
    @JoinColumn(name = "idCategoria")
    private Categoria categoria;
    
    @Column(nullable = false)
    private Boolean ativo = true;

    // Getters e Setters
    public Integer getIdProduto() {
        return idProduto;
    }

    public void setIdProduto(Integer idProduto) {
        this.idProduto = idProduto;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public BigDecimal getPreco() {
        return preco;
    }

    public void setPreco(BigDecimal preco) {
        this.preco = preco;
    }

    public Integer getStock() {
        return stock;
    }

    public void setStock(Integer stock) {
        this.stock = stock;
    }

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
        this.categoria = categoria;
    }
    
    public String getImagemUrl() {
    	return imagemUrl;
    }
    
    public void setImageURL(String image) {
    	this.imagemUrl = image;
    }
    
    public Boolean getAtivo() {
    	return ativo;
    }
    
    public void setAtivo(Boolean ativo) {
    	this.ativo = ativo;
    }
    
}
