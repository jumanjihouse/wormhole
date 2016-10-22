FROM alpine:3.4

# http://jumanjiman.github.io/
MAINTAINER Paul Morgan <jumanjiman@gmail.com>

ENV DOCKER_VERSION=1.10.3

COPY . /

RUN apk upgrade --no-cache --available

# We need an older ruby for puppet to avoid syck errors.
RUN apk add --no-cache --repositories-file /etc/apk/repositories.ruby \
      py-graphviz \
      'ruby<2.2' \
      ruby-dev \
      ruby-bundler \
      ruby-io-console \
      ruby-irb \
      && \
    ln -s /usr/lib/ruby/gems/2.1.*/bin/bundle /bin/bundle

# Packages from stable main and community repos.
RUN apk add --no-cache \
      alpine-sdk \
      bash \
      bash-completion \
      checkbashisms \
      coreutils \
      cyrus-sasl \
      cyrus-sasl-gssapi \
      docker-bash-completion \
      docker-vim \
      findutils \
      grep \
      less \
      libffi-dev \
      ncurses \
      bind-tools \
      bc \
      openssh \
      'openssh-client>=7.1_p2' \
      man \
      man-pages \
      gnupg \
      sqlite-dev \
      curl \
      libxslt-dev \
      libxml2-dev \
      nano \
      vim vimdiff \
      openjdk7 \
      jq \
      openssl openssl-dev \
      tree \
      php5 \
      strace \
      tmux \
      go \
      go-tools \
      bzr \
      tar patch diffutils \
      patchutils \
      make \
      jwhois \
      graphviz \
      wget

# Edge main packages.
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/main \
      'git>=2.9' \
      git-bash-completion \
      git-perl \
      git-svn \
      'mutt>=1.6' \
      python2-dev py-nose py-setuptools \
      python3-dev \
      py-pip \
      py-simplejson \
      py-psycopg2 \
      py-lxml \
      py-mock \
      py-oauthlib \
      py-asn1 \
      py-paramiko \
      py-yaml \
      py2-tkinter \
    && :

# Edge community packages.
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
      asciinema \
      editorconfig \
      nmh \
      py-numpy \
      py-rpm \
      rpm \
      rpm-dev \
      duo_unix

# Edge testing packages.
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
      pep8 \
      py-kerberos \
      py-matplotlib \
      py-pyramid \
      py-scipy \
      ;

RUN pip install \
      docker-compose \
      pylint \
      ;

# Install latest docker client as `docker-latest`.
RUN curl -sS -L -o /usr/bin/docker-latest https://get.docker.com/builds/Linux/x86_64/docker-latest && \
    curl -sS -L -o /usr/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION} && \
    chmod 0755 /usr/bin/docker*

# Get tmux-bash-completions.
RUN curl -L -o /usr/share/bash-completion/completions/tmux \
    https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux

# Do not track changes in volumes.
VOLUME ["/home/user", "/media/state/etc/ssh"]

RUN /usr/local/sbin/install-jing.sh

RUN /usr/sbin/harden.sh

EXPOSE 2222
ENV LANG C
ENTRYPOINT ["/usr/sbin/start.sh"]
