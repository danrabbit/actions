#!/bin/bash
set -e

#--------------------------------#
# Install the build dependencies #
#--------------------------------#

echo "Setting up git credentials..."
git config --global user.email "action@github.com"
git config --global user.name "GitHub Action"
echo "Git credentials configured."

# make sure we are in sync with HEAD
git reset --hard HEAD

# merge the debian packaging branch
if ! git merge origin/deb-packaging --allow-unrelated-histories --no-commit; then
  echo "\033[0;31mERROR: Unable to merge the 'deb-packaging' branch. Does it exist?\033[0m" && exit 1
fi

# Create a fake package depending on the build dependency and install/remove it
sudo apt -y update
mk-build-deps --build-dep --install --remove --tool 'apt -y' --root-cmd sudo debian/control

echo -e "\n\033[1;32mInstalled all the build dependencies!\033[0m\n"

if [[ -O /home/$USER/tmp && -d /home/$USER/tmp ]]; then
    TMPDIR=/home/$USER/tmp
else
    # You may wish to remove this line, it is there in case
    # a user has put a file 'tmp' in there directory or a
    mkdir -p /home/$USER/tmp
    TMPDIR=$(mktemp -d /home/$USER/tmp/XXXX)
fi

TMP=$TMPDIR
TEMP=$TMPDIR

export TMPDIR TMP TEMP

# Build from packaging
debuild -rsudo -b -us -uc
