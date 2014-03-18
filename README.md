This repo is a temporary home to store a project
while I work on getting it ready for open-source.


## Requirements

* Must run on CoreOS. Therefore no outside dependencies.
* User data must reside in data container separate from apps.


## Brief instructions

### Build an image for the app container

This image serves as a template for user images.

```
docker build -rm -t booga -no-cache .
```


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
b2dd80d4893a        jstrong:latest      /bin/sh -c /usr/sbin   About an hour ago   Up About an hour    0.0.0.0:49155->22/tcp   jstrong-run  
       
689479673e8e        jumanjiman:latest   /bin/sh -c /usr/sbin   About an hour ago   Up About an hour    0.0.0.0:49153->22/tcp   jumanjiman-run      
```


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

Rebuild the `booga` image as described above, then...

```
./upgrade.sh jumanjiman
```
