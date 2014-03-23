# https://index.docker.io/u/mattdm/fedora/
FROM mattdm/fedora:f20

# http://jumanjiman.github.io/
MAINTAINER Paul Morgan <jumanjiman@gmail.com>

# Work around https://bugzilla.redhat.com/show_bug.cgi?id=1066983
RUN yum remove -y vim-minimal

# Install dependencies.
RUN yum install -y \
    openssh-server openssh-clients \
    gcc gcc-c++ \
    ruby ruby-devel rubygem-bundler \
    libcurl-devel libxslt-devel libxml2-devel \
    vim-enhanced bash-completion \
    tree \
    python-devel python-nose python-setuptools python-pep8 rpm-python \
    python3-devel python3-nose python3-setuptools python3-pep8 rpm-python3 \
    rpm-build libxslt createrepo git-annex \
    tmux tmux-powerline reptyr \
    git tar patch diffutils which

# Remove yum metadata to reduce image size.
RUN yum clean all

# Populate /etc/skel
ADD .bashrc /etc/skel/
ADD .bash_logout /etc/skel/
ADD .bash_profile /etc/skel/

# Create sandbox user.
RUN useradd user

# Do not track changes in /home/user.
VOLUME ["/home/user"]

# Configure security.
ADD sshd_config /etc/ssh/
ADD issue.net /etc/

# Autocreate ssh host keys.
RUN ssh-keygen -A

EXPOSE 22
ENV LANG C
CMD /usr/sbin/sshd -D
