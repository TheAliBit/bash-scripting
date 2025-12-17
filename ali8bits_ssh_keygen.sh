#!/bin/bash

# === Ali8Bits SSH Key Generator ===

# Default values (easy to update)
DEFAULT_SSH_PORT=22
DEFAULT_PARENT_DIR="my_ssh"
DEFAULT_KEY_NAME="id_ed25519"
DEFAULT_KEY_IDENTIFIER="user@example.com"

# === Functions ===

welcome() {
    echo 
    echo "🚀 Welcome to Ali8Bits SSH Key Generator"
    echo "🔐 Let's make SSH keys painless!"
    echo
}

get_inputs() {
    read -p "Parent directory name (default: $DEFAULT_PARENT_DIR): " PARENT_DIRECTORY_NAME
    PARENT_DIRECTORY_NAME=${PARENT_DIRECTORY_NAME:-$DEFAULT_PARENT_DIR}

    read -p "Server name / SSH alias (e.g. server_alias): " SERVER_NAME
    read -p "Server IP or domain: " SERVER_IP
    read -p "SSH port (default $DEFAULT_SSH_PORT): " SERVER_SSH_PORT
    SERVER_SSH_PORT=${SERVER_SSH_PORT:-$DEFAULT_SSH_PORT}

    read -p "Server username: " SERVER_USERNAME
    read -p "Key identifier (email or label, default: $DEFAULT_KEY_IDENTIFIER): " KEY_IDENTIFIER
    KEY_IDENTIFIER=${KEY_IDENTIFIER:-$DEFAULT_KEY_IDENTIFIER}

    read -p "Key file name (default: $DEFAULT_KEY_NAME): " KEY_NAME
    KEY_NAME=${KEY_NAME:-$DEFAULT_KEY_NAME}

    # Avoid double slashes if parent dir is empty
    SSH_BASE="$HOME/.ssh${PARENT_DIRECTORY_NAME:+/$PARENT_DIRECTORY_NAME}/$SERVER_NAME"
    KEY_PATH="$SSH_BASE/$KEY_NAME"
    PUB_KEY_PATH="$KEY_PATH.pub"
    SSH_CONFIG="$HOME/.ssh/config"
}

create_directory() {
    echo "📁 Creating SSH directory..."
    mkdir -p "$SSH_BASE"
}

generate_key() {
    echo "🔑 Generating SSH key..."
    ssh-keygen -t ed25519 -C "$KEY_IDENTIFIER" -f "$KEY_PATH"
    chmod 700 "$HOME/.ssh"
    chmod 700 "$SSH_BASE"
    chmod 600 "$KEY_PATH"
}

update_config() {
    echo "🧠 Updating SSH config..."
    if grep -q "Host $SERVER_NAME" "$SSH_CONFIG" 2>/dev/null; then
        echo "⚠ Host $SERVER_NAME already exists in $SSH_CONFIG, skipping..."
    else
        cat >> "$SSH_CONFIG" <<EOF

Host $SERVER_NAME
    HostName $SERVER_IP
    User $SERVER_USERNAME
    Port $SERVER_SSH_PORT
    IdentityFile $KEY_PATH
EOF
        chmod 600 "$SSH_CONFIG"
    fi
}

show_summary() {
    echo
    echo "✅ All done! Your SSH key is ready"
    echo "📍 Key path: $KEY_PATH"
    echo "🏷️  SSH alias: $SERVER_NAME"
    echo
    echo "👉 Connect with:"
    echo "ssh $SERVER_NAME"
    echo
    echo "📝 Public key (copy and paste to server's authorized_keys):"
    echo "-----------------------------------------"
    cat "$PUB_KEY_PATH"
    echo "-----------------------------------------"
    echo
    echo "😎 Script made by Ali8Bits"
    echo "🌐 GitHub: https://github.com/TheAliBit"
    echo
    echo "✨ Happy hacking!"
    echo 
}

# === Main ===
welcome
get_inputs
create_directory
generate_key
update_config
show_summary

