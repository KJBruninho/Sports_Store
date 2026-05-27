package com.example.demo.models;

import jakarta.persistence.*;

@Entity
@Table(name = "estado")
public class Estado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idEstado")
    private Integer idEstado;

    @Column(nullable = false, unique = true)
    private String nome;

    public Integer getIdEstado() {
        return idEstado;
    }

    public String getNome() {
    	return nome;
    }

    public void setIdEstado(Integer idEstado) {
        this.idEstado = idEstado;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }
}