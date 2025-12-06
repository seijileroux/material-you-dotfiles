#!/bin/bash

hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
hyprpm enable hyprscrolling
hyprpm add https://github.com/KZDKM/Hyprspace
hyprpm enable Hyprspace
hyprpm add https://github.com/zakk4223/hyprWorkspaceLayouts
hyprpm enable /hyprWorkspaceLayouts
hyprpm reload