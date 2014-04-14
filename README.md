## Overview

Provide docker-based development environments to support
100-500 concurrent workspaces on a single server. The idea
is for developers to **edit code** and perform
**light compilation or testing** within the workspace.

* Serious testing is the duty of a continuous integration server.
* Serious compilation is the duty of a build server.

[![trusted build](https://d207aa93qlcgug.cloudfront.net/img/icons/framed-icon-checked-repository.svg "Trusted Build")](https://index.docker.io/u/jumanjiman/wormhole/)
[![wercker status](https://app.wercker.com/status/9a37e953c64d4c74a2b91d81b3fff338/m/master "wercker status")](https://app.wercker.com/project/bykey/9a37e953c64d4c74a2b91d81b3fff338)

[**Trusted Build**](https://index.docker.io/u/jumanjiman/wormhole/)

Please add any issues you find with this software
to the upstream [wormhole](https://github.com/jumanjiman/wormhole/issues).


## Architectural considerations

![admin](https://cloud.githubusercontent.com/assets/332496/2618648/4c55d0b8-bc24-11e3-9413-8ba57442c11a.png)

![user](https://f.cloud.github.com/assets/332496/2528015/529d5c36-b50b-11e3-9e89-707062e47b36.png)
source: [`docs/uml.md`](https://github.com/jumanjiman/wormhole/blob/master/docs/uml.md)

**Notes**:

* User data lives in a data container and
  persists across upgrades of the app container.

* sshd is restrictive:
  - ssh host key persists across upgrades of the app container.

* Weak firewall allows:
  - inbound from Internet to wormhole ephemeral TCP ports
  - outbound from wormhole to Internet on all ports

* Strong firewall allows:
  - inbound from wormhole IP to internal TCP 22
  - no outbound connections other than return traffic for inbound connections

* Must be capable of running on CoreOS. Therefore no outside dependencies.

* Internal infrastructure should use appropriate access control mechanisms
  based on risk evaluation of the wormhole.


## Test harness

RSpec documents key behaviors and assures no regressions:

```
jumanjiman/wormhole
  image
    should be available
  docker
    should expose ssh port and only ssh port
    should run sshd with logging
    should have volume /home/user
    should have volume /media/state/etc/ssh
  packages
    should not have sudo installed

sshd config
  auth
    should use privilege separation
    should use pam
    should allow pubkeyauthentication
    should deny passwordauthentication
    should deny gssapiauthentication
    should deny kerberosauthentication
    should deny challengeresponseauthentication
  tunnels and forwarding
    should deny ssh tunnels
    should deny TCP forwarding
    should deny X11 forwarding
    should deny gateway ports
  Common Configuration Enumeration (CCE)
    CCE-3660-8 Disable remote ssh from accounts with empty passwords
    CCE-3845-5 idle timeout interval should be set appropriately
    CCE-4325-7 Disable SSH protocol version 1
    CCE-4370-3 Disable SSH host-based authentication
    CCE-4387-7 Disable root login via SSH
    CCE-4431-3 SSH warning banner should be enabled
    CCE-4475-0 Disable emulation of rsh command through sshd
    CCE-14061-6 "keep alive" msg count should be set appropriately
    CCE-14491-5 Use appropriate ciphers for SSH
    CCE-14716-5 Users should not be allowed to set env options
  obscurity
    should hide patch level

users with interactive shells
  should only include "root" and "user"
  su
    "root" can su
    "user" cannot su
```


## User instructions

New containers begin life with a git-suitable
[`~/.bashrc`](https://github.com/ISEexchange/docker-wormhole/blob/master/.bashrc).
This is only the initial bashrc; you can modify it at any time.

Inside the container, your user account is literally named `user`.
That means, with default build options, your prompt inside the container is:

    user@wormhole:~$

Connect to your container with info provided by admin:

    ssh -i path/to/privkey -p <your port> user@<ip>


## Admin instructions

### Build a user box

Use the build script with a unique user id (such as github handle)
and the user ssh pubkey to create a runtime container:

```
user=jumanjiman
pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArSm80/8UD/eMolUXU3j6geyNrxthnQxbE4dpwRhXU+F6fbQG+wk9SdWev9NcLLWg9a4zBUSMJUXrrU/8ik3WshSpZpqQary4ZiFFQKgSfYriouchc20S3wwFQZcbOJgH5t5wgGeNaDMzc2GRFhqbuuBiBBF+W5llk0X9CGE1o1iAlyVPAn4UfrJ4//5OXMhYwmU+fO9df3y5Kpn/0SY/lRwWuZeVVIXC+nZcFYXNzPyBVTNEooOXLVXivddtU82jfp65ggTMdLfUafZqia1/smfWQP23lU8F4ySayAOa1lhXXvrGtpxl3lu7vaSvdEg7+F4YaIhxnWZqt769joDraw== pmorgan@github"

./build.sh $user "$pubkey"
```

A runtime container should be up on a random ssh port:

```
$ docker ps

CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                   NAMES
689479673e8e        jumanjiman:latest   /bin/sh -c /usr/sbin   About an hour ago   Up About an hour    0.0.0.0:49153->22/tcp   jumanjiman-run      
```

:warning: The scripts limit each app container to 512 MiB memory.

You can view the current limit for a container via the sys filesystem.
For example, here is a container that was started with a 1 MiB limit:

```
$ cat /sys/fs/cgroup/memory/lxc/<hash>/memory.limit_in_bytes
1048576
```

If a PID inside a container gets killed due to the memory limit,
you can view details in `dmesg` output.


### Backup 

Create a local file called `jumanjiman-data.tar` with contents of
user data container.

```
./backup.sh jumanjiman
```


### Restore user data container from backup

```
./restore.sh jumanjiman
```


### Upgrade user app container

Rebuild the `jumanjiman/wormhole` image as described above, then...

```
./upgrade.sh jumanjiman
```


### Build an image for the app container

This image serves as a template for an app container.<br/>
You can build the image locally or use the
[**Trusted Build**](https://index.docker.io/u/jumanjiman/wormhole/).

```
cd wormhole/
docker build --rm -t jumanjiman/wormhole --no-cache .
```

:warning: Use CoreOS to build image.

Fedora kernel on DigitalOcean
has an older LXC implementation that leads to inconsistent builds.
For example, it sometimes builds the base image with bad perms on
`/var` and other directories that *must* be `0755`.
