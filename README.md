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

[Architectural considerations](#architectural-considerations)<br/>
[OVAL vulnerability scan](#oval-vulnerability-scan)<br/>
[Test harness](#test-harness)<br/>
[User instructions](#user-instructions)<br/>
[Admin instructions](#admin-instructions)<br/>
[Contributing](https://github.com/jumanjiman/wormhole/blob/master/CONTRIBUTING.md)<br/>
[License](https://github.com/jumanjiman/wormhole/blob/master/LICENSE)<br/>


## Architectural considerations

![admin](https://cloud.githubusercontent.com/assets/332496/3352907/edec295c-fa65-11e3-8044-f80d3f0af3c0.png)

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


## OVAL vulnerability scan

The Red Hat Security Response Team provides OVAL definitions
for all vulnerabilities (identified by CVE name) that affect RHEL or Fedora.
This enables users to perform a vulnerability scan and
diagnose whether the system is vulnerable.

The Dockerfile in this repo adds a script to download the latest
OVAL definitions from Red Hat and perform a vulnerability scan
against the image. If the image has one or more known vulnerabilies,
the script exits non-zero, and the `docker build` fails.

Implications:

* We **must resolve all known vulnerabilities**
  in order to successfully build an image.

* The scan is time-dependent as of image build, so
  we should rebuild the image when Red Hat updates the OVAL feed.

* The vulnerability scan is distinct from the *SCAP secure configuration scan*
  described [by the test harness](#test-harness).

It is possible to scan an existing image:

    docker run --rm -t jumanjiman/wormhole /usr/sbin/oval-vulnerability-scan.sh

The exact output of the vulnerability scan varies according to the
latest Red Hat OVAL feed, but it looks similar to this snapshot from August 2014:

    -snip copious checks-

    RHSA-2014:1051: flash-plugin security update (Critical)
    oval-com.redhat.rhsa-def-20141051
    CVE-2014-0538
    CVE-2014-0540
    CVE-2014-0541
    CVE-2014-0542
    CVE-2014-0543
    CVE-2014-0544
    CVE-2014-0545
    pass

    RHSA-2014:1052: openssl security update (Moderate)
    oval-com.redhat.rhsa-def-20141052
    CVE-2014-3505
    CVE-2014-3506
    CVE-2014-3507
    CVE-2014-3508
    CVE-2014-3509
    CVE-2014-3510
    CVE-2014-3511
    pass

    RHSA-2014:1053: openssl security update (Moderate)
    oval-com.redhat.rhsa-def-20141053
    CVE-2014-0221
    CVE-2014-3505
    CVE-2014-3506
    CVE-2014-3508
    CVE-2014-3510
    pass

    vulnerability scan exit status 0

TODO: Implement some sort of CD system to poll the OVAL feed and rebuild
the image on any update. https://github.com/jumanjiman/docker-gocd may be
a candidate for the solution.


## Test harness

RSpec documents key behaviors and assures no regressions:

    contributor friction
      there should not be any

    jumanjiman/wormhole
      image
        should be available
      image properties
        should expose ssh port and only ssh port
        should have volume /home/user
        should have volume /media/state/etc/ssh

    admin scripts
      given user handle="booga"
        everybody knows pubkey
        booga knows privkey
      `build.sh $handle "$pubkey"` creates wormhole from 2 containers
        "booga-data" is a persistent read-write container
          should exist
          should be stopped
          should be created from busybox
          should export /home/user volume read-write
          should export /media/state/etc/ssh volume read-write
          should not mount any volumes
        "booga" is a read-only app container
          should exist
          should be running
          should run unprivileged
          should be created from jumanjiman/wormhole
          should use volumes from booga-data
          should have hostname wormhole.example.com
          should be limited to 512 MiB RAM
          `docker logs` should show sshd running on sshd port
          should expose internal sshd port and only sshd port
          should map internal sshd port to an outside ephemeral port

    arcanist (phabricator client)
      `arc` is in user path
      `arc version` is functional
      uses bash autocompletion

    BZ1099206 (slow test)
      home directory should exist
      go get should work

    user convenience
      man -k returns results
      locate returns the path for issue.net

    eiffelstudio
      has command-line eiffel compiler in path
      has estudio in path

    ldc D compiler
      compiles a D program

    SCAP secure configuration checks (slow test)
      should pass all tests
      /etc/securetty should be a zero-size file

    prohibited packages
      should not have at installed
      should not have prelink installed
      should not have sudo installed

    prohibited commands
      should not have the at command
      should not have the crond command
      should not have the crontab command
      should not have the /usr/sbin/prelink command

    rhc (openshift client)
      `rhc` is in user path
      `rhc --version` is functional

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
        "user" cannot su

    Finished in 1 minute 6.35 seconds (files took 0.45472 seconds to load)
    61 examples, 0 failures


The OpenSCAP secure configuration test shown above uses a
[tailoring file](wormhole/wormhole-devenv-xccdf.xml)
to adjust the upstream checks.
It expands to this inside the container:

    Title   gpgcheck Enabled In Main Yum Configuration
    Rule    ensure_gpgcheck_globally_activated
    Result  pass

    Title   gpgcheck Enabled For All Yum Package Repositories
    Rule    ensure_gpgcheck_never_disabled
    Result  pass

    Title   Shared Library Files Have Restrictive Permissions
    Rule    file_permissions_library_dirs
    Result  pass

    Title   Shared Library Files Have Root Ownership
    Rule    file_ownership_library_dirs
    Result  pass

    Title   System Executables Have Restrictive Permissions
    Rule    file_permissions_binary_dirs
    Result  pass

    Title   System Executables Have Root Ownership
    Rule    file_ownership_binary_dirs
    Result  pass

    Title   Direct root Logins Not Allowed
    Rule    no_direct_root_logins
    Result  notchecked

    Title   Virtual Console Root Logins Restricted
    Rule    securetty_root_login_console_only
    Result  pass

    Title   Serial Port Root Logins Restricted
    Rule    restrict_serial_port_logins
    Result  pass

    Title   Only Root Has UID 0
    Rule    no_uidzero_except_root
    Result  pass

    Title   Log In to Accounts With Empty Password Impossible
    Rule    no_empty_passwords
    Result  pass

    Title   Password Hashes For Each Account Shadowed
    Rule    no_hashes_outside_shadow
    Result  pass

    Title   netrc Files Do Not Exist
    Rule    no_netrc_files
    Result  pass

    Title   SSH Root Login Disabled
    Rule    sshd_disable_root_login
    Result  pass

    Title   SSH Access via Empty Passwords Disabled
    Rule    sshd_disable_empty_passwords
    Result  pass

    Title   SSH Idle Timeout Interval Used
    Rule    sshd_set_idle_timeout
    Result  pass

    Title   SSH Client Alive Count Used
    Rule    sshd_set_keepalive
    Result  pass


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

### Edit global configuration

Clone this repo, then inspect and optionally modify `global.conf`.
When you build a user box for the first time, the build script
copies `global.conf` into `/etc/wormhole/global.conf`.


### Edit duo configuration

This step is optional. The default configuration **does not use Duo**.
If you want to use Duo Security for multi-factor authentication,
you must edit both `global.conf` and `login_duo.conf`.

* When you build your first user box (see below), these two files
  are copied into `/etc/wormhole/`.

* If you modify `/etc/wormhole/*.conf`, you must restart the user
  app container(s).


### Build a user box

Use the build script with a unique user id (such as github handle)
and the user ssh pubkey to create a runtime container:

    user=jumanjiman
    pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArSm80/8UD/eMolUXU3j6geyNrxthnQxbE4dpwRhXU+F6fbQG+wk9SdWev9NcLLWg9a4zBUSMJUXrrU/8ik3WshSpZpqQary4ZiFFQKgSfYriouchc20S3wwFQZcbOJgH5t5wgGeNaDMzc2GRFhqbuuBiBBF+W5llk0X9CGE1o1iAlyVPAn4UfrJ4//5OXMhYwmU+fO9df3y5Kpn/0SY/lRwWuZeVVIXC+nZcFYXNzPyBVTNEooOXLVXivddtU82jfp65ggTMdLfUafZqia1/smfWQP23lU8F4ySayAOa1lhXXvrGtpxl3lu7vaSvdEg7+F4YaIhxnWZqt769joDraw== pmorgan@github"

    ./build.sh $user "$pubkey"

:warning: The build script attempts to fetch the github user's
ssh pubkeys and place them into the data container as authorized keys.
This is *really* bad if you create a devenv for somebody based on
a name that is *not* their github handle and the name is a valid
github handle for somebody else!

A runtime container should be up on a random ssh port:

    $ docker ps

    CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                   NAMES
    689479673e8e        jumanjiman:latest   /bin/sh -c /usr/sbin   About an hour ago   Up About an hour    0.0.0.0:49153->22/tcp   jumanjiman

The build script depends on systemd and enables a "wormhole@<username>"
service to start at boot-time for the container you just created and
persists the port as an environment variable in `/etc/wormhole/<username>.conf`.
For example: If the username is jumanjiman, you can run
`sudo systemctl status wormhole@jumanjiman` to see:

    ● wormhole@jumanjiman.service - jumanjiman app container
       Loaded: loaded (/etc/systemd/system/wormhole@.service; enabled)
       Active: active (running) since Wed 2014-06-18 14:08:05 UTC; 3h 18min ago
     Main PID: 701 (docker)
       CGroup: /system.slice/system-wormhole.slice/wormhole@jumanjiman.service
               └─701 /usr/bin/docker run --rm -t -m 512m --volumes-from jumanjiman-data -p 49153:22 -h wormhole.example.com --name jumanjiman...


    Jun 18 14:08:05 ip-192-168-254-21 bash[478]: jumanjiman
    Jun 18 14:08:05 ip-192-168-254-21 systemd[1]: Started jumanjiman app container.
    Jun 18 14:08:09 ip-192-168-254-21 docker[701]: Server listening on 0.0.0.0 port 22.
    Jun 18 14:08:09 ip-192-168-254-21 docker[701]: Server listening on :: port 22.

:warning: The default `global.conf` limits each app container to 512 MiB memory.
You can override this for a single user in `/etc/wormhole/<username>.conf`.

You can view the current limit for a container via the sys filesystem.
For example, here is a container that was started with a 1 MiB limit:

    $ cat /sys/fs/cgroup/memory/lxc/<hash>/memory.limit_in_bytes
    1048576

If a PID inside a container gets killed due to the memory limit,
you can view details in `dmesg` output.


### Backup

Create a local file called `jumanjiman-data.tar` with contents of
user data container.

    ./backup.sh jumanjiman


### Restore user data container from backup

    ./restore.sh jumanjiman


### Upgrade user app container

Rebuild the `jumanjiman/wormhole` image as described above, then...

    ./upgrade.sh jumanjiman


### Destroy a user app+data container

Backup, then discard both the app and data containers for a user.

    ./destroy.sh jumanjiman


### Build an image for the app container

This image serves as a template for an app container.<br/>
You can build the image locally or use the
[**Trusted Build**](https://index.docker.io/u/jumanjiman/wormhole/).

    cd wormhole/
    docker build --rm -t jumanjiman/wormhole --no-cache .

:warning: Use CoreOS to build image.

Fedora kernel on DigitalOcean
has an older LXC implementation that leads to inconsistent builds.
For example, it sometimes builds the base image with bad perms on
`/var` and other directories that *must* be `0755`.
