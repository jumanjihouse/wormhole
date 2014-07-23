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

# Work around https://bugzilla.redhat.com/show_bug.cgi?id=1105901
# Reproducer is at https://github.com/jumanjiman/bz1099206
RUN yum install -y \
    gcc \
    ; yum clean all

# Install dependencies.
RUN yum install -y \
    asciinema \
    bind-utils \
    bc \
    dictd \
    diction \
    ftp tftp \
    openssh-server openssh-clients \
    man-pages mlocate \
    gcc gcc-c++ \
    glibc-static \
    gnupg \
    ruby ruby-devel rubygem-bundler \
    sqlite-devel \
    ldc \
    libcurl-devel libxslt-devel libxml2-devel \
    vim-enhanced bash-completion \
    java-1.7.0-openjdk-headless \
    openssl openssl-devel crypto-utils \
    tree \
    php \
    python-devel python-nose python-setuptools python-pep8 rpm-python \
    python3-devel python3-nose python3-setuptools python3-pep8 rpm-python3 \
    pylint python3-pylint \
    rpm-build libxslt createrepo git-annex \
    scap-security-guide \
    strace \
    tmux tmux-powerline reptyr \
    golang golang-docs golang-cover golang-github-coreos-go-systemd-devel \
    golang-godoc golang-vim golang-github-coreos-go-log-devel \
    npm nodeunit \
    bzr \
    tito \
    git tar patch diffutils which \
    git-hg \
    git-svn \
    make \
    jwhois \
    ; yum clean all

RUN gem install rhc

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
    curl -s -O ftp://ftp.eiffel.com/pub/download/14.05/Eiffel_14.05_gpl_95220-linux-x86-64.tar.bz2 ;\
    tar xjf /tmp/Eiffel_14.05_gpl_95220-linux-x86-64.tar.bz2 -C /usr/local/ ;\
    rm -f /tmp/Eiffel_14.05_gpl_95220-linux-x86-64.tar.bz2

# Install duo for multifactor authentication.
ADD duo.repo /etc/yum.repos.d/
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

# Do not track changes in volumes.
VOLUME ["/home/user", "/media/state/etc/ssh"]

# Configure security.
ADD sshd_config /etc/ssh/
ADD issue.net /etc/
ADD sshd /etc/pam.d/
ADD password-auth /etc/pam.d/
ADD password-auth.patch /etc/pam.d/
ADD start.sh /usr/sbin/
ADD wormhole-devenv-xccdf.xml /usr/share/xml/scap/ssg/fedora/
ADD oscap-remediate.sh /usr/sbin/

# Install arcanist.
# https://secure.phabricator.com/book/phabricator/article/arcanist/
ADD install-arc.sh /usr/local/sbin/install-arc.sh
RUN /usr/local/sbin/install-arc.sh

# Install tools for validating xml.
ADD jing /usr/local/bin/
ADD trang /usr/local/bin/
ADD install-jing.sh /usr/local/sbin/install-jing.sh
RUN /usr/local/sbin/install-jing.sh

# Update system databases for user convenience.
RUN mandb &> /dev/null
RUN updatedb &> /dev/null

# Remediate security after all packages are installed.
RUN /usr/sbin/oscap-remediate.sh

EXPOSE 22
ENV LANG C
CMD /usr/sbin/start.sh
