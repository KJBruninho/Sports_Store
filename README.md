# 🏅 Sports Store

Uma plataforma de e-commerce moderna e responsiva dedicada à venda de equipamentos e artigos desportivos. O projeto foca-se em oferecer uma experiência de utilizador fluida, desde a navegação no catálogo até ao processo de finalização de compra.

## 🚀 Funcionalidades

* Catálogo de Produtos: Visualização dinâmica de artigos com filtragem por categorias.
* Gestão de Carrinho: Adicionar, remover e atualizar quantidades em tempo real.
* Pesquisa Avançada: Localização rápida de produtos por nome ou descrição.
* Checkout Integrado: Fluxo simplificado para finalização de encomendas.
* Design Responsivo: Interface otimizada para Desktop, Tablets e Mobile.
* Painel Administrativo: Gestão de inventário, produtos e monitorização de pedidos.

## 🛠️ Tecnologias Utilizadas

* Frontend: HTML5, CSS3, JavaScript
* Backend: Spring Maven
* Base de Dados: SQL Server (MSSQL)
* Autenticação: JWT (JSON Web Tokens)

## 📦 Instalação e Configuração

1. Clonar o repositório:
git clone https://github.com/KJBruninho/Sports_Store.git

2. Aceder à pasta do projeto:
cd Sports_Store

3. Instalar as dependências:
npm install

4. Configurar Variáveis de Ambiente:
Cria um ficheiro .env na raiz do projeto com o seguinte conteúdo:

DB_USER=teu_utilizador
DB_PASSWORD=tua_senha
DB_SERVER=localhost
DB_DATABASE=SportsStoreDB
PORT=3000

5. Executar a aplicação:
npm start

## 📂 Estrutura do Projeto

* src/controllers - Lógica de rotas e dados.
* src/models - Modelos do SQL Server.
* src/routes - Endpoints da API.
* src/public - Frontend (HTML, CSS, JS).
* server.js - Ponto de entrada.

## 🤝 Contribuição

1. Faz um Fork do projeto.
2. Cria uma Branch (git checkout -b feature/NovaFeature).
3. Faz Commit (git commit -m 'Adiciona NovaFeature').
4. Faz Push (git push origin feature/NovaFeature).
5. Abre um Pull Request.

---
Desenvolvido por KJBruninho (https://github.com/KJBruninho)
