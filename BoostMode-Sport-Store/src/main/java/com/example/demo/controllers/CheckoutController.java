package com.example.demo.controllers;

import java.math.BigDecimal;
import java.security.Principal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.demo.models.Carrinho;
import com.example.demo.models.Cliente;
import com.example.demo.models.Fatura;
import com.example.demo.models.ItemVenda;
import com.example.demo.models.Produto;
import com.example.demo.models.User;
import com.example.demo.models.Venda;
import com.example.demo.repositories.CarrinhoRepository;
import com.example.demo.repositories.ClienteRepository;
import com.example.demo.repositories.FaturaRepository;
import com.example.demo.repositories.ItemVendaRepository;
import com.example.demo.repositories.ProdutoRepository;
import com.example.demo.repositories.UserRepository;
import com.example.demo.repositories.VendaRepository;

@Controller
public class CheckoutController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ClienteRepository clienteRepository;

    @Autowired
    private CarrinhoRepository carrinhoRepository;

    @Autowired
    private ProdutoRepository produtoRepository;

    @Autowired
    private VendaRepository vendaRepository;

    @Autowired
    private ItemVendaRepository itemVendaRepository;

    @Autowired
    private FaturaRepository faturaRepository;

    @GetMapping("/checkout")
    public String checkout(Model model, Principal principal) {
        Cliente cliente = getClienteAutenticado(principal);

        if (cliente == null) {
            return "redirect:/login";
        }

        List<Carrinho> itens = carrinhoRepository.findByCliente(cliente);

        if (itens.isEmpty()) {
            return "redirect:/carrinho";
        }

        BigDecimal total = calcularTotal(itens);

        model.addAttribute("cliente", cliente);
        model.addAttribute("itens", itens);
        model.addAttribute("total", total);

        return "checkout";
    }

	@PostMapping("/checkout/finalizar")
	@Transactional
	public String finalizarCompra(Principal principal, RedirectAttributes redirectAttributes) {
	    Cliente cliente = getClienteAutenticado(principal);
	
	    if (cliente == null) {
	        return "redirect:/login";
	    }
	
	    List<Carrinho> itensCarrinho = carrinhoRepository.findByCliente(cliente);
	
	    if (itensCarrinho.isEmpty()) {
	        redirectAttributes.addFlashAttribute("aviso", "O teu carrinho está vazio.");
	        return "redirect:/carrinho";
	    }
	
	    try {
	        for (Carrinho item : itensCarrinho) {
	            Produto produto = produtoRepository.findById(item.getProduto().getIdProduto()).orElse(null);
	
	            if (produto == null) {
	                redirectAttributes.addFlashAttribute("erro", "Um dos produtos do carrinho já não está disponível.");
	                return "redirect:/carrinho";
	            }
	
	            if (produto.getStock() <= 0) {
	                redirectAttributes.addFlashAttribute("erro",
	                        "O produto \"" + produto.getNome() + "\" já não está disponível. O mesmo pode ser verdade para outros.");
	                return "redirect:/carrinho";
	            }
	
	            if (produto.getStock() < item.getQuantidade()) {
	                redirectAttributes.addFlashAttribute("erro",
	                        "O stock do produto \"" + produto.getNome() + "\" mudou. Stock disponível: "
	                                + produto.getStock() + ". O mesmo pode ser verdade para outros.");
	                return "redirect:/carrinho";
	            }
	        }
	
	        Venda venda = new Venda();
	        venda.setCliente(cliente);
	        venda.setData(LocalDateTime.now());
	        vendaRepository.save(venda);
	
	        BigDecimal total = BigDecimal.ZERO;
	
	        for (Carrinho itemCarrinho : itensCarrinho) {
	            Produto produto = produtoRepository.findById(itemCarrinho.getProduto().getIdProduto()).orElse(null);
	
	            if (produto == null) {
	                redirectAttributes.addFlashAttribute("erro", "Um dos produtos já não está disponível. O mesmo pode ser verdade para outros.");
	                return "redirect:/carrinho";
	            }
	
	            int quantidade = itemCarrinho.getQuantidade();
	
	            if (produto.getStock() < quantidade) {
	                redirectAttributes.addFlashAttribute("erro",
	                        "O stock do produto \"" + produto.getNome() + "\" mudou durante a compra. O mesmo pode ser verdade para outros.");
	                return "redirect:/carrinho";
	            }
	
	            BigDecimal precoUnitario = produto.getPreco();
	            BigDecimal subtotal = precoUnitario.multiply(BigDecimal.valueOf(quantidade));
	
	            ItemVenda itemVenda = new ItemVenda();
	            itemVenda.setVenda(venda);
	            itemVenda.setProduto(produto);
	            itemVenda.setQuantidade(quantidade);
	            itemVenda.setPrecoUnitario(precoUnitario);
	            itemVendaRepository.save(itemVenda);
	
	            produto.setStock(produto.getStock() - quantidade);
	            produtoRepository.save(produto);
	
	            total = total.add(subtotal);
	        }
	
	        Fatura fatura = new Fatura();
	        fatura.setVenda(venda);
	        fatura.setTotal(total);
	        fatura.setDataEmissao(LocalDateTime.now());
	        faturaRepository.save(fatura);
	
	        carrinhoRepository.deleteAll(itensCarrinho);
	
	        redirectAttributes.addFlashAttribute("sucesso", "Compra finalizada com sucesso.");
	        return "redirect:/faturas/" + fatura.getIdFatura();
	
	    } catch (DataAccessException ex) {
	        redirectAttributes.addFlashAttribute("erro",
	                "Não foi possível finalizar a compra. O stock pode ter mudado ou algum produto já não está disponível.");
	        return "redirect:/carrinho";
	    }
	}
	
    private BigDecimal calcularTotal(List<Carrinho> itens) {
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
