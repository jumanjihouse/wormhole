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
    git tar patch diffutils which

# Remove yum metadata to reduce image size.
RUN yum clean all

# Autocreate ssh host keys.
RUN ssh-keygen -A

EXPOSE 22
ENV LANG C
#CMD ["/bin/bash"]
CMD /usr/sbin/sshd -D
