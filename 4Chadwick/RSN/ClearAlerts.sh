#!/usr/bin/sh
# clear flag 1 in Alert files
sed --in-place 's/^ 1 / 0 /'  */*AlertStatus*
