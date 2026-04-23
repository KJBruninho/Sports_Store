Este documento irá guiá-lo para configurar e iniciar este projeto na máquina.
O projeto utiliza 'Docker', uma ferramenta que ajuda a rodar programas de forma
fácil e consistente, sem precisar instalar muitas coisas diretamente no seu computador.

=====================================
PASSO 1: INSTALAR O DOCKER DESKTOP
=====================================

Para rodar este projeto, você precisa instalar o 'Docker Desktop'.
Ele já inclui tudo o que você precisa (Docker e Docker Compose).

1.  **Baixe o Docker Desktop:**
    Abra seu navegador e vá para o site oficial do Docker:
    https://www.docker.com/products/docker-desktop/

2.  **Escolha seu Sistema Operacional:**
    No site, procure pela opção de download para o seu sistema operacional:
    -   Windows
    -   macOS
    -   Linux

3.  **Siga as Instruções de Instalação:**
    Baixe o instalador e siga as instruções na tela.

4.  **Inicie o Docker Desktop:**
    Após a instalação, abra o aplicativo 'Docker Desktop'.
    Ele geralmente fica a rodar em segundo plano.

=====================================
PASSO 2: OBTER O PROJETO
=====================================

Você precisará obter os arquivos deste projeto para a sua máquina.

1.  **Baixar o Projeto:**
    Se você recebeu o projeto em um arquivo ZIP, descompacte-o em uma pasta fácil
    de encontrar

    Se você usa 'Git' (uma ferramenta para gerenciar código), você pode clonar o repositório:
    -   Abra seu terminal ou prompt de comando.
    -   Vá para a pasta onde você guarda seus projetos (ex: `cd C:\Projetos`).
    -   Digite: `git clone <ENDERECO_DO_REPOSITORIO_AQUI>`
    -   Entre na pasta do projeto: `cd <NOME_DA_PASTA_DO_PROJETO>`

=====================================
PASSO 3: INICIAR O PROJETO COM DOCKER
=====================================

Agora que o Docker está instalado e você tem os arquivos do projeto,
vamos iniciá-lo!

1.  **Abra o Terminal/Prompt de Comando:**
    Vá para a pasta principal do projeto no seu terminal ou prompt de comando.
    (Esta é a pasta que contém os arquivos `Dockerfile` e `docker-compose.yml`.)

2.  **Execute o Comando de Início:**
    Digite o seguinte comando e pressione Enter:

    `
    docker-compose up --build -d
    `

    **O que este comando faz:**
    -   Ele diz ao Docker para iniciar tudo o que está configurado para este projeto.
    -   `--build`: Garante que o programa principal seja montado corretamente,
        isso é importante na primeira vez que você roda ou se o código mudou.
    -   `-d`: Faz com que os programas rodem em segundo plano.

    Este processo pode demorar um pouco na primeira vez.

3.  **Verifique se está a funcionar:**
    Para ter certeza de que tudo iniciou corretamente, você pode digitar:

    `
    docker-compose ps
    `
    Você deverá ver uma lista de programas (chamados "contêineres") com o status "Up" (Em execução).

4.  **Acesse o Projeto:**
    Se tudo estiver a funcionar, sua aplicação estará disponível no navegador.
    Abra seu navegador e digite:

    ```
    http://localhost:8080
    ```

=====================================
PARAR O PROJETO
=====================================

Quando você terminar de usar o projeto e quiser pará-lo, volte ao terminal
na pasta do projeto e digite:

`
docker-compose stop
`
=====================================
COMANDOS ÚTEIS DO DOCKER
=====================================

Aqui estão alguns comandos que podem ser úteis enquanto trabalha com o projeto:

* **Parar o Projeto (Contêineres):**
    Para parar os programas que estão rodando em segundo plano (como vimos anteriormente):
    
    `
    docker-compose stop
    `
	
* **Parar e Remover o Projeto (Contêineres, Redes):**
    Este comando para os programas e remove os contêineres e as redes que o Docker
    criou para este projeto. Os dados do banco de dados geralmente ficam guardados.
    
    `
    docker-compose down
    `

* **Parar, Remover e APAGAR os Dados do Banco de Dados:**
    **CUIDADO:** Este comando fará o mesmo que `docker-compose down`, mas também
    removerá permanentemente todos os dados que foram salvos no banco de dados.
    Use apenas se você quiser começar do zero e não se importa em perder os dados.
    
    `
    docker-compose down -v
    `

* **Ver os Logs dos Contêineres:**
    Para ver o que os programas estão a fazer (mensagens de erro, informações):
    
    `
    docker-compose logs -f
    `

    Para ver os logs de um programa específico (ex: aplicação Spring ou o banco de dados):

    `
    docker-compose logs -f spring-app    # Para ver os logs da aplicação Spring
    docker-compose logs -f mysql-db      # Para ver os logs do banco de dados MySQL
    `

* **Ver Quais Imagens Docker Você Tem:**

    Para listar todas as imagens Docker baixadas ou construidas:

    `
    docker images
    `

* **Ver os Contêineres Docker que estão a Rodar:**
    Para listar todos os contêineres Docker que estão ativos (não só os deste projeto):\

    `
    docker ps
    `

    Para ver todos os contêineres (ativos e parados):

    `
    docker ps -a
    `

=====================================
PROBLEMAS COMUNS
=====================================

* **"docker-compose: command not found"**: O Docker Desktop pode não estar instalado corretamente
    ou não está no "caminho" do seu sistema. Tente reiniciar o computador ou reinstalar o Docker Desktop.
* **A aplicação não inicia na porta 8080**: Verifique se não há outro programa na porta 8080
    no seu computador.
* **Erros durante o `docker-compose up`**: Leia as mensagens de erro no terminal.

Se tiver dificuldades,não peça ajuda a quem passou o projeto! :)