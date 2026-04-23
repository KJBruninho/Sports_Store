package com.example.demo.controllers;

import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
public class CustomErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request, Model model) {
        
        // Obter código de status HTTP
        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        Integer statusCode = null;
        if (status != null) {
            statusCode = Integer.valueOf(status.toString());
        }

        // Obter mensagem de erro
        String errorMessage = (String) request.getAttribute(RequestDispatcher.ERROR_MESSAGE);
        
        // Obter URL que causou o erro
        String errorPath = (String) request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI);
        
        // Obter exceção se disponível
        Throwable exception = (Throwable) request.getAttribute(RequestDispatcher.ERROR_EXCEPTION);
        
        // Obter tipo de exceção
        String exceptionType = null;
        if (exception != null) {
            exceptionType = exception.getClass().getSimpleName();
        }

        // Timestamp atual
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));

        // Definir título e mensagem baseados no código de status
        String errorTitle = "Erro";
        String userMessage = "Ocorreu um erro inesperado.";

        if (statusCode != null) {
            switch (statusCode) {
                case 400:
                    errorTitle = "Pedido Inválido";
                    userMessage = "O pedido enviado não é válido. Verifique os dados e tente novamente.";
                    break;
                case 401:
                    errorTitle = "Não Autorizado";
                    userMessage = "Precisa de fazer login para aceder a esta página.";
                    break;
                case 403:
                    errorTitle = "Acesso Negado";
                    userMessage = "Não tem permissão para aceder a esta página.";
                    break;
                case 404:
                    errorTitle = "Página Não Encontrada";
                    userMessage = "A página que procura não foi encontrada. Pode ter sido removida ou o endereço está incorreto.";
                    break;
                case 405:
                    errorTitle = "Método Não Permitido";
                    userMessage = "O método utilizado não é permitido para este recurso.";
                    break;
                case 500:
                    errorTitle = "Erro Interno do Servidor";
                    userMessage = "Ocorreu um erro interno no servidor. A nossa equipa foi notificada.";
                    break;
                case 502:
                    errorTitle = "Bad Gateway";
                    userMessage = "Erro de comunicação com o servidor. Tente novamente mais tarde.";
                    break;
                case 503:
                    errorTitle = "Serviço Indisponível";
                    userMessage = "O serviço está temporariamente indisponível. Tente novamente mais tarde.";
                    break;
                default:
                    errorTitle = "Erro " + statusCode;
                    userMessage = "Ocorreu um erro inesperado. Código: " + statusCode;
            }
        }

        // Stack trace (apenas em desenvolvimento - pode ser controlado por propriedade)
        String stackTrace = null;
        if (exception != null) {
            // Em produção, pode querer omitir o stack trace por segurança
            // Verificar se está em modo de desenvolvimento
            boolean isDevelopment = isDevMode(request);
            if (isDevelopment) {
                stackTrace = getStackTraceAsString(exception);
            }
        }

        // Adicionar atributos ao modelo
        model.addAttribute("status", statusCode);
        model.addAttribute("error", errorTitle);
        model.addAttribute("message", userMessage);
        model.addAttribute("path", errorPath);
        model.addAttribute("timestamp", timestamp);
        model.addAttribute("exception", exceptionType);
        model.addAttribute("trace", stackTrace);
        model.addAttribute("originalMessage", errorMessage);

        // Log do erro para debugging
        logError(statusCode, errorPath, exception, request);

        return "error_page_styled";
    }

    /**
     * Verifica se está em modo de desenvolvimento
     */
    private boolean isDevMode(HttpServletRequest request) {
        // Pode verificar propriedades do Spring ou headers
        String serverName = request.getServerName();
        return "localhost".equals(serverName) || "127.0.0.1".equals(serverName);
    }

    /**
     * Converte stack trace para string
     */
    private String getStackTraceAsString(Throwable exception) {
        if (exception == null) return null;
        
        StringBuilder sb = new StringBuilder();
        sb.append(exception.getClass().getSimpleName())
          .append(": ")
          .append(exception.getMessage())
          .append("\n");
        
        // Adicionar apenas as primeiras 10 linhas do stack trace
        StackTraceElement[] elements = exception.getStackTrace();
        int maxLines = Math.min(10, elements.length);
        
        for (int i = 0; i < maxLines; i++) {
            sb.append("    at ").append(elements[i].toString()).append("\n");
        }
        
        if (elements.length > maxLines) {
            sb.append("    ... e mais ").append(elements.length - maxLines).append(" linhas");
        }
        
        return sb.toString();
    }

    /**
     * Log do erro para monitorização
     */
    private void logError(Integer statusCode, String path, Throwable exception, HttpServletRequest request) {
        String userAgent = request.getHeader("User-Agent");
        String remoteAddr = request.getRemoteAddr();
        String method = request.getMethod();
        
        System.err.println("=== ERRO CAPTURADO ===");
        System.err.println("Status: " + statusCode);
        System.err.println("Path: " + path);
        System.err.println("Method: " + method);
        System.err.println("IP: " + remoteAddr);
        System.err.println("User-Agent: " + userAgent);
        System.err.println("Timestamp: " + LocalDateTime.now());
        
        if (exception != null) {
            System.err.println("Exception: " + exception.getClass().getSimpleName());
            System.err.println("Message: " + exception.getMessage());
            exception.printStackTrace();
        }
        System.err.println("=====================");
    }
}