# cpierce dotfiles

Opinionated macOS-focused dotfiles and setup scripts. This repo is meant to be run in pieces, not as a single monolith.

## Quick Start

Clone the repo and run scripts directly from the repo root.

```sh
git clone git@github.com:cpierce/dotfiles.git
cd dotfiles
```

Run individual scripts as needed:

```sh
./scripts/zsh_init.sh
./scripts/brew_init.sh
./scripts/mac_init.sh
./scripts/fonts_init.sh
./scripts/post_install.sh
```

There is also a convenience runner:

```sh
./scripts/init.sh
```

## What It Contains

- `./.config/nvim`: Neovim setup
- `./.zshrc`, `./.zfunctions`: Zsh config
- `./.gitconfig`, `./.gitignore_global`: Git defaults
- `./scripts/*`: bootstrap helpers
- `./sudoers.d/*`: local sudoers entries

## Script Notes

- `scripts/brew_init.sh` installs Homebrew and packages.
- `scripts/mac_init.sh` applies macOS defaults.
- `scripts/fzf_init.sh` installs fzf key bindings.
- `scripts/post_install.sh` runs pnpm setup, mkcert, and misc tools.

## License

Public domain under [CC0 1.0 Universal License](https://github.com/cpierce/dotfiles/blob/main/LICENSE/).
