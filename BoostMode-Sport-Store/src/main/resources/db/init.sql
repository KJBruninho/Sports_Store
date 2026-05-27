
-- =========================================================
-- SCRIPT 01 - CRIAÇÃO DA BASE DE DADOS
-- BD: sports_store
-- =========================================================

CREATE DATABASE IF NOT EXISTS sports_store;
USE sports_store;

-- =========================================================
-- LIMPEZA DE OBJETOS EXISTENTES
-- =========================================================

DROP VIEW IF EXISTS vw_logs_acesso_recentes;
DROP VIEW IF EXISTS vw_produtos_mais_vendidos;
DROP VIEW IF EXISTS vw_resumo_vendas;
DROP VIEW IF EXISTS vw_vendas_detalhadas;
DROP VIEW IF EXISTS vw_favoritos_detalhados;
DROP VIEW IF EXISTS vw_total_carrinho;
DROP VIEW IF EXISTS vw_carrinho_detalhado;
DROP VIEW IF EXISTS vw_users_cliente_sem_cliente;
DROP VIEW IF EXISTS vw_users_sem_cliente;
DROP VIEW IF EXISTS vw_clientes_com_estado;
DROP VIEW IF EXISTS vw_produtos_com_categoria;

DROP PROCEDURE IF EXISTS sp_adicionar_ao_carrinho;
DROP PROCEDURE IF EXISTS sp_remover_do_carrinho;
DROP PROCEDURE IF EXISTS sp_atualizar_quantidade_carrinho;
DROP PROCEDURE IF EXISTS sp_limpar_carrinho;
DROP PROCEDURE IF EXISTS sp_finalizar_compra;
DROP PROCEDURE IF EXISTS sp_listar_carrinho;
DROP PROCEDURE IF EXISTS sp_listar_vendas_cliente;
DROP PROCEDURE IF EXISTS sp_registar_log_acesso;
DROP PROCEDURE IF EXISTS sp_bloquear_user;
DROP PROCEDURE IF EXISTS sp_ativar_user;
DROP PROCEDURE IF EXISTS sp_pesquisar_produtos;
DROP PROCEDURE IF EXISTS sp_criar_user_cliente;
DROP PROCEDURE IF EXISTS sp_top_8_produtos_mais_vendidos;
DROP PROCEDURE IF EXISTS sp_categoria_mais_vendida;
DROP PROCEDURE IF EXISTS sp_top_9_categorias_mais_vendidas;
DROP PROCEDURE IF EXISTS sp_relatorio_kpis;
DROP PROCEDURE IF EXISTS sp_relatorio_produtos_mais_vendidos;
DROP PROCEDURE IF EXISTS sp_relatorio_categorias_mais_vendidas;
DROP PROCEDURE IF EXISTS sp_relatorio_vendas_ultimos_7_dias;
DROP PROCEDURE IF EXISTS sp_relatorio_vendas_recentes;
DROP PROCEDURE IF EXISTS sp_relatorio_logs_acesso_recentes;
DROP PROCEDURE IF EXISTS sp_remover_categoria;
DROP PROCEDURE IF EXISTS sp_remover_produto;
DROP PROCEDURE IF EXISTS sp_desativar_categoria;
DROP PROCEDURE IF EXISTS sp_desativar_produto;

DROP TRIGGER IF EXISTS trg_cliente_user_role_before_insert;
DROP TRIGGER IF EXISTS trg_cliente_user_role_before_update;
DROP TRIGGER IF EXISTS trg_produto_before_insert;
DROP TRIGGER IF EXISTS trg_produto_before_update;
DROP TRIGGER IF EXISTS trg_carrinho_before_insert;
DROP TRIGGER IF EXISTS trg_carrinho_before_update;
DROP TRIGGER IF EXISTS trg_venda_cliente_ativo;
DROP TRIGGER IF EXISTS trg_item_venda_before_insert;
DROP TRIGGER IF EXISTS trg_fatura_before_insert;
DROP TRIGGER IF EXISTS trg_item_venda_after_insert;
DROP TRIGGER IF EXISTS trg_item_venda_after_update;
DROP TRIGGER IF EXISTS trg_item_venda_after_delete;
DROP TRIGGER IF EXISTS trg_log_acesso_bloquear_user;
DROP TRIGGER IF EXISTS trg_categoria_before_delete;
DROP TRIGGER IF EXISTS trg_produto_before_delete;

DROP TABLE IF EXISTS fatura;
DROP TABLE IF EXISTS item_venda;
DROP TABLE IF EXISTS venda;
DROP TABLE IF EXISTS favorito;
DROP TABLE IF EXISTS carrinho;
DROP TABLE IF EXISTS produto;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS log_acesso;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS estado;

-- =========================================================
-- TABELAS
-- =========================================================

CREATE TABLE estado (
    idEstado INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE `user` (
    idUser INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    idEstado INT NOT NULL,

    CONSTRAINT fk_user_estado
        FOREIGN KEY (idEstado) REFERENCES estado(idEstado)
);

CREATE TABLE cliente (
    idCliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    morada VARCHAR(255),
    idUser INT NOT NULL UNIQUE,

    CONSTRAINT fk_cliente_user
        FOREIGN KEY (idUser) REFERENCES `user`(idUser)
);

CREATE TABLE log_acesso (
    idLogAcesso INT PRIMARY KEY AUTO_INCREMENT,
    idUser INT NULL,
    emailTentado VARCHAR(255) NOT NULL,
    resultado ENUM(
        'SUCESSO',
        'PASSWORD_INCORRETA',
        'EMAIL_INEXISTENTE',
		'EMAIL_INVALIDO',
        'CONTA_BLOQUEADA'
    ) NOT NULL,
    dataTentativa DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_log_user
        FOREIGN KEY (idUser) REFERENCES `user`(idUser)
);

CREATE TABLE categoria (
    idCategoria INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL UNIQUE,
    imagemUrl VARCHAR(500),
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE produto (
    idProduto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    imagemUrl VARCHAR(500),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    idCategoria INT NOT NULL,

    CONSTRAINT fk_produto_categoria
        FOREIGN KEY (idCategoria) REFERENCES categoria(idCategoria)
);

CREATE TABLE carrinho (
    idItemCarrinho INT PRIMARY KEY AUTO_INCREMENT,
    idCliente INT NOT NULL,
    idProduto INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    dataAdicao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_carrinho_cliente
        FOREIGN KEY (idCliente) REFERENCES cliente(idCliente),

    CONSTRAINT fk_carrinho_produto
        FOREIGN KEY (idProduto) REFERENCES produto(idProduto),

    CONSTRAINT uk_carrinho_cliente_produto
        UNIQUE (idCliente, idProduto)
);

CREATE TABLE favorito (
    idFavorito INT PRIMARY KEY AUTO_INCREMENT,
    idCliente INT NOT NULL,
    idProduto INT NOT NULL,
    dataCriacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_favorito_cliente
        FOREIGN KEY (idCliente) REFERENCES cliente(idCliente),

    CONSTRAINT fk_favorito_produto
        FOREIGN KEY (idProduto) REFERENCES produto(idProduto),

    CONSTRAINT uk_favorito_cliente_produto
        UNIQUE (idCliente, idProduto)
);

CREATE TABLE venda (
    idVenda INT PRIMARY KEY AUTO_INCREMENT,
    data DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idCliente INT NOT NULL,

    CONSTRAINT fk_venda_cliente
        FOREIGN KEY (idCliente) REFERENCES cliente(idCliente)
);

CREATE TABLE item_venda (
    idItemVenda INT PRIMARY KEY AUTO_INCREMENT,
    idVenda INT NOT NULL,
    idProduto INT NOT NULL,
    quantidade INT NOT NULL,
    precoUnitario DECIMAL(10, 2) NOT NULL,

    CONSTRAINT fk_item_venda_venda
        FOREIGN KEY (idVenda) REFERENCES venda(idVenda),

    CONSTRAINT fk_item_venda_produto
        FOREIGN KEY (idProduto) REFERENCES produto(idProduto)
);

CREATE TABLE fatura (
    idFatura INT PRIMARY KEY AUTO_INCREMENT,
    idVenda INT UNIQUE NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    dataEmissao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fatura_venda
        FOREIGN KEY (idVenda) REFERENCES venda(idVenda)
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX idx_user_email ON `user` (email);
CREATE INDEX idx_user_role ON `user` (role);
CREATE INDEX idx_user_estado ON `user` (idEstado);

CREATE INDEX idx_cliente_nome ON cliente (nome);

CREATE INDEX idx_log_email_tentado ON log_acesso (emailTentado);
CREATE INDEX idx_log_resultado ON log_acesso (resultado);
CREATE INDEX idx_log_data_tentativa ON log_acesso (dataTentativa);
CREATE INDEX idx_log_user_data ON log_acesso (idUser, dataTentativa);

CREATE INDEX idx_categoria_nome ON categoria (nome);

CREATE INDEX idx_produto_nome ON produto (nome);
CREATE INDEX idx_produto_categoria ON produto (idCategoria);
CREATE INDEX idx_produto_preco ON produto (preco);
CREATE INDEX idx_produto_stock ON produto (stock);
CREATE INDEX idx_produto_ativo ON produto (ativo);
CREATE INDEX idx_produto_categoria_preco ON produto (idCategoria, preco);
CREATE FULLTEXT INDEX idx_produto_texto ON produto (nome, descricao);

CREATE INDEX idx_carrinho_cliente ON carrinho (idCliente);
CREATE INDEX idx_carrinho_produto ON carrinho (idProduto);

CREATE INDEX idx_favorito_cliente ON favorito (idCliente);
CREATE INDEX idx_favorito_produto ON favorito (idProduto);

CREATE INDEX idx_venda_cliente ON venda (idCliente);
CREATE INDEX idx_venda_data ON venda (data);
CREATE INDEX idx_venda_cliente_data ON venda (idCliente, data);

CREATE INDEX idx_item_venda_venda ON item_venda (idVenda);
CREATE INDEX idx_item_venda_produto ON item_venda (idProduto);

CREATE INDEX idx_fatura_venda ON fatura (idVenda);
CREATE INDEX idx_fatura_data_emissao ON fatura (dataEmissao);

-- =========================================================
-- VIEWS
-- =========================================================

CREATE OR REPLACE VIEW vw_produtos_com_categoria AS
SELECT
    p.idProduto,
    p.nome AS produto,
    p.descricao,
    p.preco,
    p.stock,
    p.imagemUrl,
    p.ativo AS produtoAtivo,
    c.idCategoria,
    c.nome AS categoria,
    c.imagemUrl AS categoriaImagemUrl,
    c.ativo AS categoriaAtiva
FROM produto p
INNER JOIN categoria c ON p.idCategoria = c.idCategoria
WHERE p.ativo = TRUE
  AND c.ativo = TRUE;

CREATE OR REPLACE VIEW vw_clientes_com_estado AS
SELECT
    cl.idCliente,
    cl.nome AS cliente,
    cl.morada,
    u.idUser,
    u.email,
    u.role,
    e.nome AS estado
FROM cliente cl
INNER JOIN `user` u ON cl.idUser = u.idUser
INNER JOIN estado e ON u.idEstado = e.idEstado;

CREATE OR REPLACE VIEW vw_users_sem_cliente AS
SELECT
    u.idUser,
    u.email,
    u.role,
    e.nome AS estado
FROM `user` u
INNER JOIN estado e ON u.idEstado = e.idEstado
LEFT JOIN cliente c ON u.idUser = c.idUser
WHERE c.idCliente IS NULL;

CREATE OR REPLACE VIEW vw_carrinho_detalhado AS
SELECT
    ca.idItemCarrinho,
    cl.idCliente,
    cl.nome AS cliente,
    p.idProduto,
    p.nome AS produto,
    cat.nome AS categoria,
    ca.quantidade,
    p.preco,
    ca.quantidade * p.preco AS subtotal,
    ca.dataAdicao
FROM carrinho ca
INNER JOIN cliente cl ON ca.idCliente = cl.idCliente
INNER JOIN produto p ON ca.idProduto = p.idProduto
INNER JOIN categoria cat ON p.idCategoria = cat.idCategoria;

CREATE OR REPLACE VIEW vw_total_carrinho AS
SELECT
    cl.idCliente,
    cl.nome AS cliente,
    COUNT(ca.idItemCarrinho) AS linhasCarrinho,
    COALESCE(SUM(ca.quantidade), 0) AS totalItens,
    COALESCE(SUM(ca.quantidade * p.preco), 0) AS totalCarrinho
FROM cliente cl
LEFT JOIN carrinho ca ON cl.idCliente = ca.idCliente
LEFT JOIN produto p ON ca.idProduto = p.idProduto
GROUP BY cl.idCliente, cl.nome;

CREATE OR REPLACE VIEW vw_favoritos_detalhados AS
SELECT
    f.idFavorito,
    cl.idCliente,
    cl.nome AS cliente,
    p.idProduto,
    p.nome AS produto,
    p.preco,
    cat.nome AS categoria,
    f.dataCriacao
FROM favorito f
INNER JOIN cliente cl ON f.idCliente = cl.idCliente
INNER JOIN produto p ON f.idProduto = p.idProduto
INNER JOIN categoria cat ON p.idCategoria = cat.idCategoria;

CREATE OR REPLACE VIEW vw_vendas_detalhadas AS
SELECT
    v.idVenda,
    v.data AS dataVenda,
    cl.idCliente,
    cl.nome AS cliente,
    p.idProduto,
    p.nome AS produto,
    iv.quantidade,
    iv.precoUnitario,
    iv.quantidade * iv.precoUnitario AS subtotal
FROM venda v
INNER JOIN cliente cl ON v.idCliente = cl.idCliente
INNER JOIN item_venda iv ON v.idVenda = iv.idVenda
INNER JOIN produto p ON iv.idProduto = p.idProduto;

CREATE OR REPLACE VIEW vw_resumo_vendas AS
SELECT
    v.idVenda,
    v.data AS dataVenda,
    cl.idCliente,
    cl.nome AS cliente,
    COUNT(iv.idItemVenda) AS linhasVenda,
    COALESCE(SUM(iv.quantidade), 0) AS totalItens,
    COALESCE(SUM(iv.quantidade * iv.precoUnitario), 0) AS totalCalculado,
    f.total AS totalFatura,
    f.dataEmissao
FROM venda v
INNER JOIN cliente cl ON v.idCliente = cl.idCliente
LEFT JOIN item_venda iv ON v.idVenda = iv.idVenda
LEFT JOIN fatura f ON v.idVenda = f.idVenda
GROUP BY
    v.idVenda,
    v.data,
    cl.idCliente,
    cl.nome,
    f.total,
    f.dataEmissao;

CREATE OR REPLACE VIEW vw_produtos_mais_vendidos AS
SELECT
    p.idProduto,
    p.nome AS produto,
    cat.nome AS categoria,
    p.ativo AS produtoAtivo,
    cat.ativo AS categoriaAtiva,
    COALESCE(SUM(iv.quantidade), 0) AS quantidadeVendida,
    COALESCE(SUM(iv.quantidade * iv.precoUnitario), 0) AS totalVendido
FROM produto p
INNER JOIN categoria cat ON p.idCategoria = cat.idCategoria
LEFT JOIN item_venda iv ON p.idProduto = iv.idProduto
GROUP BY p.idProduto, p.nome, cat.nome, p.ativo, cat.ativo;

CREATE OR REPLACE VIEW vw_logs_acesso_recentes AS
SELECT
    l.idLogAcesso,
    l.idUser,
    l.emailTentado,
    l.resultado,
    l.dataTentativa,
    u.email AS emailRegistado
FROM log_acesso l
LEFT JOIN `user` u ON l.idUser = u.idUser;

-- =========================================================
-- PROCEDURES E TRIGGERS
-- =========================================================

DELIMITER //

CREATE PROCEDURE sp_pesquisar_produtos(
    IN p_termo VARCHAR(255),
    IN p_categoria INT,
    IN p_precoMin DECIMAL(10,2),
    IN p_precoMax DECIMAL(10,2),
    IN p_comStock BOOLEAN
)
BEGIN
    SELECT
        p.*
    FROM produto p
    INNER JOIN categoria c ON p.idCategoria = c.idCategoria
    WHERE
        p.ativo = TRUE
    AND
        c.ativo = TRUE
    AND
        (p_termo IS NULL OR p_termo = '' OR
         LOWER(p.nome) LIKE LOWER(CONCAT('%', p_termo, '%')) OR
         LOWER(p.descricao) LIKE LOWER(CONCAT('%', p_termo, '%')))
    AND
        (p_categoria IS NULL OR p.idCategoria = p_categoria)
    AND
        (p_precoMin IS NULL OR p.preco >= p_precoMin)
    AND
        (p_precoMax IS NULL OR p.preco <= p_precoMax)
    AND
        (p_comStock = FALSE OR p.stock > 0);
END//

CREATE PROCEDURE sp_adicionar_ao_carrinho (
    IN p_idCliente INT,
    IN p_idProduto INT,
    IN p_quantidade INT
)
BEGIN
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_ativo BOOLEAN DEFAULT FALSE;

    IF p_quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A quantidade deve ser maior que zero.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM cliente WHERE idCliente = p_idCliente) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente inexistente.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM produto WHERE idProduto = p_idProduto) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produto inexistente.';
    END IF;

    SELECT stock, ativo
    INTO v_stock, v_ativo
    FROM produto
    WHERE idProduto = p_idProduto;

    IF v_ativo = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produto indisponível.';
    END IF;

    IF p_quantidade > v_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantidade superior ao stock disponível.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM carrinho
        WHERE idCliente = p_idCliente
          AND idProduto = p_idProduto
    ) THEN
        UPDATE carrinho
        SET quantidade = quantidade + p_quantidade,
            dataAdicao = CURRENT_TIMESTAMP
        WHERE idCliente = p_idCliente
          AND idProduto = p_idProduto;
    ELSE
        INSERT INTO carrinho (idCliente, idProduto, quantidade)
        VALUES (p_idCliente, p_idProduto, p_quantidade);
    END IF;
END//

CREATE PROCEDURE sp_remover_do_carrinho (
    IN p_idCliente INT,
    IN p_idProduto INT
)
BEGIN
    DELETE FROM carrinho
    WHERE idCliente = p_idCliente
      AND idProduto = p_idProduto;
END//

CREATE PROCEDURE sp_atualizar_quantidade_carrinho (
    IN p_idCliente INT,
    IN p_idProduto INT,
    IN p_quantidade INT
)
BEGIN
    IF p_quantidade <= 0 THEN
        DELETE FROM carrinho
        WHERE idCliente = p_idCliente
          AND idProduto = p_idProduto;
    ELSE
        UPDATE carrinho
        SET quantidade = p_quantidade,
            dataAdicao = CURRENT_TIMESTAMP
        WHERE idCliente = p_idCliente
          AND idProduto = p_idProduto;
    END IF;
END//

CREATE PROCEDURE sp_limpar_carrinho (
    IN p_idCliente INT
)
BEGIN
    DELETE FROM carrinho
    WHERE idCliente = p_idCliente;
END//

CREATE PROCEDURE sp_top_8_produtos_mais_vendidos()
BEGIN
    SELECT
        p.idProduto,
        p.nome,
        p.descricao,
        p.preco,
        p.stock,
        p.imagemUrl,
        p.ativo,
        p.idCategoria
    FROM produto p
    INNER JOIN categoria c ON p.idCategoria = c.idCategoria
    INNER JOIN item_venda iv ON p.idProduto = iv.idProduto
    WHERE
        p.ativo = TRUE
    AND
        c.ativo = TRUE
    GROUP BY
        p.idProduto,
        p.nome,
        p.descricao,
        p.preco,
        p.stock,
        p.imagemUrl,
        p.ativo,
        p.idCategoria
    ORDER BY
        SUM(iv.quantidade) DESC,
        SUM(iv.quantidade * iv.precoUnitario) DESC
    LIMIT 8;
END//

CREATE PROCEDURE sp_categoria_mais_vendida()
BEGIN
    SELECT
        c.idCategoria,
        c.nome,
        c.imagemUrl,
        c.ativo,
        COALESCE(SUM(iv.quantidade), 0) AS quantidadeVendida,
        COALESCE(SUM(iv.quantidade * iv.precoUnitario), 0) AS totalVendido
    FROM categoria c
    INNER JOIN produto p ON c.idCategoria = p.idCategoria
    INNER JOIN item_venda iv ON p.idProduto = iv.idProduto
    WHERE
        c.ativo = TRUE
    AND
        p.ativo = TRUE
    GROUP BY
        c.idCategoria,
        c.nome,
        c.imagemUrl,
        c.ativo
    ORDER BY
        quantidadeVendida DESC,
        totalVendido DESC
    LIMIT 1;
END//

CREATE PROCEDURE sp_finalizar_compra (
    IN p_idCliente INT,
    OUT p_idVenda INT
)
BEGIN
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_linhas_carrinho INT DEFAULT 0;
    DECLARE v_linhas_atualizadas INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM cliente WHERE idCliente = p_idCliente) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente inexistente.';
    END IF;

    SELECT COUNT(*)
    INTO v_linhas_carrinho
    FROM carrinho
    WHERE idCliente = p_idCliente;

    IF v_linhas_carrinho = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Carrinho vazio.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM carrinho c
        INNER JOIN produto p ON c.idProduto = p.idProduto
        INNER JOIN categoria cat ON p.idCategoria = cat.idCategoria
        WHERE c.idCliente = p_idCliente
          AND (p.ativo = FALSE OR cat.ativo = FALSE)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'O carrinho contém produtos indisponíveis.';
    END IF;

    SELECT SUM(c.quantidade * p.preco)
    INTO v_total
    FROM carrinho c
    INNER JOIN produto p ON c.idProduto = p.idProduto
    WHERE c.idCliente = p_idCliente
      AND p.ativo = TRUE;

    UPDATE produto p
    INNER JOIN carrinho c ON p.idProduto = c.idProduto
    SET p.stock = p.stock - c.quantidade
    WHERE c.idCliente = p_idCliente
      AND p.ativo = TRUE
      AND p.stock >= c.quantidade;

    SET v_linhas_atualizadas = ROW_COUNT();

    IF v_linhas_atualizadas <> v_linhas_carrinho THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para um ou mais produtos.';
    END IF;

    INSERT INTO venda (idCliente)
    VALUES (p_idCliente);

    SET p_idVenda = LAST_INSERT_ID();

    INSERT INTO item_venda (
        idVenda,
        idProduto,
        quantidade,
        precoUnitario
    )
    SELECT
        p_idVenda,
        c.idProduto,
        c.quantidade,
        p.preco
    FROM carrinho c
    INNER JOIN produto p ON c.idProduto = p.idProduto
    WHERE c.idCliente = p_idCliente;

    INSERT INTO fatura (idVenda, total)
    VALUES (p_idVenda, v_total);

    DELETE FROM carrinho
    WHERE idCliente = p_idCliente;

    COMMIT;
END//



CREATE PROCEDURE sp_remover_produto (
    IN p_idProduto INT
)
BEGIN
    DECLARE v_totalRegistos INT DEFAULT 0;

    IF NOT EXISTS (
        SELECT 1
        FROM produto
        WHERE idProduto = p_idProduto
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produto inexistente.';
    END IF;

    SELECT
        (
            SELECT COUNT(*)
            FROM item_venda
            WHERE idProduto = p_idProduto
        )
        +
        (
            SELECT COUNT(*)
            FROM carrinho
            WHERE idProduto = p_idProduto
        )
        +
        (
            SELECT COUNT(*)
            FROM favorito
            WHERE idProduto = p_idProduto
        )
    INTO v_totalRegistos;

    IF v_totalRegistos = 0 THEN
        SET @permitir_delete_produto = TRUE;

        DELETE FROM produto
        WHERE idProduto = p_idProduto;

        SET @permitir_delete_produto = NULL;
    ELSE
        UPDATE produto
        SET ativo = FALSE
        WHERE idProduto = p_idProduto;
    END IF;
END//

CREATE PROCEDURE sp_remover_categoria (
    IN p_idCategoria INT
)
BEGIN
    DECLARE v_totalProdutos INT DEFAULT 0;

    IF NOT EXISTS (
        SELECT 1
        FROM categoria
        WHERE idCategoria = p_idCategoria
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Categoria inexistente.';
    END IF;

    SELECT COUNT(*)
    INTO v_totalProdutos
    FROM produto
    WHERE idCategoria = p_idCategoria;

    IF v_totalProdutos = 0 THEN
        SET @permitir_delete_categoria = TRUE;

        DELETE FROM categoria
        WHERE idCategoria = p_idCategoria;

        SET @permitir_delete_categoria = NULL;
    ELSE
        UPDATE categoria
        SET ativo = FALSE
        WHERE idCategoria = p_idCategoria;

        UPDATE produto
        SET ativo = FALSE
        WHERE idCategoria = p_idCategoria;
    END IF;
END//

CREATE PROCEDURE sp_listar_carrinho (
    IN p_idCliente INT
)
BEGIN
    SELECT *
    FROM vw_carrinho_detalhado
    WHERE idCliente = p_idCliente;
END//

CREATE PROCEDURE sp_listar_vendas_cliente (
    IN p_idCliente INT
)
BEGIN
    SELECT *
    FROM vw_resumo_vendas
    WHERE idCliente = p_idCliente
    ORDER BY dataVenda DESC;
END//

CREATE PROCEDURE sp_registar_log_acesso (
    IN p_emailTentado VARCHAR(255),
    IN p_resultado VARCHAR(50)
)
BEGIN
    DECLARE v_idUser INT;

    SELECT idUser
    INTO v_idUser
    FROM `user`
    WHERE email = p_emailTentado
    LIMIT 1;

    INSERT INTO log_acesso (
        idUser,
        emailTentado,
        resultado
    )
    VALUES (
        v_idUser,
        p_emailTentado,
        p_resultado
    );
END//
CREATE PROCEDURE sp_bloquear_user (
    IN p_idUser INT
)
BEGIN
    UPDATE `user`
    SET idEstado = (
        SELECT idEstado
        FROM estado
        WHERE nome = 'BLOQUEADO'
        LIMIT 1
    )
    WHERE idUser = p_idUser;
END//

CREATE PROCEDURE sp_ativar_user (
    IN p_idUser INT
)
BEGIN
    UPDATE `user`
    SET idEstado = (
        SELECT idEstado
        FROM estado
        WHERE nome = 'ATIVO'
        LIMIT 1
    )
    WHERE idUser = p_idUser;
END//

CREATE PROCEDURE sp_criar_user_cliente (
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_nome VARCHAR(255),
    IN p_morada VARCHAR(255),
    OUT p_idUser INT,
    OUT p_idCliente INT
)
BEGIN
    DECLARE v_idEstadoAtivo INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT idEstado
    INTO v_idEstadoAtivo
    FROM estado
    WHERE nome = 'ATIVO'
    LIMIT 1;

    START TRANSACTION;

    INSERT INTO `user` (email, password, role, idEstado)
    VALUES (p_email, p_password, 'CLIENTE', v_idEstadoAtivo);

    SET p_idUser = LAST_INSERT_ID();

    INSERT INTO cliente (nome, morada, idUser)
    VALUES (p_nome, p_morada, p_idUser);

    SET p_idCliente = LAST_INSERT_ID();

    COMMIT;
END//

CREATE PROCEDURE sp_top_9_categorias_mais_vendidas()
BEGIN
    SELECT
        c.idCategoria,
        c.nome,
        c.imagemUrl,
        c.ativo
    FROM categoria c
    INNER JOIN produto p ON c.idCategoria = p.idCategoria
    INNER JOIN item_venda iv ON p.idProduto = iv.idProduto
    WHERE
        c.ativo = TRUE
    AND
        p.ativo = TRUE
    GROUP BY
        c.idCategoria,
        c.nome,
        c.imagemUrl,
        c.ativo
    ORDER BY
        SUM(iv.quantidade) DESC,
        SUM(iv.quantidade * iv.precoUnitario) DESC
    LIMIT 9;
END//

CREATE PROCEDURE sp_relatorio_kpis()
BEGIN
    SELECT
        COALESCE((
            SELECT SUM(iv.precoUnitario * iv.quantidade)
            FROM item_venda iv
        ), 0) AS faturacaoTotal,

        COALESCE((
            SELECT COUNT(*)
            FROM venda
        ), 0) AS totalVendas,

        COALESCE((
            SELECT SUM(iv.quantidade)
            FROM item_venda iv
        ), 0) AS totalProdutosVendidos,

        COALESCE((
            SELECT COUNT(*)
            FROM cliente c
            INNER JOIN `user` u ON c.idUser = u.idUser
            INNER JOIN estado e ON u.idEstado = e.idEstado
            WHERE e.nome = 'ATIVO'
        ), 0) AS clientesAtivos,

        CASE
            WHEN COALESCE((SELECT COUNT(*) FROM venda), 0) = 0 THEN 0
            ELSE ROUND(
                COALESCE((
                    SELECT SUM(iv.precoUnitario * iv.quantidade)
                    FROM item_venda iv
                ), 0) / (SELECT COUNT(*) FROM venda),
                2
            )
        END AS ticketMedio;
END//

CREATE PROCEDURE sp_relatorio_produtos_mais_vendidos()
BEGIN
    SELECT
        p.nome AS nome,
        COALESCE(SUM(iv.quantidade), 0) AS quantidadeVendida,
        COALESCE(SUM(iv.quantidade * iv.precoUnitario), 0) AS totalVendido
    FROM produto p
    INNER JOIN item_venda iv ON p.idProduto = iv.idProduto
    GROUP BY p.idProduto, p.nome
    ORDER BY quantidadeVendida DESC, totalVendido DESC
    LIMIT 8;
END//

CREATE PROCEDURE sp_relatorio_categorias_mais_vendidas()
BEGIN
    SELECT
        c.nome AS nome,
        COALESCE(SUM(iv.quantidade), 0) AS quantidadeVendida,
        COALESCE(SUM(iv.quantidade * iv.precoUnitario), 0) AS totalVendido
    FROM categoria c
    INNER JOIN produto p ON c.idCategoria = p.idCategoria
    INNER JOIN item_venda iv ON p.idProduto = iv.idProduto
    GROUP BY c.idCategoria, c.nome
    ORDER BY quantidadeVendida DESC, totalVendido DESC
    LIMIT 8;
END//

CREATE PROCEDURE sp_relatorio_vendas_ultimos_7_dias()
BEGIN
    SELECT
        DATE(v.data) AS dia,
        COUNT(DISTINCT v.idVenda) AS totalVendas,
        COALESCE(SUM(iv.quantidade * iv.precoUnitario), 0) AS faturacao
    FROM venda v
    INNER JOIN item_venda iv ON v.idVenda = iv.idVenda
    WHERE v.data >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
    GROUP BY DATE(v.data)
    ORDER BY dia ASC;
END//

CREATE PROCEDURE sp_relatorio_vendas_recentes()
BEGIN
    SELECT
        v.idVenda AS idVenda,
        c.nome AS cliente,
        v.data AS data,
        COALESCE(SUM(iv.quantidade * iv.precoUnitario), 0) AS total
    FROM venda v
    INNER JOIN cliente c ON v.idCliente = c.idCliente
    INNER JOIN item_venda iv ON v.idVenda = iv.idVenda
    GROUP BY v.idVenda, c.nome, v.data
    ORDER BY v.data DESC
    LIMIT 10;
END//

CREATE PROCEDURE sp_relatorio_logs_acesso_recentes()
BEGIN
    SELECT
        l.idLogAcesso AS idLogAcesso,
        l.emailTentado AS emailTentado,
        l.resultado AS resultado,
        l.dataTentativa AS dataTentativa,
        COALESCE(u.role, '-') AS roleUser,
        COALESCE(e.nome, '-') AS estadoUser
    FROM log_acesso l
    LEFT JOIN `user` u ON l.idUser = u.idUser
    LEFT JOIN estado e ON u.idEstado = e.idEstado
    ORDER BY l.dataTentativa DESC
    LIMIT 15;
END//



-- =========================================================
-- TRIGGERS
-- =========================================================

CREATE TRIGGER trg_cliente_user_role_before_insert
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);

    SELECT role
    INTO v_role
    FROM `user`
    WHERE idUser = NEW.idUser;

    IF v_role <> 'CLIENTE' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente só pode estar associado a um user com role CLIENTE.';
    END IF;
END//

CREATE TRIGGER trg_cliente_user_role_before_update
BEFORE UPDATE ON cliente
FOR EACH ROW
BEGIN
    DECLARE v_role VARCHAR(50);

    SELECT role
    INTO v_role
    FROM `user`
    WHERE idUser = NEW.idUser;

    IF v_role <> 'CLIENTE' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente só pode estar associado a um user com role CLIENTE.';
    END IF;
END//

CREATE TRIGGER trg_produto_before_insert
BEFORE INSERT ON produto
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'O stock não pode ser negativo.';
    END IF;

    IF NEW.preco < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'O preço não pode ser negativo.';
    END IF;
END//

CREATE TRIGGER trg_produto_before_update
BEFORE UPDATE ON produto
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'O stock não pode ser negativo.';
    END IF;

    IF NEW.preco < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'O preço não pode ser negativo.';
    END IF;
END//

CREATE TRIGGER trg_carrinho_before_insert
BEFORE INSERT ON carrinho
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;
    DECLARE v_ativo BOOLEAN;

    IF NEW.quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A quantidade no carrinho deve ser maior que zero.';
    END IF;

    SELECT stock, ativo
    INTO v_stock, v_ativo
    FROM produto
    WHERE idProduto = NEW.idProduto;

    IF v_ativo = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produto indisponível.';
    END IF;

    IF NEW.quantidade > v_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantidade superior ao stock disponível.';
    END IF;
END//

CREATE TRIGGER trg_carrinho_before_update
BEFORE UPDATE ON carrinho
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;
    DECLARE v_ativo BOOLEAN;

    IF NEW.quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A quantidade no carrinho deve ser maior que zero.';
    END IF;

    SELECT stock, ativo
    INTO v_stock, v_ativo
    FROM produto
    WHERE idProduto = NEW.idProduto;

    IF v_ativo = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produto indisponível.';
    END IF;

    IF NEW.quantidade > v_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantidade superior ao stock disponível.';
    END IF;
END//

CREATE TRIGGER trg_venda_cliente_ativo
BEFORE INSERT ON venda
FOR EACH ROW
BEGIN
    DECLARE v_estado VARCHAR(50);
    DECLARE v_role VARCHAR(50);

    SELECT e.nome, u.role
    INTO v_estado, v_role
    FROM cliente c
    INNER JOIN `user` u ON c.idUser = u.idUser
    INNER JOIN estado e ON u.idEstado = e.idEstado
    WHERE c.idCliente = NEW.idCliente;

    IF v_estado <> 'ATIVO' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Só clientes com conta ativa podem comprar.';
    END IF;

    IF v_role <> 'CLIENTE' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Só users com role CLIENTE podem comprar.';
    END IF;
END//

CREATE TRIGGER trg_item_venda_before_insert
BEFORE INSERT ON item_venda
FOR EACH ROW
BEGIN
    IF NEW.quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A quantidade vendida deve ser maior que zero.';
    END IF;

    IF NEW.precoUnitario IS NULL OR NEW.precoUnitario = 0 THEN
        SET NEW.precoUnitario = (
            SELECT preco
            FROM produto
            WHERE idProduto = NEW.idProduto
        );
    END IF;

    IF NEW.precoUnitario < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'O preço unitário não pode ser negativo.';
    END IF;
END//

CREATE TRIGGER trg_fatura_before_insert
BEFORE INSERT ON fatura
FOR EACH ROW
BEGIN
    DECLARE v_total DECIMAL(10,2);

    SELECT SUM(quantidade * precoUnitario)
    INTO v_total
    FROM item_venda
    WHERE idVenda = NEW.idVenda;

    IF v_total IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível criar fatura sem itens de venda.';
    END IF;

    SET NEW.total = v_total;
END//

CREATE TRIGGER trg_item_venda_after_insert
AFTER INSERT ON item_venda
FOR EACH ROW
BEGIN
    UPDATE fatura
    SET total = (
        SELECT SUM(quantidade * precoUnitario)
        FROM item_venda
        WHERE idVenda = NEW.idVenda
    )
    WHERE idVenda = NEW.idVenda;
END//

CREATE TRIGGER trg_item_venda_after_update
AFTER UPDATE ON item_venda
FOR EACH ROW
BEGIN
    UPDATE fatura
    SET total = (
        SELECT SUM(quantidade * precoUnitario)
        FROM item_venda
        WHERE idVenda = NEW.idVenda
    )
    WHERE idVenda = NEW.idVenda;
END//

CREATE TRIGGER trg_item_venda_after_delete
AFTER DELETE ON item_venda
FOR EACH ROW
BEGIN
    UPDATE fatura
    SET total = (
        SELECT COALESCE(SUM(quantidade * precoUnitario), 0)
        FROM item_venda
        WHERE idVenda = OLD.idVenda
    )
    WHERE idVenda = OLD.idVenda;
END//

CREATE TRIGGER trg_log_acesso_bloquear_user
AFTER INSERT ON log_acesso
FOR EACH ROW
BEGIN
    DECLARE v_falhas INT;
    DECLARE v_idBloqueado INT;

    IF NEW.resultado = 'PASSWORD_INCORRETA' AND NEW.idUser IS NOT NULL THEN

        SELECT COUNT(*)
        INTO v_falhas
        FROM log_acesso
        WHERE idUser = NEW.idUser
          AND resultado = 'PASSWORD_INCORRETA'
          AND dataTentativa >= DATE_SUB(NOW(), INTERVAL 15 MINUTE);

        IF v_falhas >= 5 THEN
            SELECT idEstado
            INTO v_idBloqueado
            FROM estado
            WHERE nome = 'BLOQUEADO'
            LIMIT 1;

            UPDATE `user`
            SET idEstado = v_idBloqueado
            WHERE idUser = NEW.idUser;
        END IF;
    END IF;
END//


CREATE TRIGGER trg_produto_before_delete
BEFORE DELETE ON produto
FOR EACH ROW
BEGIN
    IF @permitir_delete_produto IS NULL OR @permitir_delete_produto <> TRUE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não apagues produtos diretamente. Usa sp_remover_produto.';
    END IF;
END//

CREATE TRIGGER trg_categoria_before_delete
BEFORE DELETE ON categoria
FOR EACH ROW
BEGIN
    IF @permitir_delete_categoria IS NULL OR @permitir_delete_categoria <> TRUE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não apagues categorias diretamente. Usa sp_remover_categoria.';
    END IF;
END//

DELIMITER ;

USE sports_store;
-- =========================================================
-- SCRIPT 02 - POPULATE DATABASE
-- DB: sports_store
-- ASCII VERSION WITH MORE SAMPLE DATA
-- =========================================================

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE item_venda;
TRUNCATE TABLE fatura;
TRUNCATE TABLE venda;
TRUNCATE TABLE favorito;
TRUNCATE TABLE carrinho;
TRUNCATE TABLE produto;
TRUNCATE TABLE categoria;
TRUNCATE TABLE cliente;
TRUNCATE TABLE log_acesso;
TRUNCATE TABLE estado;
TRUNCATE TABLE `user`;

SET FOREIGN_KEY_CHECKS = 1;
-- =========================================================
-- ESTADOS
-- =========================================================

INSERT INTO estado (nome) VALUES
('ATIVO'),
('INATIVO'),
('BLOQUEADO'),
('PENDENTE');

-- =========================================================
-- USERS
-- Example password: 123456
-- BCrypt hash generated for 123456
-- =========================================================

INSERT INTO `user` (email, password, role, idEstado) VALUES
('admin@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'ADMIN', 1),
('user1@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('user2@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('bloqueado@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 3),
('carlos@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('ana@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('bruno@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('diogo@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('ines@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('rui@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('sofia@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('tiago@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('beatriz@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('miguel@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('lara@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('pedro@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 2),
('marta@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 4),
('joana@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('nuno@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('rita@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('goncalo@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('vera@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('paulo@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('claudia@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1),
('andre@example.com', '$2y$10$9ySDtu3ZgCJuZ6TaXC85he59GGdfXGSn5m9hAZ7KRzWDx2m0v70UC', 'CLIENTE', 1);

-- =========================================================
-- CLIENTES
-- Cliente requires User. Admin has no cliente record.
-- =========================================================

INSERT INTO cliente (nome, morada, idUser) VALUES
('Joao Silva', 'Rua A 123', 2),
('Maria Santos', 'Avenida B 456', 3),
('Cliente Bloqueado', 'Rua Bloqueada 404', 4),
('Carlos Pereira', 'Travessa C 789', 5),
('Ana Martins', 'Rua Norte 10', 6),
('Bruno Costa', 'Rua Sul 22', 7),
('Diogo Ferreira', 'Avenida Central 15', 8),
('Ines Rocha', 'Rua do Parque 8', 9),
('Rui Almeida', 'Rua Nova 31', 10),
('Sofia Neves', 'Praca Livre 5', 11),
('Tiago Lopes', 'Rua do Mercado 18', 12),
('Beatriz Gomes', 'Avenida Mar 44', 13),
('Miguel Ramos', 'Rua Campo 77', 14),
('Lara Mendes', 'Rua Serra 9', 15),
('Pedro Duarte', 'Rua Antiga 2', 16),
('Marta Teixeira', 'Rua Escola 19', 17),
('Joana Carvalho', 'Avenida Sol 61', 18),
('Nuno Batista', 'Rua Jardim 14', 19),
('Rita Moreira', 'Travessa Azul 6', 20),
('Goncalo Reis', 'Rua Ponte 27', 21),
('Vera Pinto', 'Rua Lago 33', 22),
('Paulo Sousa', 'Avenida Rio 52', 23),
('Claudia Faria', 'Rua Vale 3', 24),
('Andre Correia', 'Rua Alto 29', 25);

-- =========================================================
-- LOGS DE ACESSO
-- =========================================================

INSERT INTO log_acesso (idUser, emailTentado, resultado) VALUES
(2, 'user1@example.com', 'SUCESSO'),
(2, 'user1@example.com', 'PASSWORD_INCORRETA'),
(NULL, 'naoexiste@example.com', 'EMAIL_INEXISTENTE'),
(4, 'bloqueado@example.com', 'CONTA_BLOQUEADA'),
(6, 'ana@example.com', 'SUCESSO'),
(7, 'bruno@example.com', 'SUCESSO'),
(8, 'diogo@example.com', 'SUCESSO'),
(9, 'ines@example.com', 'SUCESSO'),
(NULL, 'teste@example.com', 'EMAIL_INEXISTENTE'),
(11, 'sofia@example.com', 'PASSWORD_INCORRETA'),
(12, 'tiago@example.com', 'SUCESSO'),
(17, 'marta@example.com', 'CONTA_BLOQUEADA');

-- =========================================================
-- CATEGORIAS
-- =========================================================

INSERT INTO categoria (nome) VALUES
('Futebol'),
('Fitness'),
('Natacao'),
('Running'),
('Ciclismo'),
('Tenis'),
('Basquetebol'),
('Padel'),
('Voleibol'),
('Andebol'),
('Rugby'),
('Golf'),
('Boxe'),
('Artes Marciais'),
('Yoga'),
('Pilates'),
('Cross Training'),
('Outdoor'),
('Campismo'),
('Ski'),
('Snowboard'),
('Surf'),
('Skate'),
('Pesca'),
('Equitacao'),
('Triatlo'),
('Suplementos'),
('Acessorios'),
('Calcado'),
('Roupa Desportiva'),
('Protecao'),
('Hidratacao'),
('Tecnologia Desportiva'),
('Recuperacao'),
('Musculacao'),
('Danca'),
('Escalada'),
('Desportos Aquaticos'),
('Desportos de Praia'),
('Treino Funcional');

-- =========================================================
-- PRODUTOS
-- =========================================================

INSERT INTO produto (nome, descricao, preco, stock, idCategoria) VALUES
('Bola de Futebol Oficial', 'Bola de futebol para jogo em campo', 79.99, 50, 1),
('Caneleiras Futebol', 'Protecao para pernas em treino e jogo', 25.00, 100, 1),
('Luvas de Guarda Redes', 'Luvas com aderencia para defesa', 45.90, 35, 1),
('Chuteiras Campo Relva', 'Calcado para relva natural', 89.90, 42, 1),
('Saco de Bolas Futebol', 'Saco resistente para transporte de bolas', 34.50, 20, 1),
('Halteres Ajustaveis 10kg', 'Conjunto de halteres para treino em casa', 120.00, 30, 2),
('Tapete Fitness Pro', 'Tapete confortavel para exercicios no solo', 29.99, 70, 2),
('Elastico Resistencia Media', 'Banda elastica para treino de forca', 12.50, 120, 2),
('Rolo Abdominal', 'Equipamento compacto para treino de core', 19.90, 80, 2),
('Banco de Treino Dobravel', 'Banco para treino de peito e bracos', 139.00, 15, 2),
('Fato de Banho Competicao', 'Fato de banho para alta performance', 150.00, 20, 3),
('Oculos de Natacao', 'Oculos ajustaveis para piscina', 22.90, 90, 3),
('Touca Silicone', 'Touca leve para treino diario', 8.99, 150, 3),
('Prancha de Natacao', 'Prancha para treino de pernas', 18.50, 60, 3),
('Pull Buoy Treino', 'Flutuador para treino tecnico', 16.90, 65, 3),
('Tenis de Corrida Leve', 'Tenis ideal para corridas diarias', 99.50, 40, 4),
('Cinto Running', 'Cinto leve para telemovel e chaves', 19.99, 75, 4),
('Meias Running Respiraveis', 'Meias tecnicas para corrida', 11.90, 110, 4),
('Colete Refletor Running', 'Colete de seguranca para corrida noturna', 17.50, 55, 4),
('Garrafa Soft Flask', 'Garrafa flexivel para corrida longa', 14.90, 85, 4),
('Bicicleta de Montanha Aro 29', 'Bicicleta robusta para trilhos', 750.00, 10, 5),
('Capacete Ciclismo', 'Capacete leve com ventilacao', 59.90, 35, 5),
('Luvas Ciclismo', 'Luvas almofadadas para estrada', 21.50, 70, 5),
('Luz Led Bicicleta', 'Conjunto de luz dianteira e traseira', 24.90, 95, 5),
('Bomba de Ar Portatil', 'Bomba compacta para pneus', 18.90, 80, 5),
('Raquete de Tenis Profissional', 'Raquete de alta qualidade para jogadores avancados', 200.00, 15, 6),
('Bolas de Tenis Pack 3', 'Pack de bolas para treino e jogo', 9.90, 140, 6),
('Punho Raquete Tenis', 'Grip confortavel para raquete', 6.50, 160, 6),
('Saco Raquetes Tenis', 'Saco com espaco para raquetes e roupa', 54.90, 25, 6),
('Rede Tenis Treino', 'Rede portatil para treino', 79.00, 12, 6),
('Bola Basquetebol Indoor', 'Produto para basquetebol com boa durabilidade', 124.90, 100, 7),
('Tabela Basquetebol Parede', 'Produto para basquetebol com boa durabilidade', 137.15, 103, 7),
('Manga Compressao Basquetebol', 'Produto para basquetebol com boa durabilidade', 149.40, 11, 7),
('Raquete Padel Control', 'Produto para padel com boa durabilidade', 145.90, 14, 8),
('Bolas Padel Pack 3', 'Produto para padel com boa durabilidade', 158.15, 17, 8),
('Mochila Padel Compacta', 'Produto para padel com boa durabilidade', 50.40, 20, 8),
('Bola Voleibol Praia', 'Produto para voleibol com boa durabilidade', 46.90, 23, 9),
('Rede Voleibol Treino', 'Produto para voleibol com boa durabilidade', 59.15, 26, 9),
('Joelheiras Voleibol', 'Produto para voleibol com boa durabilidade', 71.40, 29, 9),
('Bola Andebol Senior', 'Produto para andebol com boa durabilidade', 67.90, 32, 10),
('Resina Andebol Treino', 'Produto para andebol com boa durabilidade', 80.15, 35, 10),
('Saco Andebol Equipa', 'Produto para andebol com boa durabilidade', 92.40, 38, 10),
('Bola Rugby Treino', 'Produto para rugby com boa durabilidade', 88.90, 41, 11),
('Protetor Bucal Rugby', 'Produto para rugby com boa durabilidade', 101.15, 44, 11),
('Cone Rugby Agilidade', 'Produto para rugby com boa durabilidade', 113.40, 47, 11),
('Tacos Golf Iniciante', 'Produto para golf com boa durabilidade', 109.90, 50, 12),
('Bolas Golf Pack 12', 'Produto para golf com boa durabilidade', 122.15, 53, 12),
('Luva Golf Esquerda', 'Produto para golf com boa durabilidade', 134.40, 56, 12),
('Luvas Boxe Treino', 'Produto para boxe com boa durabilidade', 130.90, 59, 13),
('Saco Boxe Suspenso', 'Produto para boxe com boa durabilidade', 143.15, 62, 13),
('Ligaduras Boxe', 'Produto para boxe com boa durabilidade', 155.40, 65, 13),
('Kimono Artes Marciais', 'Produto para artes marciais com boa durabilidade', 151.90, 68, 14),
('Cinto Artes Marciais', 'Produto para artes marciais com boa durabilidade', 44.15, 71, 14),
('Protetor Tibia Artes Marciais', 'Produto para artes marciais com boa durabilidade', 56.40, 74, 14),
('Tapete Yoga Antiderrapante', 'Produto para yoga com boa durabilidade', 52.90, 77, 15),
('Bloco Yoga Espuma', 'Produto para yoga com boa durabilidade', 65.15, 80, 15),
('Roda Yoga Flexibilidade', 'Produto para yoga com boa durabilidade', 77.40, 83, 15),
('Bola Pilates Pequena', 'Produto para pilates com boa durabilidade', 73.90, 86, 16),
('Anel Pilates Tonificacao', 'Produto para pilates com boa durabilidade', 86.15, 89, 16),
('Meias Pilates Aderentes', 'Produto para pilates com boa durabilidade', 98.40, 92, 16),
('Corda Saltar Rapida', 'Produto para cross training com boa durabilidade', 94.90, 95, 17),
('Kettlebell 16kg', 'Produto para cross training com boa durabilidade', 107.15, 98, 17),
('Caixa Pliometrica', 'Produto para cross training com boa durabilidade', 119.40, 101, 17),
('Mochila Outdoor 30L', 'Produto para outdoor com boa durabilidade', 115.90, 104, 18),
('Bastoes Caminhada', 'Produto para outdoor com boa durabilidade', 128.15, 12, 18),
('Lanterna Outdoor Led', 'Produto para outdoor com boa durabilidade', 140.40, 15, 18),
('Tenda Campismo 2 Pessoas', 'Produto para campismo com boa durabilidade', 136.90, 18, 19),
('Saco Cama Leve', 'Produto para campismo com boa durabilidade', 149.15, 21, 19),
('Colchao Insuflavel Campismo', 'Produto para campismo com boa durabilidade', 161.40, 24, 19),
('Oculos Ski Neve', 'Produto para ski com boa durabilidade', 37.90, 27, 20),
('Luvas Ski Termicas', 'Produto para ski com boa durabilidade', 50.15, 30, 20),
('Capacete Ski', 'Produto para ski com boa durabilidade', 62.40, 33, 20),
('Prancha Snowboard All Mountain', 'Produto para snowboard com boa durabilidade', 58.90, 36, 21),
('Botas Snowboard', 'Produto para snowboard com boa durabilidade', 71.15, 39, 21),
('Fixacoes Snowboard', 'Produto para snowboard com boa durabilidade', 83.40, 42, 21),
('Prancha Surf Iniciante', 'Produto para surf com boa durabilidade', 79.90, 45, 22),
('Fato Neoprene Surf', 'Produto para surf com boa durabilidade', 92.15, 48, 22),
('Leash Surf Resistente', 'Produto para surf com boa durabilidade', 104.40, 51, 22),
('Skate Completo Street', 'Produto para skate com boa durabilidade', 100.90, 54, 23),
('Capacete Skate', 'Produto para skate com boa durabilidade', 113.15, 57, 23),
('Rolamentos Skate', 'Produto para skate com boa durabilidade', 125.40, 60, 23),
('Cana Pesca Telescopica', 'Produto para pesca com boa durabilidade', 121.90, 63, 24),
('Carreto Pesca Medio', 'Produto para pesca com boa durabilidade', 134.15, 66, 24),
('Caixa Iscos Pesca', 'Produto para pesca com boa durabilidade', 146.40, 69, 24),
('Capacete Equitacao', 'Produto para equitacao com boa durabilidade', 142.90, 72, 25),
('Luvas Equitacao', 'Produto para equitacao com boa durabilidade', 155.15, 75, 25),
('Escova Cavalo', 'Produto para equitacao com boa durabilidade', 47.40, 78, 25),
('Fato Triatlo Sprint', 'Produto para triatlo com boa durabilidade', 43.90, 81, 26),
('Cinto Dorsal Triatlo', 'Produto para triatlo com boa durabilidade', 56.15, 84, 26),
('Oculos Triatlo Espelhados', 'Produto para triatlo com boa durabilidade', 68.40, 87, 26),
('Shaker Proteina', 'Produto para suplementos com boa durabilidade', 64.90, 90, 27),
('Barra Proteica Baunilha', 'Produto para suplementos com boa durabilidade', 77.15, 93, 27),
('Pack Gel Energia', 'Produto para suplementos com boa durabilidade', 89.40, 96, 27),
('Saco Desportivo Medio', 'Produto para acessorios com boa durabilidade', 85.90, 99, 28),
('Toalha Microfibra', 'Produto para acessorios com boa durabilidade', 98.15, 102, 28),
('Relogio Cronometro', 'Produto para acessorios com boa durabilidade', 110.40, 10, 28),
('Sapatilhas Treino Geral', 'Produto para calcado com boa durabilidade', 106.90, 13, 29),
('Chinelos Balneario', 'Produto para calcado com boa durabilidade', 119.15, 16, 29),
('Palmilhas Desportivas', 'Produto para calcado com boa durabilidade', 131.40, 19, 29),
('Tshirt Tecnica Homem', 'Produto para roupa desportiva com boa durabilidade', 127.90, 22, 30),
('Leggings Treino Mulher', 'Produto para roupa desportiva com boa durabilidade', 140.15, 25, 30),
('Casaco Corta Vento', 'Produto para roupa desportiva com boa durabilidade', 152.40, 28, 30),
('Protetor Bucal Simples', 'Produto para protecao com boa durabilidade', 148.90, 31, 31),
('Joelheiras Protecao', 'Produto para protecao com boa durabilidade', 41.15, 34, 31),
('Cotoveleiras Protecao', 'Produto para protecao com boa durabilidade', 53.40, 37, 31),
('Garrafa Agua 750ml', 'Produto para hidratacao com boa durabilidade', 49.90, 40, 32),
('Mochila Hidratacao 2L', 'Produto para hidratacao com boa durabilidade', 62.15, 43, 32),
('Copo Termico Desportivo', 'Produto para hidratacao com boa durabilidade', 74.40, 46, 32),
('Relogio GPS Desportivo', 'Produto para tecnologia desportiva com boa durabilidade', 70.90, 49, 33),
('Sensor Cadencia Bicicleta', 'Produto para tecnologia desportiva com boa durabilidade', 83.15, 52, 33),
('Auriculares Desporto', 'Produto para tecnologia desportiva com boa durabilidade', 95.40, 55, 33),
('Rolo Massagem Muscular', 'Produto para recuperacao com boa durabilidade', 91.90, 58, 34),
('Bola Massagem Dupla', 'Produto para recuperacao com boa durabilidade', 104.15, 61, 34),
('Pistola Massagem Mini', 'Produto para recuperacao com boa durabilidade', 116.40, 64, 34),
('Barra Olimpica 20kg', 'Produto para musculacao com boa durabilidade', 112.90, 67, 35),
('Disco Peso 10kg', 'Produto para musculacao com boa durabilidade', 125.15, 70, 35),
('Cinto Musculacao', 'Produto para musculacao com boa durabilidade', 137.40, 73, 35),
('Sapatilhas Danca Jazz', 'Produto para danca com boa durabilidade', 133.90, 76, 36),
('Fita Elasticas Danca', 'Produto para danca com boa durabilidade', 146.15, 79, 36),
('Bolsa Danca', 'Produto para danca com boa durabilidade', 158.40, 82, 36),
('Arnes Escalada', 'Produto para escalada com boa durabilidade', 34.90, 85, 37),
('Saco Magnesio Escalada', 'Produto para escalada com boa durabilidade', 47.15, 88, 37),
('Mosquetao Escalada', 'Produto para escalada com boa durabilidade', 59.40, 91, 37),
('Colete Flutuacao', 'Produto para desportos aquaticos com boa durabilidade', 55.90, 94, 38),
('Remo Ajustavel', 'Produto para desportos aquaticos com boa durabilidade', 68.15, 97, 38),
('Saco Estanque 20L', 'Produto para desportos aquaticos com boa durabilidade', 80.40, 100, 38),
('Raquetes Praia Pack', 'Produto para desportos de praia com boa durabilidade', 76.90, 103, 39),
('Bola Praia Leve', 'Produto para desportos de praia com boa durabilidade', 89.15, 11, 39),
('Guarda Sol Desportivo', 'Produto para desportos de praia com boa durabilidade', 101.40, 14, 39),
('Escada Agilidade', 'Produto para treino funcional com boa durabilidade', 97.90, 17, 40),
('Discos Marcadores', 'Produto para treino funcional com boa durabilidade', 110.15, 20, 40),
('Bola Medicinal 5kg', 'Produto para treino funcional com boa durabilidade', 122.40, 23, 40);

-- =========================================================
-- CARRINHO
-- =========================================================

INSERT INTO carrinho (idCliente, idProduto, quantidade) VALUES
(1,1,1),
(1,7,2),
(2,2,1),
(4,4,1),
(5,8,1),
(6,14,2),
(7,21,1),
(8,28,1),
(9,35,3),
(10,42,1),
(11,49,2),
(12,56,1),
(13,63,1),
(14,70,2),
(18,77,1),
(20,84,1);

-- =========================================================
-- FAVORITOS
-- =========================================================

INSERT INTO favorito (idCliente, idProduto) VALUES
(1,6),
(2,11),
(3,16),
(3,22),
(4,21),
(5,26),
(6,31),
(6,43),
(7,36),
(8,41),
(9,46),
(9,64),
(10,51),
(11,56),
(12,61),
(12,85),
(13,66),
(14,71),
(15,76),
(15,106),
(16,81),
(17,86),
(18,91),
(18,127),
(19,96),
(20,101);

-- =========================================================
-- VENDAS
-- =========================================================

INSERT INTO venda (data, idCliente) VALUES
('2025-05-27 09:00:00', 1),
('2025-05-27 11:13:00', 2),
('2025-05-27 15:39:00', 4),
('2025-05-28 17:52:00', 5),
('2025-05-28 09:05:00', 6),
('2025-05-28 11:18:00', 7),
('2025-05-28 13:31:00', 8),
('2025-05-29 15:44:00', 9),
('2025-05-29 17:57:00', 10),
('2025-05-29 09:10:00', 11),
('2025-05-29 11:23:00', 12),
('2025-05-30 13:36:00', 13),
('2025-05-30 15:49:00', 14);

-- =========================================================
-- ITENS DE VENDA
-- =========================================================
INSERT INTO item_venda (idVenda, idProduto, quantidade, precoUnitario) VALUES
(1,5,2,34.50),
(1,10,1,139.00),
(2,9,3,19.90),
(2,19,2,17.50),
(3,13,1,8.99),
(3,28,1,6.50),
(4,17,2,19.99),
(4,37,2,46.90),
(5,21,3,750.00),
(5,46,1,109.90),
(6,25,1,18.90),
(6,55,2,52.90),
(7,29,2,54.90),
(7,64,1,115.90),
(8,33,3,149.40),
(8,73,2,58.90),
(9,37,1,46.90),
(9,82,1,121.90),
(10,41,2,80.15),
(10,91,2,64.90),
(11,45,3,113.40),
(11,100,1,127.90),
(12,49,1,130.90),
(12,109,2,70.90),
(13,53,2,44.15),
(13,118,1,133.90);

-- =========================================================
-- FATURAS
-- Trigger recalculates total automatically.
-- =========================================================

INSERT INTO fatura (idVenda, total, dataEmissao) VALUES
(1, 0, '2025-05-27 09:15:00'),
(2, 0, '2025-05-27 11:28:00'),
(3, 0, '2025-05-27 13:41:00'),
(4, 0, '2025-05-27 15:54:00'),
(5, 0, '2025-05-28 18:07:00'),
(6, 0, '2025-05-28 09:20:00'),
(7, 0, '2025-05-28 11:33:00'),
(8, 0, '2025-05-28 13:46:00'),
(9, 0, '2025-05-29 15:59:00'),
(10, 0, '2025-05-29 18:12:00'),
(11, 0, '2025-05-29 09:25:00'),
(12, 0, '2025-05-29 11:38:00'),
(13, 0, '2025-05-30 13:51:00');

DELIMITER ;

-- =========================================================
-- IMAGENS ESPECÍFICAS DE PRODUTOS
-- Produtos sem imagemUrl continuam a usar a imagem da categoria
-- =========================================================

-- FUTEBOL
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1606925797300-0b35e9d1794e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Bola de Futebol Oficial';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Luvas de Guarda Redes';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1529810313688-44ea1c2d81d3?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Chuteiras Campo Relva';

-- FITNESS / MUSCULAÇÃO / CROSS TRAINING
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Halteres Ajustaveis 10kg';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Banco de Treino Dobravel';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Kettlebell 16kg';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1579758629938-03607ccdbaba?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Barra Olimpica 20kg';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Disco Peso 10kg';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1599058945522-28d584b6f0ff?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Cinto Musculacao';

-- YOGA / PILATES
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Tapete Yoga Antiderrapante';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1593811167562-9cef47bfc4d7?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Bloco Yoga Espuma';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Roda Yoga Flexibilidade';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Bola Pilates Pequena';

-- NATAÇÃO / TRIATLO
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1530549387789-4c1017266635?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Oculos de Natacao';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1530549387789-4c1017266635?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Fato de Banho Competicao';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1530549387789-4c1017266635?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Oculos Triatlo Espelhados';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Fato Triatlo Sprint';

-- RUNNING / CALÇADO
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Tenis de Corrida Leve';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Colete Refletor Running';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1543508282-6319a3e2621f?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Palmilhas Desportivas';

-- CICLISMO
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Bicicleta de Montanha Aro 29';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1502744688674-c619d1586c9e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Capacete Ciclismo';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1502744688674-c619d1586c9e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Luvas Ciclismo';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1502744688674-c619d1586c9e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Sensor Cadencia Bicicleta';

-- TÉNIS / PADEL
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Raquete de Tenis Profissional';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1617083934557-5fc8dcba9f85?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Bolas de Tenis Pack 3';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Saco Raquetes Tenis';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Raquete Padel Control';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Bolas Padel Pack 3';

-- BASQUETEBOL / VOLEIBOL / ANDEBOL
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Bola Basquetebol Indoor';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1519861531473-9200262188bf?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Tabela Basquetebol Parede';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Bola Voleibol Praia';

-- RUGBY / GOLF / BOXE / ARTES MARCIAIS
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Bola Rugby Treino';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Tacos Golf Iniciante';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Bolas Golf Pack 12';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Luvas Boxe Treino';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Saco Boxe Suspenso';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1555597673-b21d5c935865?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Kimono Artes Marciais';

-- OUTDOOR / CAMPISMO / ESCALADA
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Mochila Outdoor 30L';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Tenda Campismo 2 Pessoas';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Saco Cama Leve';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1522163182402-834f871fd851?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Arnes Escalada';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1522163182402-834f871fd851?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Mosquetao Escalada';

-- SKI / SNOWBOARD / SURF / SKATE
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Oculos Ski Neve';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Capacete Ski';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Prancha Snowboard All Mountain';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Prancha Surf Iniciante';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Fato Neoprene Surf';


-- HIDRATAÇÃO / TECNOLOGIA / ACESSÓRIOS
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1523362628745-0c100150b504?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Garrafa Agua 750ml';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1523362628745-0c100150b504?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Mochila Hidratacao 2L';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1510017803434-a899398421b3?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Relogio GPS Desportivo';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1484704849700-f032a568e944?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Auriculares Desporto';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1523381294911-8d3cead13475?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Saco Desportivo Medio';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1523381294911-8d3cead13475?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Toalha Microfibra';

-- ROUPA / DANÇA / PRAIA
UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Tshirt Tecnica Homem';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Leggings Treino Mulher';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Casaco Corta Vento';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1508700929628-666bc8bd84ea?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Sapatilhas Danca Jazz';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Raquetes Praia Pack';

UPDATE produto
SET imagemUrl = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Bola Praia Leve';

UPDATE categoria SET imagemUrl = '/img/categorias/futebol.png'
WHERE nome = 'Futebol';

UPDATE categoria SET imagemUrl = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Desportos de Praia';

UPDATE categoria SET imagemUrl = '/img/categorias/fitness.png'
WHERE nome = 'Fitness';

UPDATE categoria SET imagemUrl = 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Running';

UPDATE categoria SET imagemUrl = 'https://images.unsplash.com/photo-1520045892732-304bc3ac5d8e?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Skate';

UPDATE categoria SET imagemUrl = '/img/categorias/natacao.png'
WHERE nome IN ('Natacao', 'Natacao');

UPDATE categoria SET imagemUrl = '/img/categorias/running.png'
WHERE nome = 'Running';

UPDATE categoria SET imagemUrl = '/img/categorias/ciclismo.png'
WHERE nome = 'Ciclismo';

UPDATE categoria SET imagemUrl = '/img/categorias/tenis.png'
WHERE nome IN ('Tenis', 'Tenis');

UPDATE categoria
SET imagemUrl = 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Basquetebol';

UPDATE categoria
SET imagemUrl = 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Padel';

UPDATE categoria
SET imagemUrl = 'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Yoga';

UPDATE categoria
SET imagemUrl = 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Surf';

UPDATE categoria
SET imagemUrl = 'https://images.unsplash.com/photo-1547347298-4074fc3086f0?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Voleibol';

UPDATE categoria
SET imagemUrl = 'https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Boxe';

UPDATE categoria
SET imagemUrl = 'https://images.unsplash.com/photo-1510017803434-a899398421b3?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Acessorios';

UPDATE categoria
SET imagemUrl = 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Campismo';

UPDATE categoria
SET imagemUrl = 'https://images.unsplash.com/photo-1522163182402-834f871fd851?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Escalada';

UPDATE categoria
SET imagemUrl = 'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?auto=format&fit=crop&w=900&q=80'
WHERE nome = 'Snowboard';

INSERT INTO venda (idCliente, data)
VALUES (1, DATE_SUB(NOW(), INTERVAL 6 DAY));
SET @venda1 = LAST_INSERT_ID();

INSERT INTO venda (idCliente, data)
VALUES (2, DATE_SUB(NOW(), INTERVAL 5 DAY));
SET @venda2 = LAST_INSERT_ID();

INSERT INTO venda (idCliente, data)
VALUES (1, DATE_SUB(NOW(), INTERVAL 4 DAY));
SET @venda3 = LAST_INSERT_ID();

INSERT INTO venda (idCliente, data)
VALUES (4, DATE_SUB(NOW(), INTERVAL 3 DAY));
SET @venda4 = LAST_INSERT_ID();

INSERT INTO venda (idCliente, data)
VALUES (2, DATE_SUB(NOW(), INTERVAL 2 DAY));
SET @venda5 = LAST_INSERT_ID();

INSERT INTO venda (idCliente, data)
VALUES (1, DATE_SUB(NOW(), INTERVAL 1 DAY));
SET @venda6 = LAST_INSERT_ID();

INSERT INTO venda (idCliente, data)
VALUES (6, NOW());
SET @venda7 = LAST_INSERT_ID();


INSERT INTO item_venda (idVenda, idProduto, quantidade, precoUnitario) VALUES
(@venda1, 1, 2, 25.00),
(@venda1, 3, 1, 15.00),

(@venda2, 5, 1, 4009.90),
(@venda2, 7, 2, 9.90),

(@venda3, 10, 1, 809.00),
(@venda3, 2, 3, 12.50),

(@venda4, 4, 2, 300.00),
(@venda4, 8, 1, 65.00),

(@venda5, 6, 1, 1200.00),
(@venda5, 9, 2, 18.00),

(@venda6, 11, 1, 7500.00),
(@venda6, 12, 2, 22.00),

(@venda7, 13, 1, 99.00),
(@venda7, 14, 1, 305.00);