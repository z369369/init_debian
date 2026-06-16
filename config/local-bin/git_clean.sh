#!/bin/bash

git fetch --all

git reflog expire --expire=now --all

git gc --prune=now --aggressive