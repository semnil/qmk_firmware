FROM alpine:3.9.3

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories

RUN apk update && apk add --no-cache \
    avr-libc \
    build-base \
    gcc-avr \
    git \
    python \
    newlib-arm-none-eabi \
    unzip \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/*

ENV KEYBOARD=helix
ENV KEYMAP=semnil

ARG OSS_ACCESS_KEY_ID
ARG OSS_ACCESS_KEY_SECRET

ADD https://docs-aliyun.cn-hangzhou.oss.aliyun-inc.com/internal/oss/0.0.4/assets/sdk/OSS_Python_API_20160419.zip a.zip
RUN unzip a.zip

RUN echo "[OSSCredentials]" > /root/.osscredentials
RUN echo "accessid = ${OSS_ACCESS_KEY_ID}" >> /root/.osscredentials
RUN echo "accesskey = ${OSS_ACCESS_KEY_SECRET}" >> /root/.osscredentials
RUN echo "host = oss-ap-northeast-1.aliyuncs.com" >> /root/.osscredentials

ADD https://bootstrap.pypa.io/get-pip.py get-pip.py
RUN python get-pip.py

VOLUME /qmk_firmware
WORKDIR /qmk_firmware

CMD cd / ; rm -rf /qmk_firmware ; \
    git clone --depth 1 -b semnil https://github.com/semnil/qmk_firmware.git ; \
    cd qmk_firmware ; make $KEYBOARD:$KEYMAP ; cd .. ; \
    python osscmd put /qmk_firmware/${KEYBOARD}_rev2_${KEYMAP}.hex oss://qmk-firmware
