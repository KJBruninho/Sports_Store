package com.example.demo.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @GetMapping("/dashboard")
    public String dashboard() {
        return "admin-dashboard";
    }

    @GetMapping("/users")
    public String users() {
        return "admin-users";
    }

    @GetMapping("/reports")
    public String reports() {
        return "admin-reports";
    }

    @GetMapping("/settings")
    public String settings() {
        return "admin-settings";
    }
}


