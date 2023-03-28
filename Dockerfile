FROM eclipse-temurin:17-jre as builder
WORKDIR application
ARG JAR_FILE=application/build/libs/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

################################

FROM eclipse-temurin:17-jre
MAINTAINER johnniang <johnniang@fastmail.com>
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./

ENV JVM_OPTS="-Xmx1024m -Xms1024m" \
    TZ=Asia/Shanghai

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

ENTRYPOINT ["sh", "-c", "java ${JVM_OPTS} org.springframework.boot.loader.JarLauncher --halo.security.initializer.superadminusername=admin --halo.external-url=http://localhost:8090/ --halo.security.initializer.superadminpassword=P@88w0rd ${0} ${@} "]
