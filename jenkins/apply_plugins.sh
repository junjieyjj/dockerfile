#!/usr/bin/sh

version () { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

if [ -n "$(command -v jenkins-plugin-cli)" 2>/dev/null ] && [ $(version $(jenkins-plugin-cli --version)) -ge $(version "2.1.1") ]; then
    jenkins-plugin-cli --plugin-file "tmp/plugins.txt";
else
    /usr/local/bin/install-plugins.sh `echo $(cat tmp/plugins.txt)`;
fi