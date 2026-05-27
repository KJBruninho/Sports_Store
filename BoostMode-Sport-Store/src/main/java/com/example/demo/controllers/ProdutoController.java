package com.example.demo.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.example.demo.models.Produto;
import com.example.demo.repositories.ProdutoRepository;

@Controller
@RequestMapping("/produto")
public class ProdutoController {

    @Autowired
    private ProdutoRepository produtoRepository;

    @GetMapping("/{id}")
    public String getProdutoDetalhes(@PathVariable Integer id, Model model) {
        Produto produto = produtoRepository.findById(id).orElse(null);

        if (produto == null || Boolean.FALSE.equals(produto.getAtivo())) {
            return "redirect:/catalogo";
        }

        model.addAttribute("produto", produto);
        return "produto";
    }

    @GetMapping("/api")
    @ResponseBody
    public List<Produto> getAllProdutos() {
        return produtoRepository.findAll();
    }

    @PostMapping("/api")
    @ResponseBody
    public Produto createProduto(@RequestBody Produto produto) {
        return produtoRepository.save(produto);
    }

    @GetMapping("/api/{id}")
    @ResponseBody
    public Produto getProdutoById(@PathVariable Integer id) {
        return produtoRepository.findById(id).orElse(null);
    }

    @DeleteMapping("/api/{id}")
    @ResponseBody
    public void deleteProduto(@PathVariable Integer id) {
        produtoRepository.removerProduto(id);
    }
}