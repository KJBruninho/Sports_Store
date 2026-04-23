# Etapa 1: Build com Maven
FROM maven:3.9.4-eclipse-temurin-17 AS build

# Cria diretório de trabalho
WORKDIR /app

# Copia tudo para o container
COPY . .

# Compila o projeto (sem testes, se quiser incluir, remova o -DskipTests)
RUN mvn clean package -DskipTests

# Etapa 2: Runtime com JDK leve
FROM eclipse-temurin:17-jdk-alpine

# Cria diretório para app
WORKDIR /app

# Copia o .jar da etapa de build
COPY --from=build /app/target/*.jar app.jar

# Expõe a porta padrão do Spring Boot
EXPOSE 8080

# Comando para rodar a aplicação
ENTRYPOINT ["java", "-jar", "app.jar"]
