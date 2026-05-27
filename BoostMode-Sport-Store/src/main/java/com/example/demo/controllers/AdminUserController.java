package com.example.demo.controllers;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.demo.models.Cliente;
import com.example.demo.models.Estado;
import com.example.demo.models.User;
import com.example.demo.repositories.ClienteRepository;
import com.example.demo.repositories.EstadoRepository;
import com.example.demo.repositories.UserRepository;

@Controller
@RequestMapping("/admin")
public class AdminUserController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ClienteRepository clienteRepository;

    @Autowired
    private EstadoRepository estadoRepository;

    @GetMapping("/utilizadores")
    public String listarUtilizadores(Model model) {
        List<User> users = userRepository.findAllWithEstado();
        List<Cliente> clientes = clienteRepository.findAllWithUser();

        Map<Integer, Cliente> clientesPorUser = new HashMap<>();

        for (Cliente cliente : clientes) {
            if (cliente.getUser() != null) {
                clientesPorUser.put(cliente.getUser().getIdUser(), cliente);
            }
        }

        long totalUsers = users.size();
        long totalClientes = users.stream()
                .filter(user -> "CLIENTE".equalsIgnoreCase(user.getRole()))
                .count();

        long totalAdmins = users.stream()
                .filter(user -> "ADMIN".equalsIgnoreCase(user.getRole()))
                .count();

        long totalBloqueados = users.stream()
                .filter(user -> user.getEstado() != null
                        && "BLOQUEADO".equalsIgnoreCase(user.getEstado().getNome()))
                .count();

        model.addAttribute("users", users);
        model.addAttribute("clientesPorUser", clientesPorUser);

        model.addAttribute("totalUsers", totalUsers);
        model.addAttribute("totalClientes", totalClientes);
        model.addAttribute("totalAdmins", totalAdmins);
        model.addAttribute("totalBloqueados", totalBloqueados);

        return "admin-utilizadores";
    }

    @PostMapping("/utilizadores/{id}/bloquear")
    public String bloquearUtilizador(@PathVariable Integer id,
                                     RedirectAttributes redirectAttributes) {
        User user = userRepository.findById(id).orElse(null);

        if (user == null) {
            redirectAttributes.addFlashAttribute("erro", "Utilizador não encontrado.");
            return "redirect:/admin/utilizadores";
        }

        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            redirectAttributes.addFlashAttribute("erro", "Não podes bloquear um administrador.");
            return "redirect:/admin/utilizadores";
        }

        Estado estadoBloqueado = estadoRepository.findByNome("BLOQUEADO");

        if (estadoBloqueado == null) {
            redirectAttributes.addFlashAttribute("erro", "Estado BLOQUEADO não existe na base de dados.");
            return "redirect:/admin/utilizadores";
        }

        user.setEstado(estadoBloqueado);
        userRepository.save(user);

        redirectAttributes.addFlashAttribute("sucesso", "Utilizador bloqueado com sucesso.");
        return "redirect:/admin/utilizadores";
    }

    @PostMapping("/utilizadores/{id}/ativar")
    public String ativarUtilizador(@PathVariable Integer id,
                                   RedirectAttributes redirectAttributes) {
        User user = userRepository.findById(id).orElse(null);

        if (user == null) {
            redirectAttributes.addFlashAttribute("erro", "Utilizador não encontrado.");
            return "redirect:/admin/utilizadores";
        }

        Estado estadoAtivo = estadoRepository.findByNome("ATIVO");

        if (estadoAtivo == null) {
            redirectAttributes.addFlashAttribute("erro", "Estado ATIVO não existe na base de dados.");
            return "redirect:/admin/utilizadores";
        }

        user.setEstado(estadoAtivo);
        userRepository.save(user);

        redirectAttributes.addFlashAttribute("sucesso", "Utilizador ativado com sucesso.");
        return "redirect:/admin/utilizadores";
    }
    
    @PostMapping("/utilizadores/{id}/promover")
    public String promoverParaAdmin(@PathVariable Integer id,
                                    RedirectAttributes redirectAttributes) {
        User user = userRepository.findById(id).orElse(null);

        if (user == null) {
            redirectAttributes.addFlashAttribute("erro", "Utilizador não encontrado.");
            return "redirect:/admin/utilizadores";
        }

        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            redirectAttributes.addFlashAttribute("erro", "Este utilizador já é administrador.");
            return "redirect:/admin/utilizadores";
        }

        user.setRole("ADMIN");
        userRepository.save(user);

        redirectAttributes.addFlashAttribute("sucesso", "Utilizador promovido a administrador.");
        return "redirect:/admin/utilizadores";
    }
    
    @PostMapping("/utilizadores/{id}/despromover")
    public String despromoverParaCliente(@PathVariable Integer id,
                                         RedirectAttributes redirectAttributes) {
        User user = userRepository.findById(id).orElse(null);

        if (user == null) {
            redirectAttributes.addFlashAttribute("erro", "Utilizador não encontrado.");
            return "redirect:/admin/utilizadores";
        }

        if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
            redirectAttributes.addFlashAttribute("erro", "Este utilizador não é administrador.");
            return "redirect:/admin/utilizadores";
        }

        user.setRole("CLIENTE");
        userRepository.save(user);

        redirectAttributes.addFlashAttribute("sucesso", "Administrador convertido para cliente.");
        return "redirect:/admin/utilizadores";
    }
}