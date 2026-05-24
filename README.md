# dotfiles

> [!IMPORTANT]
> **Radicle is the canonical repository for this project.**
> The GitHub repository is a read-only mirror. All development and issues are managed on Radicle.
>
> - Main: rad:z41sVuFXSYtdG2YpBG5jMPpEdiTGC

## Installation
### macOS, Linux

```sh 
curl -sL https://raw.githubusercontent.com/clesteria/dotfiles/main/init.sh | bash
```

### Windows

```sh
.\setup.ps1
```

## Tasks

### build

```sh
nim portsInstall # Install MacPorts (macOS)
nim brewInstall # Install Homebrew (macOS)
```

### install

```sh
nim symlink # Deploy config files (macOS,Linux)
nim defaults # Apply macOS settings (macOS)
nim ports # Install CLI Tools (macOS)
nim brew # Install GUI Tools (macOS)
```
