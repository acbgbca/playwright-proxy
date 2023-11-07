FROM ghcr.io/graalvm/native-image-community:21.0.1 AS mavenbuild

COPY --link . /build
RUN cd /build && PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 && ./mvnw clean native:compile -Pnative -DskipTests

FROM debian:12.2-slim

ARG USERNAME=playwright
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN mkdir -p /opt/playwright/browsers && chown -R ${USERNAME}:${USERNAME} /opt/playwright && chmod -R 777 /opt/playwright

RUN apt update && export DEBIAN_FRONTEND=noninteractive && apt -y install --no-install-recommends curl libglib2.0-0\
 libnss3\
 libnspr4\
 libatk1.0-0\
 libatk-bridge2.0-0\
 libcups2\
 libdrm2\
 libdbus-1-3\
 libxcb1\
 libxkbcommon0\
 libatspi2.0-0\
 libx11-6\
 libxcomposite1\
 libxdamage1\
 libxext6\
 libxfixes3\
 libxrandr2\
 libgbm1\
 libpango-1.0-0\
 libcairo2\
 libasound2 && apt clean && rm -rf /var/lib/apt/lists/*

USER ${USER_UID}:${USER_GID}

COPY --from=mavenbuild --chown=${USERNAME}:${USERNAME} --chmod=775 /build/target/playwright-proxy /playwright-proxy

HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -sf http://localhost:8080/actuator/health || exit 1

ENV PLAYWRIGHT_BROWSERS_PATH=/opt/playwright/browsers

EXPOSE 8080

ENTRYPOINT [ "/playwright-proxy" ]
