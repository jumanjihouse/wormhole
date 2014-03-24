## Overview

Provide docker-based development environments to support
100-500 concurrent workspaces on a single server. The idea
is for developers to edit code and perform light compilation
or testing within the workspace.

* Serious testing is the duty of a continuous integration server.
* Serious compilation is the duty of a build server.

The upstream is https://github.com/jumanjiman/devenv


## Requirements

* Must be capable of running on CoreOS. Therefore no outside dependencies.
* User data must reside in data container separate from apps.
* ssh host key must persist across upgrades of app container.


## Brief instructions

### Build an image for the app container

This image serves as a template for an app container.

```
cd devenv/
docker build --rm -t jumanjiman/devenv --no-cache .
```

:warning: Use CoreOS to build image.

Fedora kernel on DigitalOcean
has an older LXC implementation that leads to inconsistent builds.
For example, it sometimes builds the base image with bad perms on
`/var` and other directories that *must* be `0755`.


### Build a user box

Given...

* user github handle, such as jumanjiman
* user ssh pubkey

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

Rebuild the `jumanjiman/devenv` image as described above, then...

```
./upgrade.sh jumanjiman
```


## User instructions

New containers begin life with a git-suitable
[`~/.bashrc`](https://github.com/ISEexchange/docker-devenv/blob/master/.bashrc).
This is only the initial bashrc; you can modify it at any time.
