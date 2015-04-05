# http://gliderlabs.viewdocs.io/docker-alpine
FROM alpine:latest

# http://jumanjiman.github.io/
MAINTAINER Paul Morgan <jumanjiman@gmail.com>

COPY etc/apk/repositories /etc/apk/
RUN apk upgrade --update-cache --available && apk add \
    alpine-sdk \
    asciinema \
    bind-tools \
    bc \
    docker \
    duo_unix \
    lftp \
    openssh \
    openssh-client \
    gnupg \
    ruby ruby-dev ruby-bundler ruby-irb \
    sqlite-dev \
    libxslt-dev libxml2-dev \
    nano \
    vim \
    go-vim \
    vimdiff \
    vimpager \
    docker-vim \
    nginx-vim \
    vim-sleuth \
    bash \
    bash-completion \
    git-bash-completion \
    checkbashisms \
    docker-bash-completion \
    openjdk7 \
    jq \
    openssl-dev \
    tree \
    php \
    python-dev \
    python3-dev \
    py-setuptools \
    py-rpm \
    py-pep8 \
    py-nose \
    pylint \
    rpm \
    rpm-dev \
    rpmlint \
    strace \
    tmux tmux-bash-completion \
    bzr \
    git \
    tar \
    patch \
    patchutils \
    diffutils \
    mercurial \
    git-svn \
    make \
    mutt \
    jwhois \
    py-graphviz \
    py-lxml \
    py-mock \
    py-requests-oauthlib \
    py-pyramid \
    py-asn1 \
    py-psycopg2 \
    py-paramiko \
    py-numpy-dev \
    py-yaml \
    py-scipy \
    py-matplotlib \
    && rm -fr /var/cache/apk/*

# Break su for everybody but root.
# Break cron for everybody.
# Populate /etc/skel
# Annoy user if they forget to set their username and email in git.
# Configure security.
# Install tools for validating xml.
COPY . /

# Install latest docker client.
RUN curl -sS -L -o /usr/bin/docker-compose https://github.com/docker/compose/releases/download/1.2.0rc3/docker-compose-`uname -s`-`uname -m` \
    && chmod 0755 /usr/bin/docker-compose

RUN /usr/sbin/harden.sh

# Do not track changes in volumes.
VOLUME ["/home/user", "/media/state/etc/ssh"]

# Be informative after successful login.
RUN echo "App container image built on $(date)." > /etc/motd

RUN /usr/local/sbin/install-jing.sh

EXPOSE 2222
ENV LANG C
CMD /usr/sbin/start.sh
