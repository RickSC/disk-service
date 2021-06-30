# disk-service

## Description

A service to provide ISOs to multiple VMs simultaneously.

## Getting Started

### Installing

* How/where to download your program
* Any modifications needed to be made to files/folders

### Operation

#### Description

This scripts creates a Dockerfile, a service.yaml file, and builds/pushes the diskservice image. If any file named "Dockerfile" or "service.yaml" exists in the same directory, they will be deleted before the script creates its own files.

#### Envrionmental Variables

The script uses a number of environmental variables. These variables can be set by the user to fit their system. The environmental variables are DOCKER_PREFIX, DOCKER_TAG, and IMAGE_NAME.
* DOCKER_PREFIX can be set to the repo name (quay.io, dockerhub, etc.).
* DOCKER_TAG is the image tag.
* IMAGE_NAME is the name of the image within the repo.

#### Running the Script

* To run the script, use a command formatted like the example below.
  * Multiple images can be accepted with this command.
```
./build-diskservice.bash <DOCKER_PREFIX>/<IMAGE_NAME>:DOCKER:TAG

``` 
* Run service.yaml using the example below.
```
kubectl apply -f path/to/service.yaml

```
* The disk-service should now be running.

## Example

### Requirements

This example requires [Kubevirt - network-volume](https://github.com/RickSC/kubevirt/tree/network-volume) branch to work correctly. Before attempting to use this example, ensure the branch has been downloaded and you have run the following commands:
```
make cluster generate
make cluster sync
```

### Steps

The following example runs build-diskservice.bash, starts the service, and creates a virtual machine to access the service.

* Run build-diskservice.bash.
```
./build-test.bash quay.io/kubevirt/virtio-container-disk:v0.42.1 quay.io/kubevirt/fedora-cloud-container-disk-demo:v0.42.1 quay.io/kubevirt/alpine-container-disk-demo:v0.42.1

```
* Start service.yaml.
```
kubectl apply -f path/to/service.yaml

```
* Start virt.yaml.
```
kubectl apply -f path/to/virt.yaml

```
* VNC to the VM.
```
virtctl vnc vmi-fedora

```
* Login to the VM.
```
User: fedora
Pass: fedora
```
* Make directory.
```
sudo mkdir /mnt/cdrom
```
* Mount.
```
sudo mount /dev/sr0 /mnt/cdrom
```
* Change directory.
```
cd /mnt/cdrom
```
* Check contents to verify successful mount.

### Help

If you are using the virt.yaml example file, ensure you have the correct image, uri, and format.

```
- containerDisk:
    image: registry:5000/quay.io/kubevirt/fedora-cloud-container-disk-demo:v0.42.1 
  name: containerdisk
- networkVolume:
    uri: nbd://diskservice/virtio-container-disk.iso
    format: raw
  name: cdromcontainerdisk
```

## License

This project is licensed under the [APACHE LICENSE, VERSION 2.0](https://www.apache.org/licenses/LICENSE-2.0) License - see the LICENSE.md file for details
