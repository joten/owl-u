## Default hotkeys

### General description

The hotkeys, as you can set them in `Config.ini`, are noted in the format
`<modifier><key>::<function>(<argument>)`.
Possible modifiers are the following:

* `!` (Alt)
* `^` (Ctrl, Control)
* `#` (LWin, left Windows)
* `+` (Shift)

You will have to press all keys of a hotkey at the same time beginning with the
modifier for calling the associated function, e. g. `^q` means pressing the
'Control key' and the 'Q key' (`Ctrl+Q`) for quitting owl-u.

`BackSpace::Gui_navigate(back)`
> Go back in the embedded Internet Explorer, if it shows an article.

`d::Main_download()`
> Download the article(s) of the selected entry or feed (all entries).

`Enter::Gui_navigate(+1)`
> Go to the next view (feeds -> entries -> abstract -> article).

`h::Gui_navigate(h)`
> Show the list of supported hotkeys.

`i::Main_importFeedList()`
> Import a feed list from an OPML file (only available in the feed list view or
help).

`n::Gui_showUnreadEntry(+1)`
> Show the next (in time) unread entry in the list (only available in the
abstract or article view).

`o::Gui_openArticle()`
> Open the article for the selected entry in a web browser.

`p::Gui_showUnreadEntry(-1)`
> Show the previous (in time) unread entry in the list (only available in the
abstract or article view).

`q::Gui_navigate(-1)`
> Go to the previous view (article -> abstract -> entries -> feeds).

`r::Main_reloadFeed()`
> Reload the selected feed (only available in the feed list view). This action
blocks all hotkeys to prevent interference.

`u::Main_toggleUnreadMark()`
> Toggle the unread mark ("N") for the selected entry.

`0::Gui_showUnreadEntry(0)`
> Show the first (in time = oldest) unread entry in the list (only available in
the abstract or article view).

`+a::Main_markFeedRead()`
> Mark all entries in the current feed read (only available in the entry list
view).

`+d::Main_toggleDeleteMark()`
> Toggle the deletion mark ("D") for the selected entry (delete the entry and
the associated cached files).

`+h::Run, explore <A_ScriptDir>(\..)?\doc`
> Open the documentation directory with the help file in explorer.

`+r::Main_reloadFeeds()`
> Reload all feeds (only available in the feed list view). This action blocks
all hotkeys to prevent interference.

`^e::Config_editIni()`
> Edit the configuration file (`Config_iniFilePath`).

`^q::ExitApp`
> Quit owl-u from any view.

`^r::Reload`
> Reload owl-u. This i. a. reloads the configuration variables.

`^u::Gui_toggleSourceView()`
> Toggle the article view: `` (full HTML) -> `regex` -> `body` -> `text` (only
available in the article view).

`^w::Config_writeIni()`
> Write the configuration file (`Config_iniFilePath`).
