# Black-box Flakes

The black box devShell flake

## Usage

Short version:

```shell
nix flake init -t github:cubewhy/blackbox-flakes
```

And you will notice the options in flake.nix

Just simply edit them and have fun.

If something is undocumented in the template, please open an issue/pr to let me know.

## Documentation

Please see the comments in the [default template](./templates/default/flake.nix)

## Supported languages/libraries/tools

| Type     | Name                  | Notes                                      |
| -------- | --------------------- | ------------------------------------------ |
| Language | Rust                  | need rust-overlay                          |
| Language | C/C++                 |                                            |
| Language | Assembly              | with nasm assembler                        |
| Language | Golang                | need go-overlay                            |
| Language | Java                  |                                            |
| Language | Javascript/Typescript |                                            |
| Language | Python                |                                            |
| Library  | openssl               |                                            |
| Library  | cuda                  | need systemwide nvidia driver installation |
| Library  | graphics              | include X11, wayland, opengl, vulkan       |
| Tool     | pre-commit            |                                            |

## Why this exist

I find devenv heavy, sometimes even slower than pure Flakes.

Furthermore,
I hate having to open my browser every time I need to find devenv options in devenv.sh.

I don't think everyone likes using Nix,
and on some platforms (like Windows),
Nix doesn't even exist, but devenv prefers to use the "Nix way" (like git hooks).

This is terrible... which is why I created blackbox-flakes.

It follows the KISS principle;
it should only be used to manage dependencies,
leaving everything else to dedicated tools (like docker/podman, pre-commit).

## Contribute

PRs are welcome

AI generated content can be accepted,
but please run a quick smoke test on your machine before you open the PR.

## Add new module (language/library/tool)

- Create `.nix` file in the correct category
- Import it in `modules/default.nix`
- Add examples in `templates/default/flake.nix`
