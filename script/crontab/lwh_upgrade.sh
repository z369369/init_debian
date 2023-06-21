#!/bin/bash
flatpak update --noninteractive --assumeyes
flatpak uninstall --unused --noninteractive --assumeyes
