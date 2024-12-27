FROM maven:3.9.9-amazoncorretto-23 AS build

COPY pom.xml pom.xml

RUN mvn dependency:resolve

COPY src src

RUN mvn package spring-boot:repackage -DskipTests

FROM amazoncorretto:23

WORKDIR /app

COPY --from=build /target/*.jar ./app.jar

CMD ["java", "-jar", "app.jar"]