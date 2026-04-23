package com.example.demo.models;

import jakarta.persistence.*;

@Entity
@Table(name = "itemvenda")
public class ItemVenda {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idItem;

    @ManyToOne
    @JoinColumn(name = "idVenda")
    private Venda venda;

    @ManyToOne
    @JoinColumn(name = "idProduto")
    private Produto produto;

    private Integer quantidade;
    private Double precoUnitario;

    // Getters and Setters
}