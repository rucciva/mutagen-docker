FROM debian:buster-20200514-slim

ENV DEBIAN_FRONTEND=noninteractive

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG VERSION=v0.12.0
ENV URL=https://github.com/mutagen-io/mutagen/releases/download/${VERSION}/mutagen_linux_amd64_${VERSION}.tar.gz

RUN apt-get update &&\
    apt-get -y install --no-install-recommends wget ca-certificates openssh-client 2>&1 &&\
    # download and install
    wget -e use_proxy=yes -e http_proxy=$HTTP_PROXY -e https_proxy=$HTTPS_PROXY -O /tmp/mutagen.tar.gz "$URL" &&\
    tar -zxf /tmp/mutagen.tar.gz -C /usr/local/bin   &&\
    chmod +x /usr/local/bin/mutagen  &&\
    # cleanup
    apt-get -y remove wget ca-certificates &&\
    apt-get autoremove -y &&\
    apt-get clean -y &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -rf /tmp/mutagen.tar.gz &&\
    useradd -ms /bin/bash -u 1000 mutagen &&\
    su - mutagen -c 'mkdir -p "$HOME/.mutagen" "$HOME/.ssh"'

USER mutagen
ENTRYPOINT [ "/usr/local/bin/mutagen" ]
CMD [ "daemon", "run" ]