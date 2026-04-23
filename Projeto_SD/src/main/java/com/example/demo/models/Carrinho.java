package com.example.demo.models;

import java.util.ArrayList;
import java.util.List;

public class Carrinho {

    private List<Produto> itens = new ArrayList<>();
    private double total = 0.0;

    public List<Produto> getItens() {
        return itens;
    }

    public double getTotal() {
        return total;
    }

    // Adiciona um produto ao carrinho e atualiza o total
    public void adicionarProduto(Produto produto) {
        itens.add(produto);
        total += produto.getPreco();  // Atualiza o valor total
    }

    // Remove um produto do carrinho e atualiza o total
    public void removerProduto(Produto produto) {
        if (itens.remove(produto)) {
            total -= produto.getPreco();  // Atualiza o valor total
        }
    }

    // Limpa todos os itens do carrinho e zera o total
    public void limpar() {
        itens.clear();
        total = 0.0;
    }

    // Método para obter a quantidade total de itens no carrinho
    public int getQtdItens() {
        return itens.size();
    }

    // Método para atualizar o total caso haja alterações
    public void atualizarTotal() {
        total = 0.0;
        for (Produto produto : itens) {
            total += produto.getPreco();
        }
    }
}
