# tmux-nested

Plugin for nested tmux workflows. A [tmux-suspend](https://github.com/MunifTanjim/tmux-suspend) alternative that supports arbitrary levels of nesting.

## Use case

### Problem

You use tmux for workflows on both your local and non-local machines and you would like to use the local tmux to connect to remote machines. Unfortunately, your local tmux captures all tmux keybinds, making you unable to communicate with the remote tmux instance.

### Solution

Use tmux-nested to temporarily disable the outer, local tmux and forget about it. All tmux keybinds are now forwarded to the remote, nested tmux instance. You can repeat this process if you need to communicate with other furtherly nested tmux instance, be it local or remote.[^1]

When needed, you can easily re-enable the disabled tmux instances in the reverse order they were disabled.

## Installation

### Installation with Tmux Plugin Manager

Add this repository as a [TPM](https://github.com/tmux-plugins/tpm) plugin in your `.tmux.conf` file:

```conf
set -g @plugin 'niqodea/tmux-nested'
```

Press `prefix + I` in Tmux environment to install it.

### Manual Installation

Clone this repository:

```bash
git clone https://github.com/niqodea/tmux-nested.git ~/.tmux/plugins/tmux-nested
```

Add this line to your `.tmux.conf` file:

```conf
run-shell ~/.tmux/plugins/tmux-nested/nested.tmux
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
set -g @nested_down_keybind 'M-d'
# keybind to enable inner-most inactive tmux
set -g @nested_up_keybind 'M-u'
# keybind to recursively enable all tmux instances
set -g @nested_up_recursive_keybind 'M-U'
# status style of inactive tmux
set -g @nested_inactive_status_style 'fg=colour245,bg=colour238'
# The target style or config option to change. Deafult is 'status-style'
set -g @nested_inactive_status_style_target 'status-style'
```

Include them in your `.tmux.conf` before running the setup.

## Implementation

This plugin manages nested tmux sessions using a counter environment variable for each tmux instance in the nested hierarchy. When a tmux layer is disabled, the counter increments, keeping track of how deep you are in the nested sessions. Re-enabling tmux instances decrements this counter, ensuring they are reactivated in reverse order, which feels intuitive and natural.

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.

## Acknowledgements

This plugin was inspired by samohskin's popular [`toggle_keybindings.tmux.conf`](https://gist.github.com/samoshkin/05e65f7f1c9b55d3fc7690b59d678734) Github gist.


[^1]: You could need this if, for example, you need to access a tmux server running inside a docker container on a remote machine
[^2]: Customizing your keybinds is suggested
[^3]: You can also use this to fix broken states, e.g. an inactive tmux instance nested inside an active tmux instance
