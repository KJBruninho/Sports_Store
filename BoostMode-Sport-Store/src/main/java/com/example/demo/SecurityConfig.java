package com.example.demo;

import com.example.demo.models.LogAcesso;
import com.example.demo.models.User;
import com.example.demo.repositories.LogAcessoRepository;
import com.example.demo.repositories.UserRepository;

import java.time.LocalDateTime;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    private static final String EMAIL_REGEX =
            "^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$";

    @Autowired
    private UserDetailsService userDetailsService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private LogAcessoRepository logAcessoRepository;

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();

        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());

        return authProvider;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authenticationProvider(authenticationProvider())

            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    "/",
                    "/catalogo",
                    "/produto/**",
                    "/categorias/**",
                    "/signup",
                    "/login",
                    "/css/**",
                    "/js/**",
                    "/img/**",
                    "/favicon.ico"
                ).permitAll()

                .requestMatchers("/admin/**").hasRole("ADMIN")

                .requestMatchers(
                    "/cliente/**",
                    "/carrinho/**",
                    "/favoritos/**",
                    "/checkout/**",
                    "/faturas/**"
                ).hasRole("CLIENTE")

                .anyRequest().authenticated()
            )

            .formLogin(form -> form
                .loginPage("/login")
                .loginProcessingUrl("/login")
                .usernameParameter("email")
                .passwordParameter("password")
                .successHandler(successHandler())
                .failureHandler((request, response, exception) -> {
                    String emailRecebido = request.getParameter("email");
                    String emailNormalizado = normalizarEmail(emailRecebido);

                    String resultado = obterResultadoLoginFalhado(emailNormalizado, exception);

                    registarLogAcesso(emailNormalizado, resultado);

                    response.sendRedirect("/login?erro=" + resultado);
                })
                .permitAll()
            )

            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login?logout")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
                .permitAll()
            )

            .exceptionHandling(ex -> ex
                .accessDeniedPage("/error_page")
            )

            .csrf(csrf -> csrf.disable());

        return http.build();
    }

    private AuthenticationSuccessHandler successHandler() {
        return (request, response, authentication) -> {
            String email = normalizarEmail(authentication.getName());

            registarLogAcesso(email, "SUCESSO");

            Set<String> roles = AuthorityUtils.authorityListToSet(authentication.getAuthorities());

            if (roles.contains("ROLE_ADMIN")) {
                response.sendRedirect("/admin/dashboard");
                return;
            }

            if (roles.contains("ROLE_CLIENTE")) {
                response.sendRedirect("/");
                return;
            }

            response.sendRedirect("/login");
        };
    }

    private String obterResultadoLoginFalhado(String email, Exception exception) {
        if (email == null || email.isBlank() || !email.matches(EMAIL_REGEX)) {
            return "EMAIL_INVALIDO";
        }

        User user = userRepository.findByEmail(email);

        if (user == null) {
            return "EMAIL_INEXISTENTE";
        }

        if (exception instanceof DisabledException) {
            return "CONTA_BLOQUEADA";
        }

        if (exception instanceof UsernameNotFoundException) {
            return "EMAIL_INEXISTENTE";
        }

        if (exception instanceof BadCredentialsException) {
            return "PASSWORD_INCORRETA";
        }

        return "PASSWORD_INCORRETA";
    }

    private void registarLogAcesso(String email, String resultado) {
        LogAcesso log = new LogAcesso();

        User user = null;

        if (email != null && !email.isBlank() && email.matches(EMAIL_REGEX)) {
            user = userRepository.findByEmail(email);
        }

        log.setUser(user);
        log.setEmailTentado(email);
        log.setResultado(resultado);
        log.setDataTentativa(LocalDateTime.now());

        logAcessoRepository.save(log);
    }

    private String normalizarEmail(String email) {
        if (email == null) {
            return "";
        }

        return email.trim().toLowerCase();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}