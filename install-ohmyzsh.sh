#!/usr/bin/env bash
set -e

# Colors for output
GREEN="\033[0;32m"
NC="\033[0m"

echo -e "${GREEN}--- Installing Zsh and dependencies ---${NC}"
sudo apt update
sudo apt install -y zsh curl git fonts-powerline

# Change default shell to zsh (for current user)
if [ "$SHELL" != "$(which zsh)" ]; then
  echo -e "${GREEN}--- Setting Zsh as default shell ---${NC}"
  chsh -s "$(which zsh)"
fi

echo -e "${GREEN}--- Installing Oh My Zsh ---${NC}"
export RUNZSH=no
export KEEP_ZSHRC=yes
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo -e "${GREEN}--- Installing Spaceship Prompt Theme ---${NC}"
if [ ! -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]; then
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
  ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
fi

# Move your custom files to $HOME
echo -e "${GREEN}--- Copying your custom .zshrc and aliases.zsh ---${NC}"
cp ./aliases.zsh "$HOME/aliases.zsh"
cp ./.zshrc "$HOME/.zshrc"

# Ensure aliases.zsh is sourced in .zshrc (if not already)
if ! grep -q "source ~/aliases.zsh" "$HOME/.zshrc"; then
  echo "source ~/aliases.zsh" >> "$HOME/.zshrc"
fi

echo -e "${GREEN}--- Installing common Oh My Zsh plugins ---${NC}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# zsh-completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
  git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

# Update plugins line (keep existing + add if missing)
if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
  sed -i 's/plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting zsh-completions /' "$HOME/.zshrc"
fi

# Set theme to Spaceship in .zshrc
if grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="spaceship"/' "$HOME/.zshrc"
else
  echo 'ZSH_THEME="spaceship"' >> "$HOME/.zshrc"
fi

echo -e "${GREEN}--- Applying changes ---${NC}"
source "$HOME/.zshrc" || true

echo -e "${GREEN}Oh My Zsh with Spaceship Prompt is ready!${NC}"
echo "Restart your terminal or run: exec zsh"

