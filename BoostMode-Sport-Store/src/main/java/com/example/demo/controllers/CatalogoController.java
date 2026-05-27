package com.example.demo.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.example.demo.models.Categoria;
import com.example.demo.models.Produto;
import com.example.demo.repositories.CategoriaRepository;
import com.example.demo.repositories.ProdutoRepository;

@Controller
public class CatalogoController {

    @Autowired
    private ProdutoRepository produtoRepository;

    @Autowired
    private CategoriaRepository categoriaRepository;

    @GetMapping("/catalogo")
    public String catalogo(
            Model model,
            @RequestParam(required = false) String termo,
            @RequestParam(required = false) Integer categoria,
            @RequestParam(required = false) Double precoMin,
            @RequestParam(required = false) Double precoMax,
            @RequestParam(defaultValue = "false") boolean comStock
    ) {
        List<Produto> produtos = produtoRepository.filtrarProdutos(
                termo,
                categoria,
                precoMin,
                precoMax,
                comStock
        );

        model.addAttribute("produtos", produtos);
        model.addAttribute("categorias", categoriaRepository.findByAtivoTrue());

        model.addAttribute("termo", termo);
        model.addAttribute("categoriaSelecionada", categoria);
        model.addAttribute("precoMin", precoMin);
        model.addAttribute("precoMax", precoMax);
        model.addAttribute("comStock", comStock);

        if (produtos == null || produtos.isEmpty()) {
            model.addAttribute("aviso", "Nenhum produto encontrado para a pesquisa efetuada.");
        }
        
        return "catalogo";
    }

    @GetMapping("/categorias/{slug}")
    public String categoriaPorSlug(@PathVariable String slug) {
        Categoria categoria = categoriaRepository.findByNomeIgnoreCase(slug);

        if (categoria == null) {
            return "redirect:/catalogo";
        }

        return "redirect:/catalogo?categoria=" + categoria.getIdCategoria();
    }
}