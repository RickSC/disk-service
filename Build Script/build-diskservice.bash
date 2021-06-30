#!/usr/bin/env bash
 
DOCKER_TAG=${DOCKER_TAG:-latest}
DOCKER_PREFIX=${DOCKER_PREFIX:-registry:5000}
IMAGE_NAME=${IMAGE_NAME:-disk-service}
delim=/
delim2=:

cat <<EOF >> Dockerfile
FROM registry.fedoraproject.org/fedora-minimal:34

RUN microdnf update -y && microdnf install -y nbdkit && microdnf install -y qemu-img

EXPOSE 10809

CMD nbdkit -fr file dir='/images'

EOF
for var in "$@"
do
IFS=/
read -a strarr <<< "$var"
endarr="${strarr[${#strarr[@]}-1]}"
printf "$endarr\n"
IFS=:
read -a strarr <<< "$endarr"
endarr="${strarr[0]}"
printf "$endarr\n"

cat <<EOF >> Dockerfile
COPY --from=$var /disk/* /images/$endarr.qcow2

RUN qemu-img convert -O raw /images/$endarr.qcow2 /images/$endarr.iso && rm /images/$endarr.qcow2

EOF
done

echo "Building image ${DOCKER_PREFIX}/${IMAGE_NAME}:${DOCKER_TAG}"
docker build -t "${DOCKER_PREFIX}/${IMAGE_NAME}:${DOCKER_TAG}" -f Dockerfile .
 
echo "Pushing image ${DOCKER_PREFIX}/${IMAGE_NAME}:${DOCKER_TAG}"
docker push "${DOCKER_PREFIX}/${IMAGE_NAME}:${DOCKER_TAG}"
 
cat <<EOF >> service.yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  name: diskservice
spec:
  ports:
  - port: 10809
    protocol: TCP
    targetPort: 10809
  selector:
    run: diskservice
status:
  loadBalancer: {}
---
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: diskservice
  labels:
    run: diskservice
spec:
  replicas: 1
  selector:
    matchLabels:
      run: diskservice
  template:
    metadata:
      labels:
        run: diskservice
    spec:
      containers:
      - name: nbdkit
        ports:
        - containerPort: 10809
        image: registry:5000/${IMAGE_NAME}:${DOCKER_TAG}
        imagePullPolicy: IfNotPresent
        command: ["/bin/sh"]
        args: ["-c", "nbdkit -fr file dir='/images' && tail -f /dev/null"]
EOF

echo "Done"
