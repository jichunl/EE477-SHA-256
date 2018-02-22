# Hotkeys
gui_set_hotkey -replace -hot_key "Ctrl+A" -tcl_cmd {gui_set_layout_layer_visibility -only [get_layers -quiet *]}

# Alias
alias gman {gui_show_man_page}
