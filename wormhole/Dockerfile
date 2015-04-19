# https://index.docker.io/_/fedora/
FROM fedora:21

# http://jumanjiman.github.io/
MAINTAINER Paul Morgan <jumanjiman@gmail.com>

# Allow to install docs since this is a dev environment.
RUN sed -i '/tsflags=nodocs/d' /etc/yum.conf

RUN yum update -y; yum clean all

# Work around https://bugzilla.redhat.com/show_bug.cgi?id=1066983
# and remove prohibited packages.
RUN yum remove -y vim-minimal \
    at \
    sudo \
    ; yum clean all

# Install dependencies.
RUN yum install -y \
    asciinema \
    bind-utils \
    bc \
    devscripts-minimal \
    dictd \
    diction \
    ftp tftp \
    hostname \
    openssh-server openssh-clients \
    man-db \
    man-pages mlocate \
    gcc gcc-c++ \
    glibc-static \
    gflags gflags-devel \
    gnupg \
    ruby ruby-devel rubygem-bundler \
    sqlite-devel \
    libcurl-devel libxslt-devel libxml2-devel \
    nano \
    vim-enhanced bash-completion \
    java-1.8.0-openjdk-headless \
    jq \
    openssl openssl-devel crypto-utils \
    tree \
    php \
    python-devel python-nose python-setuptools python-pep8 rpm-python \
    python3-devel python3-nose python3-setuptools python3-pep8 rpm-python3 \
    pylint python3-pylint \
    pykickstart \
    rpm-build libxslt createrepo git-annex \
    scap-security-guide \
    strace \
    tmux tmux-powerline reptyr \
    golang golang-cover golang-github-coreos-go-systemd-devel \
    golang-godoc golang-vim golang-github-coreos-go-log-devel \
    npm nodeunit \
    bzr \
    tito \
    git tar patch diffutils which \
    git-remote-hg \
    git-svn \
    make \
    mutt \
    jwhois \
    xmlstarlet \
    python-pygraphviz-doc \
    python-pygraphviz \
    python-xdot \
    python3-pygraphviz \
    python-lxml-docs \
    python-lxml \
    python3-lxml \
    python-requests-kerberos \
    python-requests-mock \
    python-requests-oauthlib \
    python3-requests-mock \
    python3-requests-oauthlib \
    python-CacheControl \
    python-pyramid-tm \
    python-requests \
    python3-CacheControl \
    python3-pyramid-tm \
    python3-requests \
    python-pyasn1-modules \
    python3-pyasn1-modules \
    python-pyasn1 \
    python3-pyasn1 \
    python-psycopg2 \
    python-psycopg2-debug \
    python-psycopg2-doc \
    python3-psycopg2.x86_64 \
    python3-psycopg2-debug \
    python-scp \
    python-paramiko \
    numpy \
    python3-numpydoc \
    python3-numpy \
    python3-PyYAML \
    python3-scipy \
    python-numpydoc \
    PyYAML \
    scipy \
    python-matplotlib-data-fonts \
    python-matplotlib-doc \
    python-matplotlib \
    python3-matplotlib \
    wget \
    ; yum clean all

# Break su for everybody but root.
# Break cron for everybody.
# Populate /etc/skel
# Annoy user if they forget to set their username and email in git.
# Configure security.
# Install tools for validating xml.
COPY . /
RUN chmod 0400 /usr/bin/crontab
RUN chmod 0400 /usr/sbin/crond

# Install duo for multifactor authentication.
RUN rpm --import https://www.duosecurity.com/RPM-GPG-KEY-DUO ;\
    yum -y install duo_unix; yum clean all
# Avoid error `Only root may specify -c or -f` when using
# ForceCommand with `-f` option at non-root ssh login.
# https://www.duosecurity.com/docs/duounix-faq#can-i-use-login_duo-to-protect-non-root-shared-accounts,-or-can-i-do-an-install-without-root-privileges?
RUN chmod u-s /usr/sbin/login_duo

# Create sandbox user.
RUN useradd user

# Ugly workaround. Really ugly.
RUN usermod -aG slocate user

# Install latest docker client.
RUN curl -sS -L -o /usr/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-latest ;\
    curl -sS -L -o /usr/bin/docker-compose https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m`;\
    chmod 0755 /usr/bin/docker*

# https://www.npmjs.com/package/dockerlint
RUN npm install -g dockerlint

# Do not track changes in volumes.
VOLUME ["/home/user", "/media/state/etc/ssh"]

# Be informative after successful login.
RUN echo "App container image built on $(date)." > /etc/motd

RUN /usr/local/sbin/install-jing.sh

# Update system databases for user convenience.
RUN mandb &> /dev/null
RUN updatedb &> /dev/null

# Remediate security after all packages are installed.
RUN /usr/sbin/oscap-remediate.sh

# Run oval security scan after remediation.
# This script exits non-zero if container is non-compliant,
# so 'docker build' fails if container has known vulnerabilities.
# IOW it's impossible to build an image with known vulnerabilities.
RUN /usr/sbin/oval-vulnerability-scan.sh

EXPOSE 22
ENV LANG C
CMD /usr/sbin/start.sh
