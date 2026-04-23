-- Criar a base de dados
CREATE DATABASE IF NOT EXISTS projetosd;
USE projetosd;

-- Tabela user
CREATE TABLE IF NOT EXISTS user (
    idUser INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50)
);

-- Tabela Cliente
CREATE TABLE IF NOT EXISTS cliente (
    idCliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    morada VARCHAR(255),
    idUser INT,
    FOREIGN KEY (idUser) REFERENCES user(idUser)
);

-- Tabela Categoria
CREATE TABLE IF NOT EXISTS categoria (
    idCategoria INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL
);

-- Tabela Produto
CREATE TABLE IF NOT EXISTS produto (
    idProduto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    idCategoria INT,
    FOREIGN KEY (idCategoria) REFERENCES categoria(idCategoria)
);

-- Tabela Venda
CREATE TABLE IF NOT EXISTS venda (
    idVenda INT PRIMARY KEY AUTO_INCREMENT,
    data DATETIME NOT NULL,
    idCliente INT,
    FOREIGN KEY (idCliente) REFERENCES cliente(idCliente)
);

-- Tabela Fatura
CREATE TABLE IF NOT EXISTS fatura (
    idFatura INT PRIMARY KEY AUTO_INCREMENT,
    idVenda INT UNIQUE NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    dataEmissao DATETIME NOT NULL,
    FOREIGN KEY (idVenda) REFERENCES venda(idVenda)
);

-- Tabela ItemVenda
CREATE TABLE IF NOT EXISTS itemVenda (
    idItem INT PRIMARY KEY AUTO_INCREMENT,
    idVenda INT NOT NULL,
    idProduto INT NOT NULL,
    quantidade INT NOT NULL,
    precoUnitario DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (idVenda) REFERENCES venda(idVenda),
    FOREIGN KEY (idProduto) REFERENCES produto(idProduto)
);

-- #############################################
-- # INSERÇÃO DE DADOS DE EXEMPLO (SEEDING)
-- #############################################

-- Inserir dados na tabela user
INSERT INTO user (email, password, role) VALUES
('admin@example.com', 'senha_hashed_aqui_para_admin', 'ADMIN'),
('user1@example.com', 'senha_hashed_aqui_para_user1', 'USER'),
('user2@example.com', 'senha_hashed_aqui_para_user2', 'USER');

-- Inserir dados na tabela categoria
INSERT INTO categoria (nome) VALUES
('Futebol'),
('Fitness'),
('Natação'),
('Running'),
('Ciclismo'),
('Tênis');

-- Inserir dados na tabela cliente (depende de 'user')
INSERT INTO cliente (nome, morada, idUser) VALUES
('João Silva', 'Rua A, 123', 2), -- idUser 2 (user1@example.com)
('Maria Santos', 'Av. B, 456', 3), -- idUser 3 (user2@example.com)
('Carlos Pereira', 'Travessa C, 789', NULL); -- Cliente sem usuário associado

-- Inserir dados na tabela produto (depende de 'categoria')
INSERT INTO produto (nome, descricao, preco, stock, idCategoria) VALUES
('Bola de Futebol Oficial', 'Bola de futebol para jogo em campo', 79.99, 50, 1), -- Categoria Futebol
('Halteres Ajustáveis 10kg', 'Conjunto de halteres para treino em casa', 120.00, 30, 2), -- Categoria Fitness
('Fato de Banho Competição', 'Fato de banho para alta performance', 150.00, 20, 3), -- Categoria Natação
('Tênis de Corrida Leve', 'Tênis ideal para corridas diárias', 99.50, 40, 4), -- Categoria Running
('Bicicleta de Montanha Aro 29', 'Bicicleta robusta para trilhas', 750.00, 10, 5), -- Categoria Ciclismo
('Raquete de Tênis Profissional', 'Raquete de alta qualidade para jogadores avançados', 200.00, 15, 6), -- Categoria Tênis
('Caneleiras Futebol', 'Proteção para pernas', 25.00, 100, 1); -- Categoria Futebol

-- Inserir dados na tabela venda (depende de 'cliente')
INSERT INTO venda (data, idCliente) VALUES
('2025-05-27 10:00:00', 1), -- Venda do João Silva
('2025-05-27 11:30:00', 2), -- Venda da Maria Santos
('2025-05-28 09:00:00', 1); -- Outra venda do João Silva

-- Inserir dados na tabela fatura (depende de 'venda')
INSERT INTO fatura (idVenda, total, dataEmissao) VALUES
(1, 199.99, '2025-05-27 10:15:00'),
(2, 120.00, '2025-05-27 11:45:00');

-- Inserir dados na tabela itemVenda (depende de 'venda' e 'produto')
INSERT INTO itemVenda (idVenda, idProduto, quantidade, precoUnitario) VALUES
(1, 1, 1, 79.99),  -- Bola de Futebol na Venda 1
(1, 7, 1, 25.00),  -- Caneleiras Futebol na Venda 1
(2, 2, 1, 120.00), -- Halteres Ajustáveis na Venda 2
(3, 4, 2, 99.50);  -- Tênis de Corrida (2 unidades) na Venda 3