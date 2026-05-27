package com.example.demo.controllers;

import java.math.BigDecimal;
import java.security.Principal;
import java.util.List;
import java.util.Optional;

import com.example.demo.models.Carrinho;
import com.example.demo.models.Cliente;
import com.example.demo.models.Produto;
import com.example.demo.models.User;
import com.example.demo.repositories.CarrinhoRepository;
import com.example.demo.repositories.ClienteRepository;
import com.example.demo.repositories.ProdutoRepository;
import com.example.demo.repositories.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class CarrinhoController {

    @Autowired
    private CarrinhoRepository carrinhoRepository;

    @Autowired
    private ProdutoRepository produtoRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ClienteRepository clienteRepository;

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


    @GetMapping("/carrinho/remover/{id}")
    public String removerProduto(@PathVariable Integer id,
                                 Principal principal,
                                 @RequestHeader(value = "Referer", required = false) String referer) {
        Cliente cliente = getClienteAutenticado(principal);

        if (cliente == null) {
            return "redirect:/login";
        }

        Produto produto = produtoRepository.findById(id).orElse(null);

        if (produto != null) {
            carrinhoRepository
                    .findByClienteAndProduto(cliente, produto)
                    .ifPresent(carrinhoRepository::delete);
        }

        if (referer != null && !referer.isBlank()) {
            return "redirect:" + referer;
        }

        return "redirect:/carrinho";
    }

    @PostMapping("/carrinho/atualizar/{id}")
    public String atualizarQuantidade(@PathVariable Integer id,
                                      @RequestParam Integer quantidade,
                                      Principal principal,
                                      @RequestHeader(value = "Referer", required = false) String referer) {
        Cliente cliente = getClienteAutenticado(principal);

        if (cliente == null) {
            return "redirect:/login";
        }

        Produto produto = produtoRepository.findById(id).orElse(null);

        if (produto != null) {
            carrinhoRepository
                    .findByClienteAndProduto(cliente, produto)
                    .ifPresent(item -> {
                        if (quantidade == null || quantidade <= 0) {
                            carrinhoRepository.delete(item);
                        } else {
                            item.setQuantidade(quantidade);
                            carrinhoRepository.save(item);
                        }
                    });
        }

        if (referer != null && !referer.isBlank()) {
            return "redirect:" + referer;
        }

        return "redirect:/carrinho";
    }
    
    @PostMapping("/carrinho/adicionar/{id}")
    public String adicionarAoCarrinho(@PathVariable Integer id,
                                      @RequestParam(defaultValue = "1") Integer quantidade,
                                      Principal principal,
                                      @RequestHeader(value = "Referer", required = false) String referer,
                                      RedirectAttributes redirectAttributes) {
        if (quantidade == null || quantidade <= 0) {
            redirectAttributes.addFlashAttribute("erro", "Quantidade inválida.");
            return "redirect:" + (referer != null ? referer : "/catalogo");
        }

        Cliente cliente = getClienteAutenticado(principal);

        if (cliente == null) {
            return "redirect:/login";
        }

        Produto produto = produtoRepository.findById(id).orElse(null);

        if (produto == null) {
            redirectAttributes.addFlashAttribute("erro", "Produto não encontrado.");
            return "redirect:" + (referer != null ? referer : "/catalogo");
        }

        if (produto.getStock() <= 0) {
            redirectAttributes.addFlashAttribute("erro", "Produto sem stock.");
            return "redirect:" + (referer != null ? referer : "/catalogo");
        }

        if (quantidade > produto.getStock()) {
            redirectAttributes.addFlashAttribute("erro", "Quantidade superior ao stock disponível.");
            return "redirect:" + (referer != null ? referer : "/catalogo");
        }

        Optional<Carrinho> itemExistenteOptional =
                carrinhoRepository.findByClienteAndProduto(cliente, produto);

        if (itemExistenteOptional.isPresent()) {
            Carrinho itemExistente = itemExistenteOptional.get();

            int novaQuantidade = itemExistente.getQuantidade() + quantidade;

            if (novaQuantidade > produto.getStock()) {
                redirectAttributes.addFlashAttribute("erro", "Quantidade total superior ao stock disponível.");
                return "redirect:" + (referer != null ? referer : "/catalogo");
            }

            itemExistente.setQuantidade(novaQuantidade);
            carrinhoRepository.save(itemExistente);
        } else {
            Carrinho novoItem = new Carrinho();
            novoItem.setCliente(cliente);
            novoItem.setProduto(produto);
            novoItem.setQuantidade(quantidade);

            carrinhoRepository.save(novoItem);
        }

        redirectAttributes.addFlashAttribute("sucesso", "Produto adicionado ao carrinho.");
        return "redirect:" + (referer != null ? referer : "/catalogo");
    }

    @GetMapping("/carrinho")
    public String verCarrinho(Principal principal, Model model) {
        Cliente cliente = getClienteAutenticado(principal);

        if (cliente == null) {
            return "redirect:/login";
        }

        List<Carrinho> itens = carrinhoRepository.findByCliente(cliente);
        BigDecimal total = calcularTotal(itens);

        model.addAttribute("itens", itens);
        model.addAttribute("total", total);

        return "carrinho";
    }

    @GetMapping("/carrinho/limpar")
    public String limparCarrinho(Principal principal,
                                 @RequestHeader(value = "Referer", required = false) String referer) {
        Cliente cliente = getClienteAutenticado(principal);

        if (cliente == null) {
            return "redirect:/login";
        }

        carrinhoRepository.deleteByCliente(cliente);

        if (referer != null && !referer.isBlank()) {
            return "redirect:" + referer;
        }

        return "redirect:/carrinho";
    }

    private BigDecimal calcularTotal(List<Carrinho> itens) {
        return itens.stream()
                .map(item -> item.getProduto().getPreco()
                        .multiply(BigDecimal.valueOf(item.getQuantidade())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
