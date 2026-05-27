package com.example.demo.controllers;

import java.math.BigDecimal;
import java.security.Principal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.example.demo.models.Carrinho;
import com.example.demo.models.Cliente;
import com.example.demo.models.Favorito;
import com.example.demo.models.User;
import com.example.demo.models.Venda;
import com.example.demo.repositories.CarrinhoRepository;
import com.example.demo.repositories.ClienteRepository;
import com.example.demo.repositories.FavoritoRepository;
import com.example.demo.repositories.UserRepository;
import com.example.demo.repositories.VendaRepository;

@Controller
public class ClienteController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ClienteRepository clienteRepository;

    @Autowired
    private CarrinhoRepository carrinhoRepository;

    @Autowired
    private FavoritoRepository favoritoRepository;

    @Autowired
    private VendaRepository vendaRepository;


    @GetMapping("/cliente/perfil")
    public String perfilCliente(Model model, Principal principal) {
        Cliente cliente = getClienteAutenticado(principal);

        if (cliente == null) {
            return "redirect:/login";
        }

        List<Carrinho> itensCarrinho = carrinhoRepository.findByCliente(cliente);
        List<Favorito> favoritos = favoritoRepository.findByClienteWithProdutoAndCategoria(cliente);
        List<Venda> vendas = vendaRepository.findByClienteOrderByDataDesc(cliente);

        BigDecimal totalCarrinho = calcularTotalCarrinho(itensCarrinho);

        model.addAttribute("cliente", cliente);
        model.addAttribute("user", cliente.getUser());
        model.addAttribute("itensCarrinho", itensCarrinho);
        model.addAttribute("favoritos", favoritos);
        model.addAttribute("vendas", vendas);
        model.addAttribute("totalCarrinho", totalCarrinho);

        return "cliente-perfil";
    }

    private BigDecimal calcularTotalCarrinho(List<Carrinho> itens) {
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