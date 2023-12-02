FROM sbo-cicd-docker-release-local.usw1.packages.broadcom.com/broadcom-custom-images/redhat/ubi/buildah:1.23.2
USER root
RUN dnf install -y podman-docker && dnf install -y go
RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/helm/latest/helm-linux-amd64 -o /usr/bin/helm && chmod +x /usr/bin/helm
RUN go install github.com/brendanjryan/k8split@latest
RUN curl -SL https://github.com/docker/compose/releases/download/v2.23.1/docker-compose-linux-x86_64 -o /usr/bin/docker-compose && chmod +x /usr/bin/docker-compose
COPY --chown=default:default bin/linux-amd64/gotpl /usr/bin/gotpl
USER buildah