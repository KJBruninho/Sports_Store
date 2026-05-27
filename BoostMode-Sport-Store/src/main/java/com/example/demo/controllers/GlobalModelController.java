package com.example.demo.controllers;

import java.math.BigDecimal;
import java.security.Principal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.example.demo.models.Carrinho;
import com.example.demo.models.Cliente;
import com.example.demo.models.User;
import com.example.demo.repositories.CarrinhoRepository;
import com.example.demo.repositories.ClienteRepository;
import com.example.demo.repositories.UserRepository;

@ControllerAdvice
public class GlobalModelController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ClienteRepository clienteRepository;

    @Autowired
    private CarrinhoRepository carrinhoRepository;
    

    @ModelAttribute("clienteLogado")
    public Cliente clienteLogado(Principal principal) {
        return getClienteAutenticado(principal);
    }

    @ModelAttribute("carrinhoQuantidade")
    public int carrinhoQuantidade(Principal principal) {
        Cliente cliente = getClienteAutenticado(principal);

        if (cliente == null) {
            return 0;
        }

        List<Carrinho> itens = carrinhoRepository.findByCliente(cliente);

        return itens.stream()
                .mapToInt(Carrinho::getQuantidade)
                .sum();
    }

    @ModelAttribute("carrinhoTotal")
    public BigDecimal carrinhoTotal(Principal principal) {
        Cliente cliente = getClienteAutenticado(principal);

        if (cliente == null) {
            return BigDecimal.ZERO;
        }

        List<Carrinho> itens = carrinhoRepository.findByCliente(cliente);

        return itens.stream()
                .map(item -> item.getProduto().getPreco()
                        .multiply(BigDecimal.valueOf(item.getQuantidade())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private Cliente getClienteAutenticado(Principal principal) {
        if (principal == null) {
            return null;
        }

        User user = userRepository.findByEmail(principal.getName());

        if (user == null) {
            return null;
        }

        return clienteRepository.findByUser(user);
    }
}