FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Camada de dependências (só refaz se o build.gradle mudar)
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./
# gradlew salvo no Windows pode ter CRLF, o que quebra no Linux
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew && ./gradlew dependencies --no-daemon

COPY src src
RUN ./gradlew bootJar --no-daemon -x test && rm -f build/libs/*-plain.jar

FROM eclipse-temurin:21-jre
WORKDIR /app

# Roda sem privilégios de root
RUN useradd --system --no-create-home spring
USER spring

# Sobra só o jar executável (o "-plain" foi removido na etapa de build)
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
