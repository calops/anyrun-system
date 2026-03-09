# anyrun-system

A system actions plugin for the [anyrun](https://github.com/anyrun-org/anyrun) runner.

## Features

Provides the following system actions:
- Lock Screen
- Log out
- Suspend
- Hibernate
- Reboot
- Shut down

## Usage

### Nix

Add this flake to your `anyrun` configuration:

```nix
{
  inputs.anyrun-system.url = "github:calops/anyrun-system";

  # ...
  # In your anyrun configuration
  plugins = [
    # ...
    inputs.anyrun-system.packages.${system}.default
  ];
}
```

### Manual

Build the project with `nix build` and copy `result/lib/libanyrun-system.so` to your anyrun plugins directory (usually `~/.config/anyrun/plugins/`).

## Development

Use `nix develop` to enter a development shell with all necessary tools.
Build with `nix build`.
