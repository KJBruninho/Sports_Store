package com.example.demo.controllers;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.example.demo.models.Cliente;
import com.example.demo.models.Estado;
import com.example.demo.models.User;
import com.example.demo.repositories.CategoriaRepository;
import com.example.demo.repositories.ClienteRepository;
import com.example.demo.repositories.EstadoRepository;
import com.example.demo.repositories.ItemVendaRepository;
import com.example.demo.repositories.ProdutoRepository;
import com.example.demo.repositories.UserRepository;

@Controller
public class MainController {
	
	private final UserRepository userRepository;
	private final EstadoRepository estadoRepository;
	private final ClienteRepository clienteRepository;
	private final ProdutoRepository produtoRepository;
	private final ItemVendaRepository itemVendaRepository;
	private final CategoriaRepository categoriaRepository;

	private final PasswordEncoder passwordEncoder;

	public MainController(UserRepository userRepository,  EstadoRepository estadoRepository, ClienteRepository clienteRepository, ProdutoRepository produtoRepository, CategoriaRepository categoriaRepository, ItemVendaRepository itemVendaRepository, PasswordEncoder passwordEncoder) {
	    this.userRepository = userRepository;
	    this.passwordEncoder = passwordEncoder;
	    this.estadoRepository = estadoRepository;
	    this.clienteRepository = clienteRepository;
	    this.produtoRepository = produtoRepository;
	    this.itemVendaRepository = itemVendaRepository;
	    this.categoriaRepository = categoriaRepository;
	}

    @GetMapping("/")
    public String index(Model model) {

    	Integer totalStock = produtoRepository.getTotalStock();
    	Long clientesAtivos = clienteRepository.countClientesAtivos();
        Double total = itemVendaRepository.somaTotalPrecosUnitarios();
        Long totalVendidos = itemVendaRepository.totalProdutosVendidos();

	    if(totalVendidos == null) {
	    	totalVendidos = 0L;
	    }
        if (total == null) {
            total = 0.0;
        }
        
	    if (totalStock == null) {
	        totalStock = 0;
	    }

	    if (clientesAtivos == null) {
	        clientesAtivos = 0L;
	    }
	    
	    model.addAttribute("produtosDestaque", produtoRepository.findTop8ProdutosMaisVendidos());
	    model.addAttribute("categoriasMaisVendidas", categoriaRepository.findTop8CategoriasMaisVendidas());
        model.addAttribute("totalPrecos", total);
	    model.addAttribute("totalPrecos", total);
	    model.addAttribute("totalStock", totalStock);
	    model.addAttribute("clientesAtivos", clientesAtivos);
	    model.addAttribute("totalVendidos", totalVendidos);

        return "sports_equipment_store";
    }

    @GetMapping("/login")
    public String login() {
        return "login_page";
    }

    @GetMapping("/signup")
    public String signupPage() {
        return "signup";
    }
    
    @PostMapping("/signup")
    public String signup(@RequestParam String email,
                         @RequestParam String password,
                         @RequestParam String nome,
                         @RequestParam(required = false) String morada,
                         Model model) {

        if (userRepository.findByEmail(email) != null) {
            model.addAttribute("erro", "Este email já está registado.");
            return "signup";
        }

        Estado estadoAtivo = estadoRepository.findByNome("ATIVO");

        if (estadoAtivo == null) {
            model.addAttribute("erro", "Estado ATIVO não existe na base de dados.");
            return "signup";
        }

        User user = new User();
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));
        user.setRole("CLIENTE");
        user.setEstado(estadoAtivo);

        userRepository.save(user);

        Cliente cliente = new Cliente();
        cliente.setNome(nome);
        cliente.setMorada(morada);
        cliente.setUser(user);

        clienteRepository.save(cliente);

        return "redirect:/login?registered";
    }
}