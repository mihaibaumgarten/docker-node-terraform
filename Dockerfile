
FROM openjdk:8-jdk

ARG VERSION=3.33
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ENV HOME /home/${user}
RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d $HOME -u ${uid} -g ${gid} -m ${user}
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="${VERSION}"

ARG AGENT_WORKDIR=/home/${user}/agent

RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/stretch-backports.list
 RUN apt-get update && apt-get install -t stretch-backports git-lfs
RUN curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

COPY jenkins-slave /usr/local/bin/jenkins-slave

ENTRYPOINT ["jenkins-slave"]

ENV TERRAFORM_VERSION=0.12.0
ENV TERRAFORM_SHA256SUM=42ffd2db97853d5249621d071f4babeed8f5fdba40e3685e6c1013b9b7b25830

# Download and install Terraform
USER root
RUN apk add --update make git curl curl-dev openssh && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
   
# Install latest nodejs  
RUN apk add --update nodejs nodejs-npm

# Install dependencies of canvas needed to build webpack
RUN apk add --update \
    && apk add --no-cache ffmpeg opus pixman cairo pango giflib ca-certificates \
    && apk add --no-cache --virtual .build-deps git curl build-base jpeg-dev pixman-dev \
    cairo-dev pango-dev pangomm-dev libjpeg-turbo-dev giflib-dev freetype-dev python g++ make nodejs npm chromium jq
#RUN apk --no-cache add --update python

# Install AWS CLI
RUN wget "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -O "awscli-bundle.zip"
RUN unzip awscli-bundle.zip && chmod +x ./awscli-bundle/install
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN rm awscli-bundle.zip && rm -rf awscli-bundle && rm /var/cache/apk/*

# Install ZIP
RUN apk --no-cache add --update zip
