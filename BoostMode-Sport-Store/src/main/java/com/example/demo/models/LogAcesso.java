package com.example.demo.models;

import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
@Table(name = "log_acesso")
public class LogAcesso {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idLogAcesso")
    private Integer idLogAcesso;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "idUser", nullable = true)
    private User user;

    @Column(name = "emailTentado", nullable = false)
    private String emailTentado;

    @Column(nullable = false)
    private String resultado;


    @Column(name = "dataTentativa", nullable = false)
    private LocalDateTime dataTentativa;

    public Integer getIdLogAcesso() {
        return idLogAcesso;
    }

    public void setIdLogAcesso(Integer idLogAcesso) {
        this.idLogAcesso = idLogAcesso;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getEmailTentado() {
        return emailTentado;
    }

    public void setEmailTentado(String emailTentado) {
        this.emailTentado = emailTentado;
    }

    public String getResultado() {
        return resultado;
    }

    public void setResultado(String resultado) {
        this.resultado = resultado;
    }
    public LocalDateTime getDataTentativa() {
        return dataTentativa;
    }

    public void setDataTentativa(LocalDateTime dataTentativa) {
        this.dataTentativa = dataTentativa;
    }
}