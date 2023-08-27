# Yasb Komorebi Active Window Indicator

A [Yasb](https://github.com/denBot/yasb) widget to display a [Komorebi](https://github.com/LGUG2Z/komorebi) active window indicator.

## Why

- If you don't use active window borders, you can't tell if you're in a stack or monocle
- Yasb's built-in active layout widget doesn't display stacks

## Prerequisites

- [Yasb](https://github.com/denBot/yasb)
  - Knowledge on how to configure it.
- [Komorebi](https://github.com/LGUG2Z/komorebi)
- [Neovim](https://neovim.io/doc/user/luvref.html). Why?
  - Because I wanted to try Neovim as a script runner
  - Because I wanted to try [luv](https://neovim.io/doc/user/luvref.html)
  - Because why not

## Installation and Usage

Run the following commands in PowerShell.

Clone this repo as `komorebi_indicator` into your Yasb install location (`~/.yasb` by default):

```PowerShell
cd .yasb
git clone https://github.com/ChuseCubr/yasb-komorebi-indicator komorebi_indicator
```

Include the following command into your startup script (assuming you already have a startup script for Komorebi/Yasb):

```PowerShell
nvim.exe --clean --headless -l $HOME/.yasb/komorebi_indicator/lua/server.lua
```

Include one of the following in your Yasb configuration.

### Individual Icons

- Display only the status of the active window.
- By default, clicking the icon will toggle off the current status (or cycle stacks).

```yaml
# ~/.yasb/config.yaml

bars:
  yasb-bar:
    widgets:
      right: ["komorebi_active_window_status"]

widgets:
  komorebi_active_window_status:
    type: yasb.custom.CustomWidget
    options:
      label: "{data[label]}"
      label_alt: "{data[label_alt]}"
      class_name: "komorebi-active-window-status"
      exec_options:
        run_cmd: "nvim.exe --clean --headless -l %userprofile%/.yasb/komorebi_indicator/lua/client.lua --command=status"
        run_interval: 1000
        return_format: "json"
      callbacks:
        on_left: "exec cmd /c {data[on_left]}"
        on_middle: "exec cmd /c {data[on_middle]}"
        on_right: "exec cmd /c {data[on_right]}"
```

### Grouped Widget

- Show all possible statuses and highlight the active one.
- By default, clicking the icon will toggle off the current status (or cycle stacks).

```yaml
# ~/.yasb/config.yaml

bars:
  yasb-bar:
    widgets:
      right: ["komorebi_active_window_statuses"]

widget:
  komorebi_active_window_status:
    type: yasb.custom.CustomWidget
    options:
      label: "{data[label]}"
      label_alt: "{data[label_alt]}"
      class_name: "komorebi-active-window-status"
      exec_options:
        run_cmd: "nvim.exe --clean --headless -l %userprofile%/.yasb/komorebi_indicator/lua/client.lua --command=statuses"
        run_interval: 1000
        return_format: "json"
      callbacks:
        on_left: "exec cmd /c {data[on_left]}"
        on_middle: "exec cmd /c {data[on_middle]}"
        on_right: "exec cmd /c {data[on_right]}"
```

### Individual Widgets

- Have a widget for each status.
- Clicking any icon will toggle that icon's status.

```yaml
# ~/.yasb/config.yaml

bars:
  yasb-bar:
    widgets:
      right: ["komorebi_floating", "komorebi_stacked", "komorebi_monocle", "komorebi_maximized"]

widgets:
  komorebi_monocle:
    type: yasb.custom.CustomWidget
    options:
      label: "{data[label]}"
      label_alt: "{data[label_alt]}"
      class_name: "komorebi-active-window-status"
      exec_options:
        run_cmd: "nvim.exe --clean --headless -l %USERPROFILE%/.yasb/komorebi_indicator/lua/client.lua --command=monocle"
        run_interval: 1000
        return_format: "json"
      callbacks:
        on_left: "exec cmd /c {data[on_left]}"
        on_middle: "exec cmd /c {data[on_middle]}"
        on_right: "exec cmd /c {data[on_right]}"

  komorebi_maximized:
    type: yasb.custom.CustomWidget
    options:
      label: "{data[label]}"
      label_alt: "{data[label_alt]}"
      class_name: "komorebi-active-window-status"
      exec_options:
        run_cmd: "nvim.exe --clean --headless -l %USERPROFILE%/.yasb/komorebi_indicator/lua/client.lua --command=maximized"
        run_interval: 1000
        return_format: "json"
      callbacks:
        on_left: "exec cmd /c {data[on_left]}"
        on_middle: "exec cmd /c {data[on_middle]}"
        on_right: "exec cmd /c {data[on_right]}"

  komorebi_floating:
    type: yasb.custom.CustomWidget
    options:
      label: "{data[label]}"
      label_alt: "{data[label_alt]}"
      class_name: "komorebi-active-window-status"
      exec_options:
        run_cmd: "nvim.exe --clean --headless -l %USERPROFILE%/.yasb/komorebi_indicator/lua/client.lua --command=floating"
        run_interval: 1000
        return_format: "json"
      callbacks:
        on_left: "exec cmd /c {data[on_left]}"
        on_middle: "exec cmd /c {data[on_middle]}"
        on_right: "exec cmd /c {data[on_right]}"

  komorebi_stacked:
    type: yasb.custom.CustomWidget
    options:
      label: "{data[label]}"
      label_alt: "{data[label_alt]}"
      class_name: "komorebi-active-window-status"
      exec_options:
        run_cmd: "nvim.exe --clean --headless -l %USERPROFILE%/.yasb/komorebi_indicator/lua/client.lua --command=stacked"
        run_interval: 1000
        return_format: "json"
      callbacks:
        on_left: "exec cmd /c {data[on_left]}"
        on_middle: "exec cmd /c {data[on_middle]}"
        on_right: "exec cmd /c {data[on_right]}"
```

## Configuration

Change the variables in `lua/settings.lua`.
