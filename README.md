# tmux-matryoshka

Plugin for nested tmux workflows.

## Use case

### Problem

You use tmux for workflows on both your local and non-local machines and you would like to use the local tmux to connect to remote machines. Unfortunately, your local tmux captures all tmux keybinds, making you unable to communicate with the remote tmux instance.

### Solution

Use tmux-matryoshka to temporarily disable the outer, local tmux and forget about it. All tmux keybinds are now forwarded to the remote, nested tmux instance. You can repeat this process if you need to communicate with other furtherly nested tmux instance, be it local or remote.[^1]

When needed, you can easily re-enable the disabled tmux instances in the reverse order they were disabled.

## Installation

### Installation with Tmux Plugin Manager

Add this repository as a [TPM](https://github.com/tmux-plugins/tpm) plugin in your `.tmux.conf` file:

```conf
set -g @plugin 'niqodea/tmux-matryoshka'
```

Press `prefix + I` in Tmux environment to install it.

### Manual Installation

Clone this repository:

```bash
git clone https://github.com/niqodea/tmux-matryoshka.git ~/.tmux/plugins/tmux-matryoshka
```

Add this line to your `.tmux.conf` file:

```conf
run-shell ~/.tmux/plugins/tmux-matryoshka/matryoshka.tmux
```

Reload tmux configuration file with:

```sh
tmux source-file ~/.tmux.conf
```

## Usage

In order to work, the keybinds for this plugin are set without tmux prefix. With the default keybinds:[^2]

- press `F1` to disable the outer-most active tmux instance
- press `F2` to enable the inner-most inactive tmux instance
- press `F3` to recursively enable all tmux instances[^3]

## Configuration

The following configuration options are available:

```conf
# keybind to disable outer-most active tmux
set -g @matryoshka_down_keybind 'M-d'
# keybind to enable inner-most inactive tmux
set -g @matryoshka_up_keybind 'M-u'
# keybind to recursively enable all tmux instances
set -g @matryoshka_up_recursive_keybind 'M-U'
# status style of inactive tmux
set -g @matryoshka_inactive_status_style 'fg=colour245,bg=colour238'

# name of the option for the style of the status line
# set if you rely on something other than the default 'status-style' option for it
set -g @matryoshka_status_style_option 'my-status-style'

# you can also choose to replace certain substrings in your style,
# rather than overriding the entire option
set -g @matryoshka_inactive_status_style_update_mode 'replace'

# here you'll provide replacements you'd like to use.
# the format is: before1,after1;before2,after2...
set -g @matryoshka_inactive_status_style_replacements '#a6a6a6,#a9a9a9;active,inactive'
```

Include them in your `.tmux.conf` before running the setup.

## Implementation

This plugin manages nested tmux sessions using a counter environment variable for each tmux instance in the nested hierarchy. When a tmux layer is disabled, the counter increments, keeping track of how deep you are in the nested sessions. Re-enabling tmux instances decrements this counter, ensuring they are reactivated in reverse order, which feels intuitive and natural.

## Comparisons with Alternatives

tmux-matryoshka is not the first plugin to streamline nested tmux workflows.
Here is how it differentiates itself from other known plugins of its kind.

* [tmux-suspend](https://github.com/MunifTanjim/tmux-suspend): tmux-matryoshka supports arbitrary levels of nesting, not just one
* [nested-tmux](https://github.com/aleclearmind/nested-tmux): tmux-matryoshka works seamlessly for nested tmux sessions also over ssh, not just locally

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.

## Acknowledgements

This plugin was inspired by samohskin's popular [`toggle_keybindings.tmux.conf`](https://gist.github.com/samoshkin/05e65f7f1c9b55d3fc7690b59d678734) Github gist.


[^1]: You could need this if, for example, you need to access a tmux server running inside a docker container on a remote machine
[^2]: Customizing your keybinds is suggested
[^3]: You can also use this to fix broken states, e.g. an inactive tmux instance nested inside an active tmux instance
