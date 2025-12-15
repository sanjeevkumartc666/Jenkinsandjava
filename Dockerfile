# Build stage
FROM maven:3.8.1-openjdk-8-slim AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn package -DskipTests && rm -rf ~/.m2

# Runtime stage
FROM tomcat:9-jre8-alpine
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/helloworld-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
