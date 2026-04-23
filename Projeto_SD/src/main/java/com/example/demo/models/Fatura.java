package com.example.demo.models;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "fatura")
public class Fatura {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idFatura;

    @OneToOne
    @JoinColumn(name = "idVenda")
    private Venda venda;

    private Double total;

    @Temporal(TemporalType.DATE)
    private Date dataEmissao;

    // Getters and Setters
}