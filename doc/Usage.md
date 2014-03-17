## Using owl-u

owl-u uses a single view interface displaying only one of the following at a
time:
+ a quick help with all supported hotkeys
+ a list of the configured feeds
+ a list of all entries of the selected feed
+ a summary for the selected entry
+ the article referred to by the selected entry either as a full (the original)
or a reduced (e. g. text only) version.

A title bar is shown on top of the view and displays one of the following
depending on the selected view:
* feed list view:
  + total number of feeds
  + number of unread entries of all feeds
  + number of etries of all feeds
* entry list view:
  + total number of entries
  + number of unread entries
  + feed title
* summary and article view:
  + feed title
  + item number of the selected entry
  + total number of entries in the feed
  + entry title

Additionally owl-u shows information on ongoing actions in a status bar and
sets a tray icon for
+ hiding and showing the main window
+ manually reloading all feeds
+ quitting owl-u

owl-u is mostly controlled with hotkeys. The available hotkeys are listed in
the document "[Default hotkeys](./Default_hotkeys.md)". For a quick help there
are the following hotkeys:

* `H`: Display the quick help with a list of the supported hotkeys.
* `Enter`: Select a feed or entry in the appropriate list or display the
summary or article of the previously selected entry.
* `Q`: Go to the previous view or leaving the quick help.
* `^q` (`Ctrl+Q`): Quit owl-u and save the feed status.
