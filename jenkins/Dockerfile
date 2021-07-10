FROM jenkins/jenkins:2.215-centos7

ADD plugins.txt tmp/plugins.txt
ADD apply_plugins.sh /tmp/apply_plugins.sh

RUN sh /tmp/apply_plugins.sh