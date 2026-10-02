# source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# ---------------------------------------------------------------------------
# Environment variables (ported from zsh ~/.zshenv)
# ---------------------------------------------------------------------------
set -gx EDITOR micro
set -gx KERAS_HOME "$XDG_STATE_HOME/keras"
set -gx _JAVA_OPTIONS "-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"
set -gx NUGET_PACKAGES "$XDG_CACHE_HOME/NuGetPackages"
set -gx ICEAUTHORITY "$XDG_CACHE_HOME/ICEauthority"
set -gx LESSHISTFILE "$XDG_CACHE_HOME/less/history"
set -gx KDEHOME "$XDG_CONFIG_HOME/kde"
set -gx GTK2_RC_FILES "$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
set -gx GOPATH "$XDG_DATA_HOME/go"
set -gx GNUPGHOME "$XDG_DATA_HOME/gnupg"
set -gx CCACHE_DIR "$XDG_CACHE_HOME/ccache"
set -gx ANDROID_HOME "$XDG_DATA_HOME/android"

# PATH additions (from zsh ~/.zshrc)
fish_add_path /home/vic/bin
fish_add_path "$HOME/.local/bin"

set -g fish_transient_prompt 1

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias cls 'clear'
alias .. 'cd ..'
alias cd.. 'cd ..'
alias home 'cd ~'
alias cat 'bat'
alias df 'df -ahiT --total'
alias mkdir 'mkdir -pv'
alias mkfile 'touch'
alias rm 'rm -rfi'
alias userlist 'cut -d: -f1 /etc/passwd'
alias free 'free -mt'
alias dus 'du -ach | sort -h'
alias ps 'ps auxf'
alias wget 'wget -c --hsts-file=$XDG_DATA_HOME/wget-hsts'
alias histg 'history | grep'
alias folders 'find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias grep 'grep --color=auto'
alias chownme 'sudo chown -R vic:vic'
alias gamescope1080 'gamescope -h 1080 -H 1080 -- '
alias setcapwine 'sudo setcap cap_net_raw+epi (which wine); sudo setcap cap_net_raw+epi (which wineserver)'
alias editzshrc 'kate ~/.config/zsh/.zshrc'
alias configuretide "tide configure --auto --style=Classic --prompt_colors='True color' --classic_prompt_color=Light --show_time='24-hour format' --classic_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Dotted --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Dark --prompt_spacing=Sparse --icons='Many icons'"

# ---------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------

# Listing (eza)
function ls --wraps eza --description "List contents of directory"
    eza $argv
end

function ll --wraps eza --description "List contents of directory using long format"
    eza -lh $argv
end

function la --wraps eza --description "List contents of directory, including hidden files in directory using long format"
    eza -lAh $argv
end

function tree --wraps eza --description "List contents of directories in a tree-like format"
    eza --tree $argv
end

function lsl --wraps ls --description "List contents of directory in long format, piped to less"
    eza --color=always -lhFA | less -FRi
end

# File operations (rsync)
function cpr --wraps rsync --description "rsync with better defaults, mimics cp"
    rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 $argv
end

function mvr --wraps rsync --description "rsync with better defaults, mimics mv"
    rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files $argv
end

# Archives
function extract --description "Extract an archive based on its extension"
    if test -z "$argv[1]"
        echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    else if test -f "$argv[1]"
        switch "$argv[1]"
            case '*.tar.bz2'; tar xvjf $argv[1]
            case '*.tar.gz'; tar xvzf $argv[1]
            case '*.tar.xz'; tar xvJf $argv[1]
            case '*.lzma'; unlzma $argv[1]
            case '*.bz2'; bunzip2 $argv[1]
            case '*.rar'; unrar x -ad $argv[1]
            case '*.gz'; gunzip $argv[1]
            case '*.tar'; tar xvf $argv[1]
            case '*.tbz2'; tar xvjf $argv[1]
            case '*.tgz'; tar xvzf $argv[1]
            case '*.zip'; unzip $argv[1]
            case '*.Z'; uncompress $argv[1]
            case '*.7z'; 7z x $argv[1]
            case '*.xz'; unxz $argv[1]
            case '*.exe'; cabextract $argv[1]
            case '*'; echo "extract: '$argv[1]' - unknown archive method"
        end
    else
        echo "$argv[1] - file does not exist"
    end
end

function maketar --wraps tar --description "Create a .tar.gz archive from a directory"
    set -l dir (string trim -r -c / -- "$argv[1]")
    tar cvzf "$dir.tar.gz" "$dir/"
end

function makezip --wraps zip --description "Create a .zip archive"
    zip -r "$argv[1]".zip "$argv[1]"
end

function bin2iso --wraps bchunk --description "Convert a bin/cue pair to iso"
    set -l name (basename $argv[1] .cue)
    bchunk "$name.bin" "$name.cue" "$name"
end

# Processes
function psgrep --description "List processes matching a pattern (case-insensitive)"
    if test (count $argv) -eq 0
        echo "usage: psgrep <pattern>" >&2
        return 1
    end
    ps aux | grep -v grep | grep -i -e VSZ -e "$argv[1]"
end

function my_ps --wraps ps --description "List processes for current user"
    ps $argv -u $USER -o pid,%cpu,%mem,bsdtime,command
end

# Media (ffmpeg)
function ffmpegclip --wraps ffmpeg --description "Cut a clip (stream copy)"
    ffmpeg -i $argv[1] -ss $argv[2] -to $argv[3] -c:v copy -c:a copy output.mp4
end

function ffmpegclipsubtitles --wraps ffmpeg --description "Cut a clip with burned-in subtitles"
    ffmpeg -i $argv[1] -ss $argv[2] -to $argv[3] -c:v copy -copyts -c:a copy -vf subtitles=$argv[1] output.mp4
end

function ffmpegtranspile --wraps ffmpeg --description "Transcode to webm"
    set -l codec "$argv[2]"
    set -l encoder hevc_vaapi
    set -l quality -q 30
    set -l vaapi_args -vaapi_device /dev/dri/renderD128 -vf format=nv12,hwupload
    switch "$codec"
        case hevc
            set encoder hevc_vaapi
        case vp9
            set encoder libvpx-vp9
            set quality -crf 30
            set vaapi_args
        case av1
            set encoder av1_vaapi
        case h264
            set encoder h264_vaapi
    end
    ffmpeg $vaapi_args -i "$argv[1]" -c:v "$encoder" $quality output.webm
end

# hydownloader

function starthydown
    hydownloader-daemon start --path /mnt/Yukari/import/hydownloader
end

function importhydown --description "Run hydownloader import job (optionally into a subdir)"
    cd ~/bin/hydownloader
    if test -z "$argv[1]"
        poetry run hydownloader-importer run-job --path /mnt/Yukari/import/hydownloader --config hydownloader-import-jobs.py --job default --verbose
    else
        poetry run hydownloader-importer run-job --path /mnt/Yukari/import/hydownloader --config hydownloader-import-jobs.py --job default --subdir "$argv[1]" --verbose
    end
    cd -
end

function cleanhydown --description "Delete already-imported hydownloader files"
    cd ~/bin/hydownloader
    poetry run hydownloader-importer clear-imported --path /mnt/Yukari/import/hydownloader --action delete
    cd -
end

# Utilities
function myip --wraps curl --description "Print public IP address"
    curl ifconfig.co
end

function b64link --wraps xdg-open --description "Open a base64-encoded URL"
    xdg-open (echo $argv[1] | base64 -d -)
end

function mcd --description "Create a directory and cd into it"
    mkdir -p $argv[1]
    cd $argv[1]
end

function jplocale --description "Switch locale to Japanese"
    set -gx LANG ja_JP.UTF-8
    set -gx LC_ALL ja_JP.UTF-8
end
