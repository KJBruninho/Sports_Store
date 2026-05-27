package com.example.demo.controllers;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.demo.models.Categoria;
import com.example.demo.models.Produto;
import com.example.demo.repositories.CategoriaRepository;
import com.example.demo.repositories.ProdutoRepository;

@Controller
@RequestMapping("/admin")
public class AdminProductController {

    @Autowired
    private ProdutoRepository produtoRepository;

    @Autowired
    private CategoriaRepository categoriaRepository;

    @GetMapping("/produtos")
    public String gerirProdutos(Model model) {
    	List<Produto> produtos = produtoRepository.findByAtivoTrue();
    	List<Categoria> categorias = categoriaRepository.findByAtivoTrue();

        model.addAttribute("produtos", produtos);
        model.addAttribute("categorias", categorias);

        model.addAttribute("novoProduto", new Produto());
        model.addAttribute("novaCategoria", new Categoria());

        model.addAttribute("totalProdutos", produtos.size());
        model.addAttribute("totalCategorias", categorias.size());

        long produtosSemStock = produtos.stream()
                .filter(p -> p.getStock() == null || p.getStock() <= 0)
                .count();

        model.addAttribute("produtosSemStock", produtosSemStock);

        return "admin-produtos";
    }

	@PostMapping("/categorias/adicionar")
	public String adicionarCategoria(@RequestParam String nome,
	                                 @RequestParam(required = false) String imagemUrl,
	                                 RedirectAttributes redirectAttributes) {
	    if (nome == null || nome.isBlank()) {
	        redirectAttributes.addFlashAttribute("erro", "O nome da categoria é obrigatório.");
	        return "redirect:/admin/produtos";
	    }
	
	    Categoria categoriaExistente = categoriaRepository.findByNomeIgnoreCase(nome.trim());
	
	    if (categoriaExistente != null) {
	        redirectAttributes.addFlashAttribute("erro", "Essa categoria já existe.");
	        return "redirect:/admin/produtos";
	    }
	
	    Categoria categoria = new Categoria();
	    categoria.setNome(nome.trim());
	
	    if (imagemUrl != null && !imagemUrl.isBlank()) {
	        categoria.setImagemUrl(imagemUrl.trim());
	    }
	
	    categoriaRepository.save(categoria);
	
	    redirectAttributes.addFlashAttribute("sucesso", "Categoria adicionada com sucesso.");
	    return "redirect:/admin/produtos";
	}

	@PostMapping("/categorias/{id}/remover")
	public String removerCategoria(@PathVariable Integer id,
	                               RedirectAttributes redirectAttributes) {
	    Categoria categoria = categoriaRepository.findById(id).orElse(null);

	    if (categoria == null) {
	        redirectAttributes.addFlashAttribute("erro", "Categoria não encontrada.");
	        return "redirect:/admin/produtos";
	    }

	    try {
	        categoriaRepository.removerCategoria(id);
	        redirectAttributes.addFlashAttribute("sucesso", "Categoria removida ou desativada com sucesso.");
	    } catch (Exception e) {
	        redirectAttributes.addFlashAttribute("erro", "Não foi possível remover a categoria.");
	    }

	    return "redirect:/admin/produtos";
	}

    @PostMapping("/produtos/adicionar")
    public String adicionarProduto(@RequestParam String nome,
                                   @RequestParam(required = false) String descricao,
                                   @RequestParam BigDecimal preco,
                                   @RequestParam Integer stock,
                                   @RequestParam(required = false) String imagemUrl,
                                   @RequestParam Integer idCategoria,
                                   RedirectAttributes redirectAttributes) {
        if (nome == null || nome.isBlank()) {
            redirectAttributes.addFlashAttribute("erro", "O nome do produto é obrigatório.");
            return "redirect:/admin/produtos";
        }

        if (preco == null || preco.compareTo(BigDecimal.ZERO) < 0) {
            redirectAttributes.addFlashAttribute("erro", "O preço não pode ser negativo.");
            return "redirect:/admin/produtos";
        }

        if (stock == null || stock < 0) {
            redirectAttributes.addFlashAttribute("erro", "O stock não pode ser negativo.");
            return "redirect:/admin/produtos";
        }

        Categoria categoria = categoriaRepository.findById(idCategoria).orElse(null);

        if (categoria == null) {
            redirectAttributes.addFlashAttribute("erro", "Categoria inválida.");
            return "redirect:/admin/produtos";
        }

        Produto produto = new Produto();
        produto.setNome(nome.trim());
        produto.setDescricao(descricao);
        produto.setPreco(preco);
        produto.setStock(stock);
        produto.setCategoria(categoria);

        if (imagemUrl != null && !imagemUrl.isBlank()) {
            produto.setImagemUrl(imagemUrl.trim());
        }

        produtoRepository.save(produto);

        redirectAttributes.addFlashAttribute("sucesso", "Produto adicionado com sucesso.");
        return "redirect:/admin/produtos";
    }

    @PostMapping("/produtos/{id}/remover")
    public String removerProduto(@PathVariable Integer id,
                                 RedirectAttributes redirectAttributes) {
        Produto produto = produtoRepository.findById(id).orElse(null);

        if (produto == null) {
            redirectAttributes.addFlashAttribute("erro", "Produto não encontrado.");
            return "redirect:/admin/produtos";
        }

        try {
            produtoRepository.removerProduto(id);
            redirectAttributes.addFlashAttribute("sucesso", "Produto removido ou desativado com sucesso.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute(
                    "erro",
                    "Não foi possível remover o produto."
            );
        }

        return "redirect:/admin/produtos";
    }
}