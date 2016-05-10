#!/bin/bash
name=$1

if [[ -n "$name" ]]; then
    ssh scottnm@"$name".cs.utexas.edu
else
    ssh scottnm@linux.cs.utexas.edu
fi
