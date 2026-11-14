-- Yazi init.
--
-- <Enter> is bound to the `smart-enter` plugin (see keymap.toml). By default
-- that plugin forwards `hovered = true` to the `open` action, which is fine for
-- normal browsing, but when yazi is used as a file chooser (`--chooser-file`,
-- i.e. the XDG desktop portal / Firefox / Zen upload dialog) it means `open`
-- writes ONLY the currently hovered file to the chooser file -- files selected
-- with <Space> or visual mode are ignored, so uploads come out as a single file.
--
-- `open_multi = true` makes the plugin emit `open` without `--hovered`, so the
-- chooser file receives every selected file.
require("smart-enter"):setup {
	open_multi = true,
}
