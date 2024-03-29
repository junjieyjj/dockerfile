# Build Jnlp image
FROM adoptopenjdk/openjdk8:jdk8u292-b10-centos as jnlp

ARG VERSION=4.7

COPY jenkins-agent /usr/local/bin/jenkins-agent

RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
  && yum install -y git docker-ce docker-ce-cli containerd.io \
  && curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && chmod +x /usr/local/bin/jenkins-agent

# Build CI image
FROM adoptopenjdk/openjdk8:jdk8u292-b10-centos

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent
COPY --from=jnlp /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar
COPY --from=jnlp /usr/bin/docker /usr/bin/docker

# Install Tools
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
  && yum install -y python3 python3-pip unzip jq git gettext

# Install Maven
ARG MAVEN_VERSION=3.8.1
ARG USER_HOME_DIR="/root"
ARG SHA=0ec48eb515d93f8515d4abe465570dfded6fa13a3ceb9aab8031428442d9912ec20f066b2afbf56964ffe1ceb56f80321b50db73cf77a0e2445ad0211fb8e38d
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ADD settings.xml /usr/share/maven/conf/settings.xml

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# Install Nvm and Multi Node Version
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.38.0/install.sh | bash

ENV NODE_VERSION 8.17.0

# install node and npm LTS
RUN source ~/.nvm/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && nvm install 10.24.1 \
    && nvm install 12.22.1

# add node and npm to path so the commands are available
# ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
# ENV PATH $NVM_DIR/versions/node/v8.17.0/bin:$NVM_DIR/versions/node/v10.24.1/bin:$NVM_DIR/versions/node/v12.22.1/bin:$PATH

# Install Anaconda and Multi Python Version
# Anaconda is very bigger, https://www.anaconda.com/products/individual

# Install CI TOOLS
ARG HELM_VERSION=3.5.4
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -fr awscliv2.zip aws \
  && curl https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm-v${HELM_VERSION}-linux-amd64.tar.gz \
  && tar zxf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
  && mv linux-amd64/helm /usr/local/bin \
  && chmod +x /usr/local/bin/helm \
  && rm -fr helm-v${HELM_VERSION}-linux-amd64.tar.gz linux-amd64/ \
  && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && chmod +x kubectl \
  && mv kubectl /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
