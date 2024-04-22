FROM quay.io/podman/stable
USER root
RUN dnf -y update; yum -y reinstall shadow-utils;
RUN echo "[jfrog-cli]" > jfrog-cli.repo && echo "name=jfrog-cli" >> jfrog-cli.repo && echo "baseurl=https://releases.jfrog.io/artifactory/jfrog-rpms" >> jfrog-cli.repo && echo "enabled=1" >> jfrog-cli.repo && rpm --import https://releases.jfrog.io/artifactory/jfrog-gpg-public/jfrog_public_gpg.key && mv jfrog-cli.repo /etc/yum.repos.d/
RUN dnf -y install buildah slirp4netns iputils podman-docker python3.11 go maven-openjdk11.noarch nodejs jfrog-cli git fuse-overlayfs --exclude container-selinux
RUN curl -fL https://install-cli.jfrog.io | sh

RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/helm/latest/helm-linux-amd64 -o /usr/bin/helm && chmod +x /usr/bin/helm
RUN userdel podman && useradd buildah && usermod -u 1000 buildah; \
echo buildah:10000:65536 > /etc/subuid; \
echo buildah:10000:65536 > /etc/subgid;
COPY --chown=buildah:buildah ../../bin/linux-amd64/gotpl /usr/bin/gotpl

COPY podman-containers.conf /home/buildah/.config/containers/containers.conf

RUN chown -R buildah:buildah /home/buildah

USER buildah
RUN go install github.com/brendanjryan/k8split@latest
ENV PATH="${PATH}:/home/buildah/go/bin:/home/buildah/.local/bin"
RUN python3.11 -m ensurepip
RUN pip3.11 install podman-compose --user
