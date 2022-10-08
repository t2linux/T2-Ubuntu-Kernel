#!/bin/bash

echo "Latest Mainline"
curl -sL https://kernel.org/ | grep "latest_button" -A 1 | awk "NR==2" | cut -d "/" -f 8 | cut -d "\"" -f 1 | cut -d "-" -f 2 | rev | cut -c 8- | rev
echo -e "\nLatest LTS"
LTS_VER=5.15
curl -sL https://kernel.org/ | grep ${LTS_VER} | grep tar.xz | cut -d "/" -f 8 | cut -d "\"" -f 1 | cut -d "-" -f 2 | rev | cut -c 8- | rev
