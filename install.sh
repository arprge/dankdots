#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=false
NO_BACKUP=false
SKIP_DEPS=false
PERSONAL=false
MODE="install"
REQUESTED_PACKAGES=()

# Personal packages: skipped by default so anyone can run `./install.sh` safely.
# Included automatically with `./install.sh --me` (or `--personal`).
PERSONAL_PACKAGES=(git)

# Files containing this placeholder are rendered into $HOME instead of being
# symlinked, so absolute home paths work for whoever installs the dots.
HOME_PLACEHOLDER="@HOME@"

# Colors (disabled if stdout is not a tty)
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' RESET=''
fi

info()    { printf "${BLUE}[info]${RESET} %s\n" "$*"; }
ok()      { printf "${GREEN}[ok]${RESET}   %s\n" "$*"; }
warn()    { printf "${YELLOW}[warn]${RESET} %s\n" "$*"; }
err()     { printf "${RED}[err]${RESET}  %s\n" "$*" >&2; }
section() { printf "\n${BOLD}${CYAN}==> %s${RESET}\n" "$*"; }

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [PACKAGE...]

Install, unlink, or sync dankdots (Fedora + Niri + Dux shell).
Running ./$(basename "$0") with no arguments installs the full Dux shell stack
and links all desktop/shell configs (skipping personal identity configs like git).

Options:
      --me, --personal  Include personal configs (git) and gaming apps (Lutris, ProtonPlus)
  -n, --dry-run         Preview changes without modifying anything
  -l, --list            List available packages and exit
      --no-backup       Replace existing files without backing them up
      --skip-deps       Skip system packages, Oh My Zsh, and app installation
      --unlink          Remove symlinks/rendered files pointing into this repository
      --uninstall       Unlink configs and restore the latest ~/.dotfiles-backup/
      --sync            Copy live files from \$HOME back into this repository
  -h, --help            Show this help message

Examples:
  ./$(basename "$0")                # Full Dux shell setup for anyone on Fedora
  ./$(basename "$0") --me           # Full setup + personal git config & gaming apps
  ./$(basename "$0") --dry-run      # Preview full install
  ./$(basename "$0") zsh kitty niri # Install only zsh, kitty, and niri
  ./$(basename "$0") --unlink nvim  # Remove nvim symlinks
  ./$(basename "$0") --uninstall    # Remove linked configs and restore latest backup
  ./$(basename "$0") --sync         # Pull live changes from \$HOME into repo
EOF
}

discover_packages() {
  local dir
  for dir in "$REPO_DIR"/*/; do
    [[ -d "$dir" ]] || continue
    local name
    name="$(basename "$dir")"
    [[ "$name" == ".git" ]] && continue
    printf '%s\n' "$name"
  done | sort
}

is_personal_package() {
  local pkg="$1"
  local p

  for p in "${PERSONAL_PACKAGES[@]}"; do
    [[ "$pkg" == "$p" ]] && return 0
  done

  return 1
}

is_template_file() {
  grep -qIF -- "$HOME_PLACEHOLDER" "$1" 2>/dev/null
}

# Substitute the placeholder using a literal (not regex) pattern match.
render_template() {
  local src="$1"
  local escaped_home

  escaped_home="$(printf '%s' "$HOME" | sed -e 's/[\\|&]/\\&/g')"
  sed "s|$HOME_PLACEHOLDER|${escaped_home}|g" -- "$src"
}

# Reverse substitution, used by --sync so live files do not bake in $HOME.
unrender_template() {
  local src="$1"
  local escaped_home

  escaped_home="$(printf '%s' "$HOME" | sed -e 's/[\\|&]/\\&/g')"
  sed "s|${escaped_home}|$HOME_PLACEHOLDER|g" -- "$src"
}

list_packages() {
  local pkg

  while IFS= read -r pkg; do
    if is_personal_package "$pkg"; then
      printf '%s (opt-in)\n' "$pkg"
    else
      printf '%s\n' "$pkg"
    fi
  done < <(discover_packages)
}

default_packages() {
  local pkg

  while IFS= read -r pkg; do
    if is_personal_package "$pkg"; then
      continue
    fi
    printf '%s\n' "$pkg"
  done < <(discover_packages)
}

backup_target() {
  local target="$1"
  local rel="${target#"$HOME"/}"
  local backup_path="${BACKUP_ROOT}/${rel}"

  if [[ "$NO_BACKUP" == true ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      info "[dry-run] would remove existing $target"
    else
      rm -rf -- "$target"
    fi
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] would back up $target -> $backup_path"
  else
    mkdir -p -- "$(dirname -- "$backup_path")"
    mv -- "$target" "$backup_path"
    warn "backed up $target -> $backup_path"
  fi
}

link_file() {
  local src="$1"
  local dst="$2"

  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink -f -- "$dst" 2>/dev/null || true)"
    local expected
    expected="$(readlink -f -- "$src")"
    if [[ "$current" == "$expected" ]]; then
      ok "already linked: $dst"
      return
    fi
    # Symlink points elsewhere; replace it
    backup_target "$dst"
  elif [[ -e "$dst" ]]; then
    backup_target "$dst"
  fi

  if [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] would link $dst -> $src"
  else
    mkdir -p -- "$(dirname -- "$dst")"
    ln -s -- "$src" "$dst"
    ok "linked $dst -> $src"
  fi
}

template_file() {
  local src="$1"
  local dst="$2"
  local rendered
  rendered="$(mktemp)"
  render_template "$src" >"$rendered"

  if [[ -f "$dst" && ! -L "$dst" ]] && cmp -s -- "$rendered" "$dst"; then
    rm -f -- "$rendered"
    ok "already rendered: $dst"
    return
  fi

  # An older install may have symlinked the raw template
  if [[ -L "$dst" ]]; then
    local current expected
    current="$(readlink -f -- "$dst" 2>/dev/null || true)"
    expected="$(readlink -f -- "$src")"
    if [[ "$current" == "$expected" ]]; then
      if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] would replace symlink $dst with a rendered copy"
      else
        rm -f -- "$dst"
      fi
    else
      backup_target "$dst"
    fi
  elif [[ -e "$dst" ]]; then
    backup_target "$dst"
  fi

  if [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] would render $dst from $src (${HOME_PLACEHOLDER} -> $HOME)"
    rm -f -- "$rendered"
    return
  fi

  mkdir -p -- "$(dirname -- "$dst")"
  mv -- "$rendered" "$dst"
  chmod --reference="$src" "$dst" 2>/dev/null || true
  ok "rendered $dst from $src"
}

install_file() {
  local src="$1"
  local dst="$2"

  if is_template_file "$src"; then
    template_file "$src" "$dst"
  else
    link_file "$src" "$dst"
  fi
}

unlink_file() {
  local src="$1"
  local dst="$2"

  if is_template_file "$src"; then
    unlink_template "$src" "$dst"
    return
  fi

  if [[ ! -L "$dst" ]]; then
    return
  fi

  local current expected
  current="$(readlink -f -- "$dst" 2>/dev/null || true)"
  expected="$(readlink -f -- "$src")"

  if [[ "$current" == "$expected" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      info "[dry-run] would unlink $dst"
    else
      rm -- "$dst"
      ok "unlinked $dst"
    fi
  fi
}

unlink_template() {
  local src="$1"
  local dst="$2"
  local rendered
  rendered="$(mktemp)"
  render_template "$src" >"$rendered"

  if [[ -L "$dst" || ! -e "$dst" ]]; then
    rm -f -- "$rendered"
    return
  fi

  # Only remove a copy we generated; never delete user edits
  if ! cmp -s -- "$rendered" "$dst"; then
    rm -f -- "$rendered"
    warn "left modified file in place: $dst"
    return
  fi

  rm -f -- "$rendered"
  if [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] would remove rendered $dst"
  else
    rm -- "$dst"
    ok "removed rendered $dst"
  fi
}

sync_file() {
  local repo_file="$1"
  local live_file="$2"

  if [[ ! -e "$live_file" ]]; then
    return
  fi

  if is_template_file "$repo_file"; then
    sync_template "$repo_file" "$live_file"
    return
  fi

  # Skip if live_file is already a symlink to repo_file
  if [[ -L "$live_file" ]]; then
    local current expected
    current="$(readlink -f -- "$live_file" 2>/dev/null || true)"
    expected="$(readlink -f -- "$repo_file")"
    if [[ "$current" == "$expected" ]]; then
      return
    fi
  fi

  if cmp -s -- "$live_file" "$repo_file"; then
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] would sync $live_file -> $repo_file"
  else
    cp -a -- "$live_file" "$repo_file"
    ok "synced $live_file -> $repo_file"
  fi
}

sync_template() {
  local repo_file="$1"
  local live_file="$2"
  local current
  current="$(mktemp)"
  render_template "$repo_file" >"$current"

  if cmp -s -- "$current" "$live_file"; then
    rm -f -- "$current"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    rm -f -- "$current"
    info "[dry-run] would sync $live_file -> $repo_file (back to $HOME_PLACEHOLDER)"
    return
  fi

  rm -f -- "$current"
  local staged
  staged="$(mktemp)"
  unrender_template "$live_file" >"$staged"
  cat -- "$staged" >"$repo_file"
  rm -f -- "$staged"
  ok "synced $live_file -> $repo_file (back to $HOME_PLACEHOLDER)"
}

process_package() {
  local pkg="$1"
  local pkg_dir="${REPO_DIR}/${pkg}"

  if [[ ! -d "$pkg_dir" ]]; then
    err "Unknown package: $pkg"
    return 1
  fi

  section "Package: $pkg"

  while IFS= read -r -d '' src; do
    local rel="${src#"$pkg_dir"/}"
    local dst="${HOME}/${rel}"

    # Skip hardware-specific monitor mode/scale (1080p@60Hz scale 1.4) unless --me is passed
    if [[ "$MODE" == "install" && "$PERSONAL" == false && ( "$rel" == ".config/niri/dms/outputs.kdl" || "$rel" == ".config/dms/monitors.json" ) ]]; then
      info "Skipping machine-specific display profile: $rel (pass --me to include)"
      continue
    fi

    case "$MODE" in
      install)           install_file "$src" "$dst" ;;
      unlink|uninstall)  unlink_file "$src" "$dst" ;;
      sync)              sync_file "$src" "$dst" ;;
    esac
  done < <(find "$pkg_dir" \( -type f -o -type l \) -print0 | sort -z)
}

restore_latest_backup() {
  local backup_parent="${HOME}/.dotfiles-backup"
  [[ -d "$backup_parent" ]] || return 0

  local latest=""
  local dir
  for dir in "$backup_parent"/*/; do
    [[ -d "$dir" ]] && latest="$dir"
  done
  [[ -n "$latest" ]] || return 0
  latest="${latest%/}"

  section "Restoring backup: $latest"
  local restored=0
  local bak_file
  while IFS= read -r -d '' bak_file; do
    local rel="${bak_file#"$latest"/}"
    local dst="${HOME}/${rel}"

    if [[ -e "$dst" || -L "$dst" ]]; then
      continue
    fi

    if [[ "$DRY_RUN" == true ]]; then
      info "[dry-run] would restore $bak_file -> $dst"
    else
      mkdir -p -- "$(dirname -- "$dst")"
      mv -- "$bak_file" "$dst"
      ok "restored $dst"
    fi
    ((restored += 1))
  done < <(find "$latest" \( -type f -o -type l \) -print0 | sort -z)

  if (( restored == 0 )); then
    info "No matching files to restore from $latest"
  elif [[ "$DRY_RUN" == false ]]; then
    find "$latest" -type d -empty -delete 2>/dev/null || true
  fi
}

clone_if_missing() {
  local url="$1"
  local dest="$2"
  local label="$3"

  if [[ -d "$dest" ]]; then
    ok "$label already installed ($dest)"
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    warn "git not found; cannot install $label"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] would clone $url -> $dest"
  else
    info "Installing $label..."
    mkdir -p -- "$(dirname -- "$dest")"
    git clone --depth=1 -- "$url" "$dest"
    ok "Installed $label"
  fi
}

install_dnf_pkg() {
  local pkg="$1"
  local bin="${2:-$1}"

  if command -v "$bin" >/dev/null 2>&1; then
    ok "$pkg already installed ($(command -v "$bin"))"
  elif command -v dnf >/dev/null 2>&1; then
    if [[ "$DRY_RUN" == true ]]; then
      info "[dry-run] would run: sudo dnf install -y $pkg"
    else
      info "Installing $pkg via dnf..."
      sudo dnf install -y "$pkg"
      ok "Installed $pkg"
    fi
  else
    warn "dnf not found; please install $pkg manually"
  fi
}

bootstrap_dux_shell() {
  section "Installing Dux shell (official installer)"
  local installer_url="https://install.duxlabs.dev"

  if command -v dms >/dev/null 2>&1; then
    ok "Dux shell already installed ($(command -v dms))"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] would run official Dux shell installer: $installer_url"
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    if command -v dnf >/dev/null 2>&1; then
      info "Installing curl via dnf..."
      sudo dnf install -y curl
    else
      err "curl not found; install curl or run $installer_url manually first"
      exit 1
    fi
  fi

  info "Launching official Dux shell installer ($installer_url)..."
  local tmp_installer
  tmp_installer="$(mktemp)"
  if ! curl -fsSL "$installer_url" -o "$tmp_installer"; then
    rm -f -- "$tmp_installer"
    err "Failed to download Dux shell installer ($installer_url)"
    exit 1
  fi

  # Run from a file (not a pipe) so the interactive installer keeps full TTY access
  local status=0
  sh "$tmp_installer" || status=$?
  rm -f -- "$tmp_installer"

  if (( status != 0 )); then
    err "Dux shell installer exited with status $status; stopping before linking configs"
    exit "$status"
  fi

  hash -r
  ok "Dux shell installation complete"
}

bootstrap_packages() {
  section "Installing companion & CLI packages"

  local extra_pkgs=(
    dux-files dux-search
    zsh kitty neovim mpv fastfetch cava
    eza bat zoxide btop micro
    qt6ct adw-gtk3-theme papirus-icon-theme adwaita-sans-fonts
    curl unzip fontconfig
  )
  local terra_pkgs=(starship yazi darkly)

  if ! command -v dnf >/dev/null 2>&1; then
    warn "dnf not found; skipping automatic Fedora package installation"
    return
  fi

  local missing_pkgs=()
  local missing_terra=false
  local pkg

  for pkg in "${extra_pkgs[@]}"; do
    if ! rpm -q "$pkg" >/dev/null 2>&1; then
      missing_pkgs+=("$pkg")
    fi
  done

  for pkg in "${terra_pkgs[@]}"; do
    if ! rpm -q "$pkg" >/dev/null 2>&1; then
      missing_pkgs+=("$pkg")
      missing_terra=true
    fi
  done

  if (( ${#missing_pkgs[@]} == 0 )); then
    ok "All companion & CLI packages already installed"
  elif [[ "$DRY_RUN" == true ]]; then
    if [[ "$missing_terra" == true ]] && ! rpm -q terra-release >/dev/null 2>&1; then
      info "[dry-run] would enable Terra repository (for starship, yazi, darkly)"
    fi
    info "[dry-run] would run: sudo dnf install -y --skip-unavailable ${missing_pkgs[*]}"
  else
    if [[ "$missing_terra" == true ]] && ! rpm -q terra-release >/dev/null 2>&1; then
      info "Enabling Terra repository (for starship, yazi, darkly)..."
      sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release || true
    fi
    info "Installing missing packages via dnf: ${missing_pkgs[*]}"
    sudo dnf install -y --skip-unavailable "${missing_pkgs[@]}"
    ok "Installed companion & CLI packages"
  fi

  # Ensure standard directories referenced by niri/dsearch/dfiles exist
  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p -- "$HOME/Projects" "$HOME/Pictures/Screenshots"
  fi
}

bootstrap_dux_services() {
  section "Enabling Dux companion services"

  if ! command -v systemctl >/dev/null 2>&1; then
    return
  fi

  if ! systemctl --user list-unit-files >/dev/null 2>&1; then
    warn "systemd user session not available; enable companion services after login:"
    info "  systemctl --user enable --now dfiles.service dsearch.service"
    return
  fi

  local svc
  for svc in dfiles.service dsearch.service; do
    if ! systemctl --user list-unit-files "$svc" --no-legend 2>/dev/null | grep -q "^${svc}"; then
      continue
    fi

    if systemctl --user is-enabled "$svc" >/dev/null 2>&1; then
      ok "$svc already enabled"
    elif [[ "$DRY_RUN" == true ]]; then
      info "[dry-run] would run: systemctl --user enable $svc"
    else
      if systemctl --user enable "$svc" >/dev/null 2>&1; then
        ok "Enabled $svc"
      else
        warn "Could not enable $svc; run: systemctl --user enable $svc"
      fi
    fi
  done
}

bootstrap_anilist_updater() {
  section "Installing latest mpv-anilist-updater"
  local installer_url="https://raw.githubusercontent.com/AzuredBlue/mpv-anilist-updater/main/installers/unix.sh"

  if [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] would run the upstream installer: $installer_url"
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    warn "curl not found; cannot install mpv-anilist-updater"
    return
  fi

  # The dots link ~/.config/mpv, so always target that directory. Without this,
  # the upstream installer prefers a Flatpak/Snap mpv config when one exists.
  info "Fetching the latest release from GitHub..."
  if MPV_CONFIG_DIR="${HOME}/.config/mpv" /bin/bash -c "$(curl -fsSL "$installer_url")"; then
    ok "Installed latest mpv-anilist-updater"
  else
    warn "mpv-anilist-updater installation failed; mpv works without it"
  fi
}

bootstrap_personal_apps() {
  section "Installing personal gaming apps (Lutris, ProtonPlus)"

  install_dnf_pkg lutris

  if ! command -v flatpak >/dev/null 2>&1; then
    warn "flatpak not found; cannot install ProtonPlus (com.vysp3r.ProtonPlus)"
    return
  fi

  if flatpak info com.vysp3r.ProtonPlus >/dev/null 2>&1; then
    ok "ProtonPlus already installed (com.vysp3r.ProtonPlus)"
  elif [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] would ensure flathub remote and run: flatpak install -y flathub com.vysp3r.ProtonPlus"
  else
    info "Installing ProtonPlus via Flatpak..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub com.vysp3r.ProtonPlus
    ok "Installed ProtonPlus"
  fi
}

bootstrap_fonts() {
  section "Installing Nerd Fonts & refreshing font cache"
  local font_dir="${HOME}/.local/share/fonts"

  if [[ -f "${font_dir}/GoogleSansCodeNerdFont-Regular.ttf" ]] || fc-list : family 2>/dev/null | grep -qi "GoogleSansCode Nerd Font"; then
    ok "GoogleSansCode Nerd Font already installed"
  elif ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
    warn "curl or unzip not found; skipping GoogleSansCode Nerd Font download"
  elif [[ "$DRY_RUN" == true ]]; then
    info "[dry-run] would download GoogleSansCode Nerd Font into $font_dir"
  else
    info "Downloading GoogleSansCode Nerd Font..."
    local tmp_zip
    tmp_zip="$(mktemp --suffix=.zip)"
    mkdir -p -- "$font_dir"
    if curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/GoogleSansCode.zip" -o "$tmp_zip"; then
      unzip -qo "$tmp_zip" "*.ttf" -d "$font_dir"
      ok "Installed GoogleSansCode Nerd Font"
    else
      warn "Failed to download GoogleSansCode Nerd Font"
    fi
    rm -f -- "$tmp_zip"
  fi

  if command -v fc-cache >/dev/null 2>&1; then
    if [[ "$DRY_RUN" == true ]]; then
      info "[dry-run] would run: fc-cache -f $font_dir"
    else
      fc-cache -f "$font_dir" >/dev/null 2>&1 || true
      ok "Refreshed font cache ($font_dir)"
    fi
  fi
}

bootstrap_zsh_deps() {
  section "Bootstrapping Oh My Zsh & Zsh plugins"
  local omz_dir="${ZSH:-$HOME/.oh-my-zsh}"
  local custom_dir="${ZSH_CUSTOM:-$omz_dir/custom}"

  clone_if_missing "https://github.com/ohmyzsh/ohmyzsh.git" "$omz_dir" "Oh My Zsh"
  clone_if_missing "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$custom_dir/plugins/zsh-autosuggestions" "zsh-autosuggestions"
  clone_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$custom_dir/plugins/zsh-syntax-highlighting" "zsh-syntax-highlighting"
}

check_tools() {
  section "Checking recommended tools"
  local tools=(
    zsh starship kitty nvim mpv dms niri dfiles dsearch
    yazi fastfetch cava matugen eza bat zoxide btop micro
  )
  local missing=()
  local t
  for t in "${tools[@]}"; do
    if command -v "$t" >/dev/null 2>&1; then
      ok "$t ($(command -v "$t"))"
    else
      warn "$t (not found in PATH)"
      missing+=("$t")
    fi
  done

  if (( ${#missing[@]} > 0 )); then
    printf "\n"
    info "Missing tools: ${missing[*]}"
    info "Install them with your package manager (e.g., sudo dnf install ...)."
  fi
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--dry-run)   DRY_RUN=true ;;
      -l|--list)      list_packages; exit 0 ;;
      --me|--personal) PERSONAL=true ;;
      --no-backup)    NO_BACKUP=true ;;
      --skip-deps)    SKIP_DEPS=true ;;
      --unlink)       MODE="unlink" ;;
      --uninstall)    MODE="uninstall" ;;
      --sync)         MODE="sync" ;;
      -h|--help)      usage; exit 0 ;;
      -*)
        err "Unknown option: $1"
        usage
        exit 1
        ;;
      *)
        REQUESTED_PACKAGES+=("$1")
        ;;
    esac
    shift
  done

  local packages=()
  if (( ${#REQUESTED_PACKAGES[@]} > 0 )); then
    packages=("${REQUESTED_PACKAGES[@]}")
  elif [[ "$MODE" == "install" && "$PERSONAL" == false ]]; then
    # Personal packages stay out of the default install unless --me/--personal is passed;
    # sync/unlink still cover them so their live files can round-trip through the repo.
    mapfile -t packages < <(default_packages)

    local skipped=()
    local pkg
    for pkg in "${PERSONAL_PACKAGES[@]}"; do
      [[ -d "${REPO_DIR}/${pkg}" ]] && skipped+=("$pkg")
    done
    if (( ${#skipped[@]} > 0 )); then
      info "Skipping personal package(s): ${skipped[*]} (pass --me to include)"
    fi
  else
    mapfile -t packages < <(discover_packages)
  fi

  if (( ${#packages[@]} == 0 )); then
    err "No packages found in $REPO_DIR"
    exit 1
  fi

  info "Repository: $REPO_DIR"
  info "Mode:       $MODE (dry-run=$DRY_RUN, personal=$PERSONAL)"

  local is_full_install=false
  (( ${#REQUESTED_PACKAGES[@]} == 0 )) && is_full_install=true

  local has_dux=false
  local has_desktop=false
  local has_zsh=false
  local has_mpv=false
  local has_fonts=false
  local pkg
  for pkg in "${packages[@]}"; do
    case "$pkg" in
      dms|niri) has_dux=true ;;
      desktop)  has_desktop=true ;;
      zsh)      has_zsh=true ;;
      mpv)      has_mpv=true ;;
      fonts)    has_fonts=true ;;
    esac
  done

  # 1. Native Dux shell installer & system packages (before linking configs so
  #    upstream defaults are backed up and replaced cleanly by our dotfiles).
  if [[ "$MODE" == "install" && "$SKIP_DEPS" == false ]]; then
    if [[ "$is_full_install" == true || "$has_dux" == true ]]; then
      bootstrap_dux_shell
    fi
    if [[ "$is_full_install" == true || "$has_dux" == true || "$has_desktop" == true ]]; then
      bootstrap_packages
    fi
  fi

  # 2. Link/render dotfiles (or unlink/uninstall/sync).
  for pkg in "${packages[@]}"; do
    process_package "$pkg"
  done

  # 3. Post-link setup: tools that write into linked config dirs, fonts, services.
  if [[ "$MODE" == "install" && "$SKIP_DEPS" == false ]]; then
    if [[ "$has_zsh" == true ]]; then
      bootstrap_zsh_deps
    fi
    if [[ "$has_mpv" == true ]]; then
      bootstrap_anilist_updater
    fi
    if [[ "$has_fonts" == true ]]; then
      bootstrap_fonts
    fi
    if [[ "$PERSONAL" == true ]]; then
      bootstrap_personal_apps
    fi
    if [[ "$has_desktop" == true ]]; then
      bootstrap_dux_services
    fi
    if [[ "$is_full_install" == true ]]; then
      check_tools
    fi
  elif [[ "$MODE" == "uninstall" ]]; then
    restore_latest_backup
    if command -v fc-cache >/dev/null 2>&1 && [[ "$DRY_RUN" == false ]]; then
      fc-cache -f "${HOME}/.local/share/fonts" >/dev/null 2>&1 || true
    fi
  fi

  printf "\n"
  ok "Done!"
}

main "$@"
