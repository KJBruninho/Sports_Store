package com.example.demo.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import com.example.demo.repositories.ProdutoRepository;
import com.example.demo.models.Produto;

@Controller
@RequestMapping("/produto")
public class ProdutoController {

    @Autowired
    private ProdutoRepository produtoRepository;

    // Mostrar página HTML com detalhes do produto
    @GetMapping("/{id}")
    public String getProdutoDetalhes(@PathVariable Integer id, Model model) {
        Produto produto = produtoRepository.findById(id).orElse(null);
        model.addAttribute("produto", produto);
        return "produto"; // templates/produto.html
    }

    // Para API REST - lista todos os produtos (JSON)
    @GetMapping("/api")
    @ResponseBody
    public List<Produto> getAllProdutos() {
        return produtoRepository.findAll();
    }

    // Para API REST - criar produto (JSON)
    @PostMapping("/api")
    @ResponseBody
    public Produto createProduto(@RequestBody Produto produto) {
        return produtoRepository.save(produto);
    }

    // Para API REST - obter produto por id (JSON)
    @GetMapping("/api/{id}")
    @ResponseBody
    public Produto getProdutoById(@PathVariable Integer id) {
        return produtoRepository.findById(id).orElse(null);
    }

    // Para API REST - apagar produto por id
    @DeleteMapping("/api/{id}")
    @ResponseBody
    public void deleteProduto(@PathVariable Integer id) {
        produtoRepository.deleteById(id);
    }
}
