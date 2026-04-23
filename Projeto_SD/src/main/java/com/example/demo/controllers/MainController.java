package com.example.demo.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import com.example.demo.models.User;
import com.example.demo.repositories.UserRepository;
import com.example.demo.models.Produto;
import com.example.demo.repositories.ProdutoRepository;
import org.springframework.ui.Model;
import java.util.List;

@Controller
public class MainController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ProdutoRepository produtoRepository;

    // BCryptPasswordEncoder para encriptação
    private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @GetMapping({"/", "/login"})
    public String loginPage() {
        return "index"; // página de login
    }

    @GetMapping("/home")
    public String home(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
            String email = auth.getName();

            User user = userRepository.findByEmail(email);
            if (user != null) {
                if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                    // Redireciona para a página admin
                    return "redirect:/admin/dashboard";
                } else {
                    // Cliente normal mostra o dashboard com produtos
                    List<Produto> produtos = produtoRepository.findAll();
                    model.addAttribute("produtos", produtos);
                    model.addAttribute("email", email);
                    return "dashboard";
                }
            }
        }
        // Se não autenticado, vai para login
        return "redirect:/login";
    }

    @GetMapping("/signup")
    public String signupPage() {
        return "signup"; // Mostra o formulário de registo
    }

    // Força role CLIENTE na criação do utilizador
    @PostMapping("/signup")
    public String signup(@RequestParam String email,
                         @RequestParam String password) {
        User user = new User();
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));
        user.setRole("CLIENTE");

        userRepository.save(user);

        return "index"; // ou redirecionar para login
    }

    // Método para servir a página admin dashboard
    @GetMapping("/admin/dashboard")
    public String adminDashboard() {
        return "admin-dashboard"; // nome do ficheiro html Thymeleaf
    }

}
