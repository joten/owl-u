## CHANGES

##### Legend

* `-` deleted
* `~` changed
* `+` added

### 0.4.0

* `~` `BackSpace::Gui_navigate("back")` -> `BackSpace::Gui_IE_navigate("back")`
* `+` `Config_CAL_priorities`, the available priorities for creating a new CAL
item
* `+` `Config_CAL_tags`, the available tags for creating a new CAL item
* `+` `^!c::GUI_CAL_createInputWindow()`, opening the window for creating a new
CAL item

### 0.3.0

* `+` `Config_htmlTemplate` replacing `html\template.htm` and setting an HTML
template text with variables being replaced by owl-u
* `-` `html\template.htm`
* `~` The data directory is now given by the first command line argument,
rather than by setting the working directory; if not given it defaults to a
subdirectory in the user's APPDATA directory.
* `+` `Config_cssFilePath` setting the file path to the style sheet used for
`HTML` files shown in the Internet Explorer control

### 0.2.0

* `-` `Config_fontColor#1` and `Config_fontColor#2` (=> no different colors
for the status bar text)
* `+` `Config_muaCommand` (path to the Sylpheed executable)
* `+` new `Config_feed_xmlUrl` type "mua://"

### 0.1.0

With version 0.1.0 and the transition to AutoHotkey_L the configurtion
variables and cache structure changed; therefor the configuration file
and the saved feed lists of version 0.0.4 are not compatible. They should
be replaced or deleted; downloaded articles are compatible.

* `~` transition from AutoHotkey (1.0.48.5) to AutoHotkey_L (1.1.0.0)
  + use of `#` instead of `[` and `]` for array variables
  + transition to UTF-8
* `+` additional configuration possibilities (i. a. hotkeys)
  + `+` `Config_feed_singleEntry`
  + `+` `Config_hotkey`
* `+` additional function `Feed_parseEntry` (please see the help for more
information)
* `~` changed cache structure (moving of the file `<cache-id>.ini` to the
already existing directory `<cache-id>\entries.ini`)
* `~` replacement of text with HTML views (embedded Internet Explorer)
  + introducing HTML templates and CSS for a reduced HTML, text-like view
  + replacing the text help with a HTML help view
* `+` implementation of a "back" hotkey for the embedded Internet Explorer
showing articles
* `+` implementation of a "toggle unread" hotkey for re-/setting the un-/read
state of entries
* `-` removed the function `Gui_showUrls`
* `~` `Config_fontColor[i]` -> `Config_fontColor#i`
* `-` `Config_textWidth`
* `~` `Config_feed[i]_htmlSourceView` -> `Config_feed_htmlSource`
* `~` `Config_feed[i]_*` -> `Config_feed_*`
* `~` `Config_feed[i]_needleRegEx[j]` -> `Config_feed_needleRegEx`
* `~` `Config_feed[i]_replacement[j]` -> `Config_feed_replacement`
* `-` `Config_feed[i]_needleRegExCount`
* `-` `Config_feedCount`
