package com.example.demo.controllers;

import java.nio.charset.StandardCharsets;
import java.security.Principal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.example.demo.models.Fatura;
import com.example.demo.models.ItemVenda;
import com.example.demo.models.Venda;
import com.example.demo.repositories.FaturaRepository;
import com.example.demo.repositories.ItemVendaRepository;

@Controller
public class FaturaController {

    @Autowired
    private FaturaRepository faturaRepository;

    @Autowired
    private ItemVendaRepository itemVendaRepository;

    @GetMapping("/faturas/{id}")
    public String verFatura(@PathVariable Integer id, Model model, Principal principal) {
        Fatura fatura = faturaRepository.findByIdWithVendaAndCliente(id).orElse(null);

        if (fatura == null) {
            return "redirect:/error_page";
        }

        Venda venda = fatura.getVenda();
        List<ItemVenda> itens = itemVendaRepository.findByVendaWithProduto(venda);

        model.addAttribute("fatura", fatura);
        model.addAttribute("venda", venda);
        model.addAttribute("cliente", venda.getCliente());
        model.addAttribute("itens", itens);

        return "fatura";
    }
    
    @GetMapping("/faturas/venda/{idVenda}")
    public String verFaturaPorVenda(@PathVariable Integer idVenda) {
        Fatura fatura = faturaRepository.findByVenda_IdVenda(idVenda).orElse(null);

        if (fatura == null) {
            return "redirect:/cliente/perfil?faturaNaoEncontrada";
        }

        return "redirect:/faturas/" + fatura.getIdFatura();
    }

    @GetMapping("/faturas/{id}/download")
    public ResponseEntity<byte[]> downloadFatura(@PathVariable Integer id) {
        Fatura fatura = faturaRepository.findByIdWithVendaAndCliente(id).orElse(null);

        if (fatura == null) {
            return ResponseEntity.notFound().build();
        }

        Venda venda = fatura.getVenda();
        List<ItemVenda> itens = itemVendaRepository.findByVendaWithProduto(venda);

        StringBuilder conteudo = new StringBuilder();

        conteudo.append("FATURA BOOSTMODE\n");
        conteudo.append("============================\n\n");
        conteudo.append("Fatura nº: ").append(fatura.getIdFatura()).append("\n");
        conteudo.append("Data: ").append(fatura.getDataEmissao()).append("\n");
        conteudo.append("Cliente: ").append(venda.getCliente().getNome()).append("\n\n");

        conteudo.append("Itens:\n");

        for (ItemVenda item : itens) {
            conteudo.append("- ")
                    .append(item.getProduto().getNome())
                    .append(" | Quantidade: ")
                    .append(item.getQuantidade())
                    .append(" | Preço unitário: ")
                    .append(item.getPrecoUnitario())
                    .append(" € | Subtotal: ")
                    .append(item.getSubtotal())
                    .append(" €\n");
        }

        conteudo.append("\nTotal: ").append(fatura.getTotal()).append(" €\n");

        byte[] bytes = conteudo.toString().getBytes(StandardCharsets.UTF_8);

        ContentDisposition contentDisposition = ContentDisposition
                .attachment()
                .filename("fatura-" + id + ".txt")
                .build();

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, contentDisposition.toString())
                .contentType(MediaType.TEXT_PLAIN)
                .body(bytes);
    }
}