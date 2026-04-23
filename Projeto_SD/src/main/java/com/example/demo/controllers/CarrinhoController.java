package com.example.demo.controllers;

import com.example.demo.models.Carrinho;
import com.example.demo.models.Produto;
import com.example.demo.repositories.ProdutoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.SessionAttributes;

@Controller
@SessionAttributes("carrinho") // Mantém o carrinho na sessão
public class CarrinhoController {

    @Autowired
    private ProdutoRepository produtoRepository;

    // Inicializa o carrinho na sessão, se não existir
    @ModelAttribute("carrinho")
    public Carrinho criarCarrinho() {
        return new Carrinho();
    }

    // Adicionar produto ao carrinho
    @GetMapping("/carrinho/adicionar/{id}")
    public String adicionarProduto(@PathVariable Integer id, @ModelAttribute("carrinho") Carrinho carrinho) {
        Produto produto = produtoRepository.findById(id).orElse(null);
        if (produto != null) {
            carrinho.adicionarProduto(produto);
        }
        return "redirect:/home"; // Redireciona para a página de produtos
    }

    // Remover produto do carrinho
    @GetMapping("/carrinho/remover/{id}")
    public String removerProduto(@PathVariable Integer id, @ModelAttribute("carrinho") Carrinho carrinho) {
        Produto produto = produtoRepository.findById(id).orElse(null);
        if (produto != null) {
            carrinho.removerProduto(produto);
        }
        return "redirect:/carrinho"; // Redireciona para a página do carrinho
    }

    // Visualizar o carrinho
    @GetMapping("/carrinho")
    public String verCarrinho(@ModelAttribute("carrinho") Carrinho carrinho, Model model) {
        model.addAttribute("itens", carrinho.getItens());  // Passa os itens do carrinho
        model.addAttribute("total", carrinho.getTotal());  // Passa o total calculado
        return "carrinho"; // Exibe a página do carrinho
    }

    // Limpar o carrinho
    @GetMapping("/carrinho/limpar")
    public String limparCarrinho(@ModelAttribute("carrinho") Carrinho carrinho) {
        carrinho.limpar();  // Limpa os itens do carrinho
        return "redirect:/carrinho";  // Redireciona para a página do carrinho vazio
    }
}
