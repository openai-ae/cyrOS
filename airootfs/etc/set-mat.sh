#!/bin/bash

# Check if this is the first boot (if a specific file does not exist)
if [ ! -f /etc/.firstboot ]; then
    # Set the GTK theme (replace "Arc-Dark" with your custom theme)
    gsettings set org.gnome.desktop.interface gtk-theme "custom-dark"

    # Mark that the first boot has been completed
    touch /etc/.firstboot
fi
