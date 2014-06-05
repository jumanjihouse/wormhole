# https://index.docker.io/_/fedora/
FROM fedora:20

# http://jumanjiman.github.io/
MAINTAINER Paul Morgan <jumanjiman@gmail.com>

RUN yum update -y; yum clean all

# Work around https://bugzilla.redhat.com/show_bug.cgi?id=1066983
# and remove prohibited packages.
RUN yum remove -y vim-minimal \
    at \
    sudo \
    ; yum clean all

# Install dependencies.
RUN yum install -y \
    bind-utils \
    ftp tftp \
    openssh-server openssh-clients \
    man-pages mlocate \
    gcc gcc-c++ \
    gnupg \
    ruby ruby-devel rubygem-bundler \
    libcurl-devel libxslt-devel libxml2-devel \
    vim-enhanced bash-completion \
    tree \
    python-devel python-nose python-setuptools python-pep8 rpm-python \
    python3-devel python3-nose python3-setuptools python3-pep8 rpm-python3 \
    pylint python3-pylint \
    rpm-build libxslt createrepo git-annex \
    tmux tmux-powerline reptyr \
    golang golang-docs golang-cover golang-github-coreos-go-systemd-devel \
    golang-godoc golang-vim golang-github-coreos-go-log-devel \
    npm nodeunit \
    bzr \
    tito \
    git tar patch diffutils which \
    git-hg \
    ; yum clean all

# Break su for everybody but root.
ADD su /etc/pam.d/

# Break cron for everybody.
ADD cron.allow /etc/
RUN chmod 0400 /usr/bin/crontab
RUN chmod 0400 /usr/sbin/crond

# Populate /etc/skel
ADD .bashrc /etc/skel/
ADD .bash_logout /etc/skel/
ADD .bash_profile /etc/skel/

# Annoy user if they forget to set their username and email in git.
ADD profile.d /etc/profile.d/

# Install EiffelStudio. See LICENSE.eiffelstudio for terms.
RUN yum -y install gtk2-devel.x86_64 libXtst-devel.x86_64 pangox-compat; yum clean all
RUN cd /tmp ;\
    curl -O ftp://ftp.eiffel.com/pub/download/13.11/Eiffel_13.11_gpl_93542-linux-x86-64.tar.bz2 ;\
    tar xvjf /tmp/Eiffel_13.11_gpl_93542-linux-x86-64.tar.bz2 -C /usr/local/ ;\
    rm -f /tmp/Eiffel_13.11_gpl_93542-linux-x86-64.tar.bz2

# Create sandbox user.
RUN useradd user

# Do not track changes in volumes.
VOLUME ["/home/user", "/media/state/etc/ssh"]

# Configure security.
ADD sshd_config /etc/ssh/
ADD issue.net /etc/
ADD sshd /etc/pam.d/

# Update system databases for user convenience.
RUN mandb
RUN updatedb

EXPOSE 22
ENV LANG C
CMD /usr/sbin/sshd -D -e
