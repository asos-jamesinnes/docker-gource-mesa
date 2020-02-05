FROM utensils/opengl:stable
RUN set -xe; \
    apk --update add --no-cache --virtual .runtime-deps \
    bash ffmpeg git gource imagemagick llvm7-libs;
COPY ./entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]
