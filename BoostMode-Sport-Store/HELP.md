# Guia de Instalação e Execução do Projeto

Este guia explica como preparar o ambiente, iniciar a aplicação com Docker e resolver problemas comuns.

O projeto usa **Docker** para executar a aplicação Spring Boot e a base de dados MySQL de forma consistente, sem exigir a instalação manual de todos os componentes no computador.

---

## 1. Pré-requisitos

Antes de começar, confirme que tem instalado:

- **Docker Desktop**
- Opcionalmente, **Git**, caso queira clonar o projeto a partir de um repositório

### Instalar o Docker Desktop

1. Aceda ao site oficial do Docker:  
   https://www.docker.com/products/docker-desktop/

2. Escolha a versão para o seu sistema operativo:
   - Windows
   - macOS
   - Linux

3. Instale o Docker Desktop seguindo as instruções do instalador.

4. Abra o Docker Desktop e deixe-o em execução em segundo plano.

Para confirmar que o Docker está instalado corretamente, abra o terminal e execute:

```bash
docker --version
docker compose version
```

> Nota: Em versões recentes do Docker, o comando recomendado é `docker compose`. Em alguns sistemas, também pode funcionar `docker-compose`.

---

## 2. Obter o projeto

Pode obter o projeto de duas formas.

### Opção A: Projeto em ZIP

1. Extraia o ficheiro ZIP para uma pasta fácil de encontrar.
2. Abra essa pasta no terminal.

### Opção B: Clonar com Git

No terminal, vá para a pasta onde guarda os seus projetos e execute:

```bash
git clone <ENDERECO_DO_REPOSITORIO_AQUI>
cd <NOME_DA_PASTA_DO_PROJETO>
```

---

## 3. Estrutura esperada do projeto

Na pasta principal do projeto devem existir ficheiros semelhantes a estes:

```text
Dockerfile
docker-compose.yml
pom.xml
src/
db/
HELP.md
```

A pasta `db/` deve conter os scripts SQL usados para criar e preencher a base de dados.

Exemplo:

```text
db/
├── 01-init.sql
└── 02-populate.sql
```

---

## 4. Configuração do Docker Compose

O ficheiro `docker-compose.yml` define dois serviços principais:

- `mysql-db`: base de dados MySQL
- `spring-app`: aplicação Spring Boot

Exemplo recomendado de configuração:

```yaml
services:
  mysql-db:
    image: mysql:8.0
    container_name: mysql-database
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: sports_store
    ports:
      - "3306:3306"
    volumes:
      - db-data:/var/lib/mysql
      - ./db:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h localhost -u root -ppassword"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    restart: unless-stopped

  spring-app:
    build: .
    container_name: spring-java
    ports:
      - "8080:8080"
    depends_on:
      mysql-db:
        condition: service_healthy
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql-db:3306/sports_store?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Europe/Lisbon
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: password
      SPRING_JPA_HIBERNATE_DDL_AUTO: none
      SPRING_JPA_SHOW_SQL: "true"
      SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT: org.hibernate.dialect.MySQLDialect
    restart: unless-stopped

volumes:
  db-data:
```

### Nota importante sobre os scripts SQL

Se a pasta `db/` contém vários ficheiros `.sql`, a forma mais simples é mapear a pasta inteira:

```yaml
- ./db:/docker-entrypoint-initdb.d
```

Assim, o MySQL executa automaticamente os ficheiros `.sql` quando a base de dados é criada pela primeira vez.

Se quiser mapear ficheiros individualmente, use este formato:

```yaml
- ./db/01-init.sql:/docker-entrypoint-initdb.d/01-init.sql
- ./db/02-populate.sql:/docker-entrypoint-initdb.d/02-populate.sql
```

Evite mapear a pasta `db` diretamente para nomes de ficheiros, como neste exemplo incorreto:

```yaml
- ./db:/docker-entrypoint-initdb.d/01-init.sql
- ./db:/docker-entrypoint-initdb.d/02-populate.sql
```

---

## 5. Iniciar o projeto

Na pasta principal do projeto, execute:

```bash
docker compose up --build -d
```

Se o seu sistema usar o comando antigo, execute:

```bash
docker-compose up --build -d
```

Este comando:

- constrói a aplicação Spring Boot;
- inicia o MySQL;
- inicia a aplicação;
- deixa os serviços a correr em segundo plano.

A primeira execução pode demorar alguns minutos.

---

## 6. Verificar se os serviços estão ativos

Execute:

```bash
docker compose ps
```

ou:

```bash
docker-compose ps
```

Deve ver os serviços `mysql-db` e `spring-app` com estado semelhante a `Up` ou `running`.

---

## 7. Aceder à aplicação

Quando os serviços estiverem ativos, abra o navegador e aceda a:

```text
http://localhost:8080
```

---

## 8. Parar o projeto

Para parar os containers sem apagar dados:

```bash
docker compose stop
```

ou:

```bash
docker-compose stop
```

---

## 9. Parar e remover os containers

Para parar e remover os containers e redes criadas pelo Docker Compose:

```bash
docker compose down
```

ou:

```bash
docker-compose down
```

Os dados da base de dados continuam guardados no volume Docker.

---

## 10. Recriar a base de dados do zero

Se quiser apagar os dados existentes e voltar a executar os scripts SQL da pasta `db/`, use:

```bash
docker compose down -v
docker compose up --build -d
```

ou:

```bash
docker-compose down -v
docker-compose up --build -d
```

> Atenção: o parâmetro `-v` apaga o volume da base de dados. Todos os dados guardados serão removidos.

---

## 11. Comandos úteis

### Ver logs de todos os serviços

```bash
docker compose logs -f
```

### Ver logs da aplicação Spring Boot

```bash
docker compose logs -f spring-app
```

### Ver logs da base de dados MySQL

```bash
docker compose logs -f mysql-db
```

### Ver containers ativos

```bash
docker ps
```

### Ver todos os containers, incluindo parados

```bash
docker ps -a
```

### Ver imagens Docker existentes

```bash
docker images
```

---

## 12. Problemas comuns

### Erro: `docker-compose: command not found`

Possíveis causas:

- Docker Desktop não está instalado;
- Docker Desktop não está aberto;
- o sistema usa `docker compose` em vez de `docker-compose`.

Tente:

```bash
docker compose version
```

Se não funcionar, reinicie o Docker Desktop ou reinstale-o.

---

### A aplicação não abre em `http://localhost:8080`

Verifique se os containers estão ativos:

```bash
docker compose ps
```

Veja também os logs da aplicação:

```bash
docker compose logs -f spring-app
```

Possíveis causas:

- a aplicação ainda está a iniciar;
- ocorreu erro na ligação ao MySQL;
- a porta `8080` já está a ser usada por outro programa.

---

### Erro na porta `3306`

A porta `3306` pode já estar ocupada por outro MySQL instalado no computador.

Soluções possíveis:

1. Parar o outro MySQL;
2. Alterar a porta externa no `docker-compose.yml`.

Exemplo:

```yaml
ports:
  - "3307:3306"
```

Neste caso, dentro do Docker a aplicação continua a usar `mysql-db:3306`.

---

### Os scripts SQL não foram executados

Os scripts em `/docker-entrypoint-initdb.d` só são executados quando a base de dados é criada pela primeira vez.

Se já existir um volume `db-data`, os scripts não voltam a correr automaticamente.

Para forçar a recriação:

```bash
docker compose down -v
docker compose up --build -d
```

---

### Erros durante o `docker compose up`

Veja os logs:

```bash
docker compose logs -f
```

Leia a primeira mensagem de erro relevante. Normalmente, os problemas estão relacionados com:

- Docker Desktop fechado;
- portas ocupadas;
- erro nos scripts SQL;
- falha na ligação entre Spring Boot e MySQL;
- configuração incorreta no `docker-compose.yml`.

---

## 13. Referências úteis

- Documentação oficial do Maven:  
  https://maven.apache.org/guides/index.html

- Spring Boot Maven Plugin:  
  https://docs.spring.io/spring-boot/3.4.5/maven-plugin

- Spring Data JPA:  
  https://docs.spring.io/spring-boot/3.4.5/reference/data/sql.html#data.sql.jpa-and-spring-data

- Spring Security:  
  https://docs.spring.io/spring-boot/3.4.5/reference/web/spring-security.html

- Thymeleaf:  
  https://docs.spring.io/spring-boot/3.4.5/reference/web/servlet.html#web.servlet.spring-mvc.template-engines

- Spring Web:  
  https://docs.spring.io/spring-boot/3.4.5/reference/web/servlet.html

- Guia Spring: Accessing Data with JPA:  
  https://spring.io/guides/gs/accessing-data-jpa/

- Guia Spring: Accessing Data with MySQL:  
  https://spring.io/guides/gs/accessing-data-mysql/

- Guia Spring: Securing a Web Application:  
  https://spring.io/guides/gs/securing-web/

- Guia Spring: Serving Web Content with Spring MVC:  
  https://spring.io/guides/gs/serving-web-content/

---

## 14. Resumo rápido

Para iniciar o projeto pela primeira vez:

```bash
docker compose up --build -d
```

Para verificar se está a correr:

```bash
docker compose ps
```

Para abrir a aplicação:

```text
http://localhost:8080
```

Para parar:

```bash
docker compose stop
```

Para apagar a base de dados e recriar tudo:

```bash
docker compose down -v
docker compose up --build -d
```
