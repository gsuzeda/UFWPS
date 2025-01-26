#!/bin/bash

# ANSI Colors
YELLOW=$'\e[1;33m'
LIGHT_BLUE=$'\e[1;34m'
RED=$'\e[1;31m'
GREEN=$'\e[1;32m'
NC=$'\e[0m'

# Custom print function
out() {
    local text="$1"
    local color="${NC}"
    local position="left"

    # Dynamically identify additional arguments
    for arg in "${@:2}"; do
        case "$arg" in
        warning) color="${YELLOW}" ;;
        info) color="${LIGHT_BLUE}" ;;
        danger) color="${RED}" ;;
        success) color="${GREEN}" ;;
        left | center | right) position="$arg" ;;
        esac
    done

    # Calculate the actual length of the text (without ANSI sequences)
    local clean_text="${text}"
    local text_length="${#clean_text}"

    # Adjust text positioning
    local term_width
    term_width=$(tput cols)

    case "$position" in
    center)
        local padding=$(((term_width - text_length) / 2))
        printf "%*s%s%*s\n" "$padding" "" "${color}${text}${NC}" "$padding" ""
        ;;
    right)
        printf "%*s\n" "$term_width" "${color}${text}${NC}"
        ;;
    *)
        printf "%s\n" "${color}${text}${NC}"
        ;;
    esac
}

#Custom read input
input() {
    local prompt="$1"
    read -s -n1 -p "$prompt" option
    echo $option
}

# Menu function
menu() {
    clear
    echo
    out "╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮" center
    out "┃                                                                             ┃" center
    out "┃                   ██╗   ██╗███████╗██╗    ██╗██████╗ ███████╗               ┃" center
    out "┃                   ██║   ██║██╔════╝██║    ██║██╔══██╗██╔════╝               ┃" center
    out "                    ██║   ██║█████╗  ██║ █╗ ██║██████╔╝███████╗                " center
    out "┃                   ██║   ██║██╔══╝  ██║███╗██║██╔═══╝ ╚════██║               ┃" center
    out "┃                   ╚██████╔╝██║     ╚███╔███╔╝██║     ███████║               ┃" center
    out "                     ╚═════╝ ╚═╝      ╚══╝╚══╝ ╚═╝     ╚══════╝                " center
    out "┃                                                                             ┃" center
    out "Welcome to Ultimate Fedora Workstation Post Script Installation" center
    out "┃                                                                             ┃" center
    out "┃                                                                             ┃" center
    out "⚡ Your System Will Be Ready Soon ⚡" center
    out "┃                                                                             ┃" center
    out "┃                          { by:  Uzeda (@gsuzeda) }                          ┃" center
    out "┃                                                                             ┃" center
    out "╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯" center
    echo
    out "Please select an option:" center info
    echo
    out "[S]tart Installation" center success
    out "[E]xit" center danger
    echo
    option=$(input)
    echo

    case $option in
    [Ss])
        cp -r "$PWD" /tmp/UFWPS
        cd "/tmp/UFWPS"
        debloat
        echo
        echo
        optimizations
        echo
        echo
        install_theme_prompt
        echo
        echo
        install_extensions_prompt
        echo
        echo
        out "Script finished successfully, I hope you like the result and remember to restart your system" center success
        ;;
    [Ee])
        out "Bye Bye 👋" center
        exit 0
        ;;
    *)
        echo "Invalid option. Please try again."
        sleep 2
        menu
        ;;
    esac
}

# Debloat function
debloat() {
    local apps=("$@")

    # If no apps are passed, initialize the full list
    if [[ ${#apps[@]} -eq 0 ]]; then
        apps=(
            "gnome-connections" "anaconda" "gnome-characters" "gnome-classic-session"
            "gnome-contacts" "gnome-maps" "gnome-photos" "gnome-remote-desktop"
            "gnome-system-monitor" "gnome-tour" "gnome-user-docs" "yelp"
            "cheese" "rhythmbox" "totem" "libreoffice-core"
            "gnome-boxes" "unoconv" "gnome-weather" "gnome-clocks"
            "gnome-calculator" "simple-scan" "mediawriter" "gnome-font-viewer"
            "evince" "gnome-disk-utility" "baobab" "eog"
            "gnome-calendar" "gnome-software" "gnome-logs" "loupe"
            "abrt" "snapshot" "firefox"
        )
    fi

    clear
    out "Applications to be removed:" center info
    echo

    # Calculate columns based on terminal width
    local term_width=$(tput cols)
    local col_width=30
    local columns=$((term_width / col_width))
    if [[ $columns -lt 1 ]]; then columns=1; fi
    local rows=$(((${#apps[@]} + columns - 1) / columns))

    # Display apps in a grid
    for ((i = 0; i < rows; i++)); do
        for ((j = 0; j < columns; j++)); do
            local index=$((i + j * rows))
            if [[ $index -lt ${#apps[@]} ]]; then
                printf "${YELLOW}%-4s${NC} %-25s" "$((index + 1))" "${apps[$index]}"
            fi
        done
        echo
    done

    echo
    out "Enter the indices of the applications you want to exclude from removal, separated by spaces:" center
    out "Example: 1 5 12" center warning
    echo
    out "[C]onfirm current list for removal or [S]kip." center
    echo
    read -p "> " user_input

    # Check if the user chose to confirm or exit
    case "$user_input" in
    [Cc])
        sudo dnf remove -y "${apps[@]}"
        out "Applications removed successfully!" center success
        return
        ;;
    [Ss])
        out "Exiting without changes." center warning
        return
        ;;
    *)
        # Handle exclusion of apps
        local exclude_array=($user_input)
        local to_remove=()
        for i in "${!apps[@]}"; do
            if ! [[ " ${exclude_array[*]} " =~ " $((i + 1)) " ]]; then
                to_remove+=("${apps[$i]}")
            fi
        done

        # Restart debloat with updated list
        debloat "${to_remove[@]}"
        ;;
    esac
}

# Function to show help information for each prompt
show_help() {
    local help_context="$1"
    case "$help_context" in
        "theme")
            out "Theme Installation Details:" center info
            out "- Will install the Graphite GTK theme" left
            out "- Will install Papirus icon theme" left
            out "- Will set up wallpapers for light and dark modes" left
            out "- Will install an elegant GRUB theme" left
            out "- Changes will be fully visible after system restart" left warning
            ;;
        "extensions")
            out "GNOME Extensions Installation Details:" center info
            out "- Will install several productivity-enhancing extensions:" left
            out "  • Blur My Shell: Adds blur effects to shell elements" left
            out "  • App Indicators: Adds support for legacy tray icons" left
            out "  • Tiling Assistant: Improves window management" left
            out "  • Hide Top Bar: Automatically hides the top panel" left
            out "  • Clipboard Indicator: Manages clipboard history" left
            out "  • Caffeine: Prevents system from sleeping" left
            out "  • Fullscreen Notifications: Better notification handling" left
            out "  • Fuzzy App Search: Improves application search" left
            out "  • Quick Settings Tweaks: Enhances quick settings menu" left
            ;;
        "mitigations")
            out "Performance Mitigations Details:" center info
            out "- Will disable CPU security mitigations" left
            out "- Improves system performance" left
            out "- May slightly reduce system security" left danger
            out "- Recommended only for personal computers" left warning
            ;;
        "tkg")
            out "Custom TKG Kernel Installation Details:" center info
            out "- Will install an optimized kernel for your CPU" left
            out "- Provides better system responsiveness" left
            out "- Includes specific optimizations for your CPU architecture" left
            out "- Requires system restart to take effect" left warning
            ;;
        "firefox")
            out "Firefox Optimization Details:" center info
            out "- Will install OpenH264 codec support" left
            out "- Enables better video playback in Firefox" left
            out "- Improves compatibility with web content" left
            out "- Manual activation in Firefox settings required" left warning
            ;;
        "nvidia")
            out "NVIDIA Driver Installation Details:" center info
            out "- Will install proprietary NVIDIA drivers" left
            out "- Provides better graphics performance" left
            out "- Enables CUDA support (optional)" left
            out "- Requires system restart to take effect" left warning
            ;;
        "battery")
            out "Battery Optimization Details:" center info
            out "- Will install and configure TLP" left
            out "- Removes conflicting power management tools" left
            out "- Optimizes system for better battery life" left
            out "- Automatically manages power settings" left
            out "- Changes take effect after restart" left warning
            ;;
        *)
            out "No help available for this context" center warning
            ;;
    esac
    echo
    out "Press any key to continue..." center
    input ""
}

# Function to prompt user for theme installation
install_theme_prompt() {
    out "Do you want to install a custom theme?" center info
    echo
    out "[Y]es" center success
    out "[N]o" center danger
    out "[H]elp - Show more details" center info
    echo
    option=$(input)

    case $option in
    [Hh])
        show_help "theme"
        install_theme_prompt
        ;;
    [Yy])
        install_theme
        ;;
    [Nn])
        out "Skipping theme installation." center warning
        ;;
    *)
        out "Invalid option. Please try again." center danger
        install_theme_prompt
        ;;
    esac
}

# Function to prompt user for GNOME extension installation
install_extensions_prompt() {
    out "Do you want to install my personal GNOME extensions collection?" center info
    echo
    out "[Y]es" center success
    out "[N]o" center danger
    out "[H]elp - Show more details" center info
    echo
    option=$(input)

    case $option in
    [Hh])
        show_help "extensions"
        install_extensions_prompt
        ;;
    [Yy])
        install_extensions
        ;;
    [Nn])
        out "Skipping GNOME extension installation." center warning
        ;;
    *)
        out "Invalid option. Please try again." center danger
        install_extensions_prompt
        ;;
    esac
}

# Function to install the theme
install_theme() {
    out "Cloning and installing the theme..." center info
    git clone https://github.com/vinceliuice/Graphite-gtk-theme.git
    sudo ./Graphite-gtk-theme/install.sh -g -l -s compact --tweaks rimless float
    sudo dnf install -y papirus-icon-theme
    out "Theme and icon installation complete!" center success
    out "Setting Papirus as default icon theme..." center info
    gsettings set org.gnome.desktop.interface icon-theme "Papirus"
    sudo bash ./Graphite-gtk-theme/wallpaper/install-wallpapers.sh -s fedora
    gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/wave-Light-fedora.jpg'
    gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/wave-Dark-fedora.jpg'
    out "Installing grub theme" center info
    out "The theme will load completely after restarting the system" center warning
    git clone https://github.com/vinceliuice/Elegant-grub2-themes.git
    sudo ./Elegant-grub2-themes/install.sh -t mojave -p blur
}

install_extensions() {

    sudo dnf install -y gnome-extensions gnome-shell-extension-tool
    cp -r ./extensions/* ~/.local/share/gnome-shell/extensions/.
    # List of extension IDs
    extensions=(
        "blur-my-shell@aunetx"
        "appindicatorsupport@rgcjonas.gmail.com"
        "tiling-assistant@leleat-on-github"
        "hidetopbar@mathieu.bidon.ca"
        "clipboard-indicator@tudmotu.com"
        "caffeine@patapon.info" 
        "fullscreen-notifications@sorrow.about.alice.pm.me" 
        "gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com"
        "quick-settings-tweaks@qwreey"
    )

    # Install and enable each extension
    for ext in "${extensions[@]}"; do
        out "Enabling Extension: $ext" left info
        # Enable the extension
        gnome-extensions enable $ext
    done

    # Install QuickSettingsTweak (which needs to be done after a reboot)
    git clone https://github.com/qwreey/quick-settings-tweaks quicksettings
    # sed -i 's|glib-compile-schemas --targetdir=src/schemas src/schemas|glib-compile-schemas --targetdir=/tmp/UFWPS/quicksettings/src/schemas /tmp/UFWPS/quicksettings/src/schemas|g' ./quicksettings/install.sh
    cd ./quicksettings
    bash ./install.sh install
    cd ..

    # Check if the systemd user directory exists, if not, create it
    if [ ! -d ~/.config/systemd/user ]; then
        mkdir -p ~/.config/systemd/user
    fi

    # Create a systemd service to activate the extension after reboot at the user level
    echo "[Unit]
    Description=QuickSettingsTweak Setup

    [Service]
    Type=oneshot
    ExecStart=/usr/bin/gnome-extensions enable quick-settings-tweaks@qwreey
    ExecStartPost=rm -f ~/.config/systemd/user/oneshotsettingssetup.service
    RemainAfterExit=true

    [Install]
    WantedBy=default.target
    " | tee ~/.config/systemd/user/oneshotsettingssetup.service >/dev/null

    # Enable the systemd service to run at the next boot at the user level
    systemctl --user enable oneshotsettingssetup.service

    out "All extensions have been installed and enabled successfully!" center success
}

# Function to perform system optimizations
optimizations() {
    out "Starting system optimizations..." center info
    echo

    # Install RPM Fusion
    out "Installing RPM Fusion repositories..." left info
    sudo dnf install -y --quiet https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    # Enable S3 Deep Sleep for lower standby power consumption
    out "Enabling S3 Deep Sleep for reduced power consumption..." left info
    sudo grubby --update-kernel=ALL --args="mem_sleep_default=s2idle"

    # Disable NetworkManager-wait-online service for faster boot
    out "Disabling NetworkManager-wait-online service to speed up boot time..." left info
    sudo systemctl disable NetworkManager-wait-online.service

    # Fix timezone for dual boot
    out "Fixing timezone for dual boot compatibility..." left info
    sudo timedatectl set-local-rtc '0'

    # Prompt to disable performance mitigations
    out "Do you want to disable security performance mitigations for better performance? (Optional)" center warning
    out "[Y]es" center success
    out "[N]o" center danger
    out "[H]elp - Show more details" center info
    option=$(input)
    if [[ "$option" =~ [Hh] ]]; then
        show_help "mitigations"
        out "Do you want to disable security performance mitigations for better performance? (Optional)" center warning
        out "[Y]es" center success
        out "[N]o" center danger
        option=$(input)
    fi
    if [[ "$option" =~ [Yy] ]]; then
        out "Disabling performance mitigations..." left info
        sudo grubby --update-kernel=ALL --args="mitigations=off"
    else
        out "Skipping performance mitigations." left warning
    fi

    # Upgrade to multimedia non-free packages
    out "Upgrading multimedia packages to non-free versions..." left info
    sudo dnf5 group upgrade multimedia -y --quiet --assumeyes
    sudo dnf upgrade @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin --assumeyes --quiet

    # Install hardware acceleration packages
    out "Installing hardware acceleration packages..." left info
    sudo dnf install -y --quiet ffmpeg-libs libva libva-utils --allowerasing

    # Detect chipset automatically using lscpu
    out "Detecting the chipset..." center info
    cpu_info=$(lscpu)

    # Check if the processor is Intel or AMD
    if echo "$cpu_info" | grep -q "Intel"; then
        chipset="Intel"
        # Check Intel processor generation
        cpu_model=$(lscpu | grep "Model name" | awk -F': ' '{print $2}' | xargs)
        if [[ "$cpu_model" =~ (i7|i5|i3|Xeon) ]]; then
            # Check if it's a 5th generation or newer
            generation=$(echo "$cpu_model" | grep -oP '\d{4}' | head -n 1)
            if [[ "$generation" -ge 5000 ]]; then
                out "Intel CPU (5th Gen or newer) detected. Installing Intel hardware acceleration drivers..." left info
                sudo dnf swap --assumeyes --quiet libva-intel-media-driver intel-media-driver --allowerasing
                sudo dnf install -y --quiet libva-intel-driver
            else
                out "Intel CPU (older than 5th Gen) detected. Hardware acceleration may not be supported." left warning
            fi
        fi
    elif echo "$cpu_info" | grep -q "AMD"; then
        chipset="AMD"
        out "AMD chipset detected. Installing AMD hardware acceleration drivers..." left info
        sudo dnf swap --assumeyes --quiet mesa-va-drivers mesa-va-drivers-freeworld
        sudo dnf swap --assumeyes --quiet mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
    else
        chipset="Unknown"
    fi

    # If the chipset couldn't be identified, ask the user
    if [[ "$chipset" == "Unknown" ]]; then
        out "Chipset not detected automatically. Would you like to continue with hardware acceleration driver installation? [Y/N]" center info
        option=$(input)
        if [[ "$option" =~ [Yy] ]]; then
            out "Skipping hardware acceleration driver installation." left warning
        fi
    fi

    # Prompt to install a custom TKG kernel
    out "Would you like to install a custom TKG kernel? [Y/N]" center info
    out "[Y]es" center success
    out "[N]o" center danger
    out "[H]elp - Show more details" center info
    option=$(input)
    if [[ "$option" =~ [Hh] ]]; then
        show_help "tkg"
        out "Would you like to install a custom TKG kernel? [Y/N]" center info
        out "[Y]es" center success
        out "[N]o" center danger
        option=$(input)
    fi
    if [[ "$option" =~ [Yy] ]]; then
        # Detect CPU family and model
        cpu_family=$(lscpu | grep "CPU family" | awk -F': ' '{print $2}' | xargs)
        cpu_model=$(lscpu | grep "Model:" | awk -F': ' '{print $2}' | xargs)

        # Determine the kernel repo and package based on CPU family and model
        local kernel_repo=""
        local kernel_package=""

        if [[ "$cpu_family" -eq 25 ]]; then
            if [[ "$cpu_model" -ge 80 ]]; then
                out "AMD Zen2+ detected. Selecting zen2-preempt kernel..." left info
                kernel_repo="whitehara/kernel-tkg-zen2-preempt"
                kernel_package="kernel-tkg-zen2-preempt"
            else
                out "AMD CPU detected. Selecting zen kernel..." left info
                kernel_repo="whitehara/kernel-tkg-preempt"
                kernel_package="kernel-tkg-preempt"
            fi
        elif [[ "$cpu_family" -eq 6 ]]; then
            if [[ "$cpu_model" -ge 166 && "$cpu_model" -lt 170 ]]; then
                out "Intel Ice Lake detected. Selecting icelake-preempt kernel..." left info
                kernel_repo="whitehara/kernel-tkg-icelake-preempt"
                kernel_package="kernel-tkg-icelake-preempt"
            elif [[ "$cpu_model" -ge 170 ]]; then
                out "Intel Alder Lake detected. Selecting alderlake-preempt kernel..." left info
                kernel_repo="whitehara/kernel-tkg-alderlake-preempt"
                kernel_package="kernel-tkg-alderlake-preempt"
            else
                out "Intel CPU detected. Selecting preempt kernel..." left info
                kernel_repo="whitehara/kernel-tkg-preempt"
                kernel_package="kernel-tkg-preempt"
            fi
        else
            out "Unknown CPU family or architecture. Selecting preempt kernel..." left warning
            kernel_repo="whitehara/kernel-tkg-preempt"
            kernel_package="kernel-tkg-preempt"
        fi

        # Enable the selected TKG repository and install the kernel
        out "Enabling TKG repository: $kernel_repo and installing TKG kernel: $kernel_package..." left info
        sudo dnf copr enable "$kernel_repo" --assumeyes --quiet
        sudo dnf update --refresh --nobest --assumeyes --quiet
        #sudo dnf install -y --quiet "$kernel_package"

        out "Custom TKG kernel installation complete. A reboot is required to apply changes." center success
    else
        out "Skipping custom TKG kernel installation." left warning
    fi

    # Check if the user uses Firefox
    out "Do you use Firefox? [Y/N]" center info
    out "[Y]es" center success
    out "[N]o" center danger
    out "[H]elp - Show more details" center info
    option=$(input)
    if [[ "$option" =~ [Hh] ]]; then
        show_help "firefox"
        out "Do you use Firefox? [Y/N]" center info
        out "[Y]es" center success
        out "[N]o" center danger
        option=$(input)
    fi
    if [[ "$option" =~ [Yy] ]]; then
        out "Installing OpenH264 and enabling support for Firefox..." left info
        sudo dnf install -y --quiet firefox openh264 gstreamer1-plugin-openh264 mozilla-openh264
        sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
        out "Enable OpenH264 Plugin in Firefox's settings after installation." left warning
    fi

    # Check if the user has an NVIDIA GPU
    out "Do you have an NVIDIA graphics card? [Y/N]" center info
    out "[Y]es" center success
    out "[N]o" center danger
    out "[H]elp - Show more details" center info
    option=$(input)
    if [[ "$option" =~ [Hh] ]]; then
        show_help "nvidia"
        out "Do you have an NVIDIA graphics card? [Y/N]" center info
        out "[Y]es" center success
        out "[N]o" center danger
        option=$(input)
    fi
    if [[ "$option" =~ [Yy] ]]; then
        out "Installing NVIDIA drivers..." left info
        sudo dnf install -y --quiet akmod-nvidia

        # Check if the user uses applications requiring CUDA
        out "Do you use applications like DaVinci Resolve or Blender that require CUDA? [Y/N]" center info
        option=$(input)
        if [[ "$option" =~ [Yy] ]]; then
            out "Installing NVIDIA CUDA support..." left info
            sudo dnf install -y --quiet xorg-x11-drv-nvidia-cuda
        fi
    fi

    # Prompt to check if GNOME Software should be installed
    out "Do you use GNOME Software (for managing apps and updates)? [Y/N]" center info
    option=$(input)
    if [[ "$option" =~ [Yy] ]]; then
        out "Installing GNOME Software..." left info
        sudo dnf install -y --quiet gnome-software
    else
        out "Removing GNOME Software from autostart..." left info
        sudo dnf remove -y --quiet gnome-software
        sudo rm -f /etc/xdg/autostart/org.gnome.Software.desktop
    fi
    echo

    # Check if the system has a battery
    if [ -d /sys/class/power_supply/BAT0 ]; then
        out "Battery detected. Do you want to optimize battery usage using TLP? [Y/N]" center info
        out "[Y]es" center success
        out "[N]o" center danger
        out "[H]elp - Show more details" center info
        option=$(input)
        if [[ "$option" =~ [Hh] ]]; then
            show_help "battery"
            out "Battery detected. Do you want to optimize battery usage using TLP? [Y/N]" center info
            out "[Y]es" center success
            out "[N]o" center danger
            option=$(input)
        fi
        if [[ "$option" =~ [Yy] ]]; then
            # Remove conflicting power profiles
            out "Removing conflicting power profiles..." left info
            sudo dnf remove -y --quiet power-profiles-daemon tuned tuned-ppd

            # Install TLP for battery optimization
            out "Installing TLP and enabling battery optimizations..." left info
            sudo dnf install -y --quiet tlp tlp-rdw

            # Enable TLP service
            out "Enabling TLP service..." left info
            sudo systemctl enable tlp.service

            # Mask conflicting services
            out "Masking systemd-rfkill service..." left info
            sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket

            out "Battery optimizations applied using TLP!" left success
        else
            out "Skipping battery optimizations." left warning
        fi
    else
        out "No battery detected. Skipping battery optimizations." left warning
    fi

    out "Updating the system..." center info
    sudo dnf update -y --quiet
    sudo dnf group upgrade core -y --quiet
    sudo dnf5 group upgrade core -y --quiet
    sudo dnf autoremove -y --quiet
    sudo fwupdmgr refresh --force
    sudo fwupdmgr get-devices
    sudo fwupdmgr get-updates
    sudo fwupdmgr update
    out "System optimizations completed!" center success
}

menu
