---
title: RHEL change container storage location
description: RHEL change the location of the storage folder for containers
---

# RHEL change container storage location

The storage location where images are stored for standard users images are typically in `$HOME/.local/share/containers/storage/`.  
In some cases it can be useful to change this location.

> [!warning]  
> If you change the `graphroot` location, you must ensure that SELinux labeling is correct for the new location. See [here](#selinux-configuration) for an example.  

## Update the location

To override the location of the folder containing the images create and edit the following file:  

```sh
nano ~/.config/containers/storage.conf 
```

Copy/Paste the following adapting the `graphroot` parameter to point to the desired folder. In the below example the images will be stored in `/share/containers/storage`.

```sh
[storage]
  graphroot = "/share/containers/storage"
```

Modification of theses parameters requires a reset of the podman service. Run the following command as root:

```sh
podman system reset
```

To validate the change please run the following command:

```sh
podman info | grep "graphRoot:"
```

## SELinux configuration

As mentioned when updating the location it is necessary to ensure that the SELinux labeling is correct for the updated location.  

> The following commands are provided as an example.

All following commands are to be executed as root.

First, clean-up and re-create the necessary folder structure. In the following commands the `graphroot` path is configured to be `/share/containers/storage`. Please adapt to your context.

```sh
sudo rm -rf /share/containers/
mkdir -p /share/containers
```

Second, update the ownership of the folder to correspond to the user running podman. In the following case the local user is `radiantlogic`.

```sh
chown radiantlogic:radiantlogic /share/containers
chmod go-rwx /share/containers
```

Third, update the SELinx configuration  

```sh
semanage fcontext -a -s unconfined_u -t container_ro_file_t "/share/containers/storage/overlay(/.*)?"
semanage fcontext -a -s unconfined_u -t container_ro_file_t "/share/containers/storage/overlay-images(/.*)?"
semanage fcontext -a -s unconfined_u -t container_ro_file_t "/share/containers/storage/overlay-layers(/.*)?"
semanage fcontext -a -s unconfined_u -t container_ro_file_t "/share/containers/storage/overlay2(/.*)?"
semanage fcontext -a -s unconfined_u -t container_ro_file_t "/share/containers/storage/overlay2-images(/.*)?"
semanage fcontext -a -s unconfined_u -t container_ro_file_t "/share/containers/storage/overlay2-layers(/.*)?"
semanage fcontext -a -s unconfined_u -t container_file_t "/share/containers/storage/volumes/[^/]*/.*"
restorecon -R -v /share/containers
sudo semanage fcontext -a -e /var/lib/containers /share/containers
restorecon -R -v /share/containers
```

Finally, reset podman for the changes to apply:

```sh
podman system reset
```

To validate the changes you can use the following commands to read the policies:

```sh
sudo semanage fcontext -l
```

or to limit on the desired folder:

```sh
sudo semanage fcontext -l | grep /share/containers
```

To clean up old policies, the following command can be used as root. Theses commands delete the policies for a given path.  

```sh  
sudo semanage fcontext -D "/share/containers/storage/overlay(/.*)?"
```

## More information

For more information please refer to https://docs.oracle.com/en/operating-systems/oracle-linux/podman/podman-ConfiguringStorageforPodman.html#podman-containers-mounts.  
