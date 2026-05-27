package com.example.demo.controllers;

import java.security.Principal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.ui.Model;

import com.example.demo.models.Cliente;
import com.example.demo.models.Favorito;
import com.example.demo.models.Produto;
import com.example.demo.models.User;
import com.example.demo.repositories.ClienteRepository;
import com.example.demo.repositories.FavoritoRepository;
import com.example.demo.repositories.ProdutoRepository;
import com.example.demo.repositories.UserRepository;

@Controller
public class FavoritoController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ClienteRepository clienteRepository;

    @Autowired
    private ProdutoRepository produtoRepository;

    @Autowired
    private FavoritoRepository favoritoRepository;

    @GetMapping("/favoritos")
    public String listarFavoritos(Model model, Principal principal) {
        Cliente cliente = getClienteAutenticado(principal);

        if (cliente == null) {
            return "redirect:/login";
        }

        List<Favorito> favoritos = favoritoRepository.findByClienteWithProdutoAndCategoria(cliente);

        model.addAttribute("favoritos", favoritos);

        return "favoritos";
    }

    @GetMapping("/favoritos/adicionar/{id}")
    public String adicionarFavorito(@PathVariable Integer id,
                                    Principal principal,
                                    @RequestHeader(value = "Referer", required = false) String referer) {
        Cliente cliente = getClienteAutenticado(principal);

        if (cliente == null) {
            return "redirect:/login";
        }

        Produto produto = produtoRepository.findById(id).orElse(null);

        if (produto == null) {
            return "redirect:/catalogo";
        }

        boolean jaExiste = favoritoRepository.existsByClienteAndProduto(cliente, produto);

        if (!jaExiste) {
            Favorito favorito = new Favorito();
            favorito.setCliente(cliente);
            favorito.setProduto(produto);

            favoritoRepository.save(favorito);
        }

        return "redirect:" + limparReferer(referer);
    }

    @GetMapping("/favoritos/remover/{id}")
    public String removerFavorito(@PathVariable Integer id,
                                  Principal principal,
                                  @RequestHeader(value = "Referer", required = false) String referer) {
        Cliente cliente = getClienteAutenticado(principal);

        if (cliente == null) {
            return "redirect:/login";
        }

        Produto produto = produtoRepository.findById(id).orElse(null);

        if (produto == null) {
            return "redirect:/favoritos";
        }

        Favorito favorito = favoritoRepository
                .findByClienteAndProduto(cliente, produto)
                .orElse(null);

        if (favorito != null) {
            favoritoRepository.delete(favorito);
        }

        return "redirect:" + limparReferer(referer);
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

    private String limparReferer(String referer) {
        if (referer == null || referer.isBlank()) {
            return "/catalogo";
        }

        try {
            java.net.URI uri = java.net.URI.create(referer);
            String path = uri.getPath();

            if (uri.getQuery() != null) {
                path += "?" + uri.getQuery();
            }

            return path;
        } catch (Exception e) {
            return "/catalogo";
        }
    }
}