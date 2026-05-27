package com.example.demo.controllers;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.repositories.AdminRelatorioRepository;

@Controller
public class AdminRelatoriosController {

    private final AdminRelatorioRepository adminRelatorioRepository;

    public AdminRelatoriosController(AdminRelatorioRepository adminRelatorioRepository) {
        this.adminRelatorioRepository = adminRelatorioRepository;
    }

    @GetMapping("/admin/relatorios")
    public String relatorios(Model model) {
        model.addAttribute("dados", carregarDadosRelatorio());
        return "admin-relatorios";
    }

    @GetMapping("/admin/relatorios/dados")
    @ResponseBody
    public RelatorioDashboard dadosRelatorios() {
        return carregarDadosRelatorio();
    }

    private RelatorioDashboard carregarDadosRelatorio() {
        Kpis kpis = obterKpis();

        return new RelatorioDashboard(
                kpis.faturacaoTotal(),
                kpis.totalVendas(),
                kpis.totalProdutosVendidos(),
                kpis.clientesAtivos(),
                kpis.ticketMedio(),
                obterProdutosMaisVendidos(),
                obterCategoriasMaisVendidas(),
                obterVendasUltimos7Dias(),
                obterVendasRecentes(),
                obterLogsAcessoRecentes()
        );
    }

    private Kpis obterKpis() {
        List<Object[]> resultados = adminRelatorioRepository.buscarKpis();

        if (resultados == null || resultados.isEmpty()) {
            return new Kpis(
                    BigDecimal.ZERO,
                    0L,
                    0L,
                    0L,
                    BigDecimal.ZERO
            );
        }

        Object[] row = resultados.get(0);

        return new Kpis(
                toBigDecimal(row[0]),
                toLong(row[1]),
                toLong(row[2]),
                toLong(row[3]),
                toBigDecimal(row[4])
        );
    }

    private List<ProdutoVendido> obterProdutosMaisVendidos() {
        List<Object[]> resultados = adminRelatorioRepository.buscarProdutosMaisVendidos();
        List<ProdutoVendido> lista = new ArrayList<>();

        if (resultados == null) {
            return lista;
        }

        for (Object[] row : resultados) {
            lista.add(new ProdutoVendido(
                    toStringValue(row[0]),
                    toLong(row[1]),
                    toBigDecimal(row[2])
            ));
        }

        return lista;
    }

    private List<CategoriaVendida> obterCategoriasMaisVendidas() {
        List<Object[]> resultados = adminRelatorioRepository.buscarCategoriasMaisVendidas();
        List<CategoriaVendida> lista = new ArrayList<>();

        if (resultados == null) {
            return lista;
        }

        for (Object[] row : resultados) {
            lista.add(new CategoriaVendida(
                    toStringValue(row[0]),
                    toLong(row[1]),
                    toBigDecimal(row[2])
            ));
        }

        return lista;
    }

    private List<VendaDia> obterVendasUltimos7Dias() {
        List<Object[]> resultados = adminRelatorioRepository.buscarVendasUltimos7Dias();
        List<VendaDia> lista = new ArrayList<>();

        if (resultados == null) {
            return lista;
        }

        for (Object[] row : resultados) {
            lista.add(new VendaDia(
                    toDateString(row[0]),
                    toLong(row[1]),
                    toBigDecimal(row[2])
            ));
        }

        return lista;
    }

    private List<VendaRecente> obterVendasRecentes() {
        List<Object[]> resultados = adminRelatorioRepository.buscarVendasRecentes();
        List<VendaRecente> lista = new ArrayList<>();

        if (resultados == null) {
            return lista;
        }

        for (Object[] row : resultados) {
            lista.add(new VendaRecente(
                    toLong(row[0]),
                    toStringValue(row[1]),
                    toLocalDateTime(row[2]),
                    toBigDecimal(row[3])
            ));
        }

        return lista;
    }

    private List<LogAcesso> obterLogsAcessoRecentes() {
        List<Object[]> resultados = adminRelatorioRepository.buscarLogsAcessoRecentes();
        List<LogAcesso> lista = new ArrayList<>();

        if (resultados == null) {
            return lista;
        }

        for (Object[] row : resultados) {
            lista.add(new LogAcesso(
                    toLong(row[0]),
                    toStringValue(row[1]),
                    toStringValue(row[2]),
                    toLocalDateTime(row[3]),
                    toStringValue(row[4]),
                    toStringValue(row[5])
            ));
        }

        return lista;
    }

    private Long toLong(Object valor) {
        if (valor == null) {
            return 0L;
        }

        if (valor instanceof Number numero) {
            return numero.longValue();
        }

        try {
            return Long.parseLong(valor.toString());
        } catch (NumberFormatException e) {
            return 0L;
        }
    }

    private BigDecimal toBigDecimal(Object valor) {
        if (valor == null) {
            return BigDecimal.ZERO;
        }

        if (valor instanceof BigDecimal decimal) {
            return decimal;
        }

        if (valor instanceof Number numero) {
            return BigDecimal.valueOf(numero.doubleValue());
        }

        try {
            return new BigDecimal(valor.toString());
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }

    private String toStringValue(Object valor) {
        if (valor == null) {
            return "-";
        }

        return String.valueOf(valor);
    }

    private String toDateString(Object valor) {
        if (valor == null) {
            return "-";
        }

        if (valor instanceof Date date) {
            return date.toLocalDate().toString();
        }

        if (valor instanceof LocalDate localDate) {
            return localDate.toString();
        }

        if (valor instanceof Timestamp timestamp) {
            return timestamp.toLocalDateTime().toLocalDate().toString();
        }

        return String.valueOf(valor);
    }

    private LocalDateTime toLocalDateTime(Object valor) {
        if (valor == null) {
            return null;
        }

        if (valor instanceof Timestamp timestamp) {
            return timestamp.toLocalDateTime();
        }

        if (valor instanceof LocalDateTime localDateTime) {
            return localDateTime;
        }

        if (valor instanceof Date date) {
            return date.toLocalDate().atStartOfDay();
        }

        if (valor instanceof LocalDate localDate) {
            return localDate.atStartOfDay();
        }

        return null;
    }

    private record Kpis(
            BigDecimal faturacaoTotal,
            Long totalVendas,
            Long totalProdutosVendidos,
            Long clientesAtivos,
            BigDecimal ticketMedio
    ) {}

    public record RelatorioDashboard(
            BigDecimal faturacaoTotal,
            Long totalVendas,
            Long totalProdutosVendidos,
            Long clientesAtivos,
            BigDecimal ticketMedio,
            List<ProdutoVendido> produtosMaisVendidos,
            List<CategoriaVendida> categoriasMaisVendidas,
            List<VendaDia> vendasPorDia,
            List<VendaRecente> vendasRecentes,
            List<LogAcesso> logsAcesso
    ) {}

    public record ProdutoVendido(
            String nome,
            Long quantidadeVendida,
            BigDecimal totalVendido
    ) {}

    public record CategoriaVendida(
            String nome,
            Long quantidadeVendida,
            BigDecimal totalVendido
    ) {}

    public record VendaDia(
            String dia,
            Long totalVendas,
            BigDecimal faturacao
    ) {}

    public record VendaRecente(
            Long idVenda,
            String cliente,
            LocalDateTime data,
            BigDecimal total
    ) {}

    public record LogAcesso(
            Long idLogAcesso,
            String emailTentado,
            String resultado,
            LocalDateTime dataTentativa,
            String roleUser,
            String estadoUser
    ) {}
}