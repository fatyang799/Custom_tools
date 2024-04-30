#!/bin/bash
# only retain chr1-chr22, chrX, chrY
grep ^chr $1 | grep -v chrM > $2

