FROM alpine:3.3

# http://jumanjiman.github.io/
MAINTAINER Paul Morgan <jumanjiman@gmail.com>

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
      cyrus-sasl \
      cyrus-sasl-gssapi \
      docker-bash-completion \
      docker-vim \
      docker \
      findutils \
      git \
      git-bash-completion \
      git-perl \
      git-svn \
      grep \
      less \
      libffi-dev \
      tmux-bash-completion \
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
      php \
      python-dev py-nose py-setuptools \
      python3-dev \
      py-simplejson \
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
      py-lxml \
      py-mock \
      py-oauthlib \
      py-asn1 \
      py-paramiko \
      py-yaml \
      wget

# Edge main packages.
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/main \
      'mutt>=1.6' \
    && :

# Edge community packages.
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
      duo_unix

# Edge testing packages.
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
      asciinema \
      editorconfig \
      nmh \
      pep8 \
      pylint \
      rpm \
      rpmlint \
      rpm-dev \
      py-kerberos \
      py-matplotlib \
      py-numpy \
      py-psycopg2 \
      py-pyramid \
      py-rpm \
      py-scipy \
      vimpager

# Install latest docker client as `docker-latest`.
RUN curl -sS -L -o /usr/bin/docker-latest https://get.docker.com/builds/Linux/x86_64/docker-latest && \
    curl -sS -L -o /usr/bin/docker-compose https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m`;\
    chmod 0755 /usr/bin/docker*

# Do not track changes in volumes.
VOLUME ["/home/user", "/media/state/etc/ssh"]

RUN /usr/local/sbin/install-jing.sh

RUN /usr/sbin/harden.sh

EXPOSE 2222
ENV LANG C
ENTRYPOINT ["/usr/sbin/start.sh"]
