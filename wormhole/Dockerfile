# https://index.docker.io/u/mattdm/fedora/
FROM mattdm/fedora:f20

# http://jumanjiman.github.io/
MAINTAINER Paul Morgan <jumanjiman@gmail.com>

# Work around https://bugzilla.redhat.com/show_bug.cgi?id=1066983
RUN yum remove -y vim-minimal sudo

# Install dependencies.
RUN yum install -y \
    openssh-server openssh-clients \
    gcc gcc-c++ \
    gnupg \
    ruby ruby-devel rubygem-bundler \
    libcurl-devel libxslt-devel libxml2-devel \
    vim-enhanced bash-completion \
    tree \
    python-devel python-nose python-setuptools python-pep8 rpm-python \
    python3-devel python3-nose python3-setuptools python3-pep8 rpm-python3 \
    rpm-build libxslt createrepo git-annex \
    tmux tmux-powerline reptyr \
    golang golang-docs golang-cover golang-github-coreos-go-systemd-devel \
    golang-godoc golang-vim golang-github-coreos-go-log-devel \
    git tar patch diffutils which

# Remove yum metadata to reduce image size.
RUN yum clean all

# Break su for everybody but root.
ADD su /etc/pam.d/

# Populate /etc/skel
ADD .bashrc /etc/skel/
ADD .bash_logout /etc/skel/
ADD .bash_profile /etc/skel/

# Annoy user if they forget to set their username and email in git.
ADD git_global.sh /etc/profile.d/

# Create sandbox user.
RUN useradd user

# Do not track changes in volumes.
VOLUME ["/home/user", "/media/state/etc/ssh"]

# Configure security.
ADD sshd_config /etc/ssh/
ADD issue.net /etc/
ADD sshd /etc/pam.d/

EXPOSE 22
ENV LANG C
CMD /usr/sbin/sshd -D -e
