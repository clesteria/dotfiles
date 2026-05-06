# dotfiles

## Installation

### macOS, Linux

```sh 
bash <(curl -LSs https://raw.githubusercontent.com/clesteria/dotfiles/main/bootstrap.sh)
```

### Windows

```sh
.\setup.ps1
```

## Tasks

```sh
nim portsInstall # Install MacPorts (macOS)
nim brewInstall # Install Homebrew (macOS)
```

```sh
nim symlink # Deploy config files (macOS,Linux)
nim defaults # Apply macOS settings (macOS)
nim ports # Install CLI Tools (macOS)
nim brew # Install GUI Tools (macOS)
```
