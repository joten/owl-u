## Default setting of configuration variables

`Config_autoReload=0`
> If true (`=1`), the feeds are automatically reloaded on start-up.

`Config_browser=C:\Program Files\Internet Explorer\iexplore.exe`
> The browser, which is used, when opening an article or a link list.

`Config_cssFilePath=<Main_dataDir>\styles.css`
> The file path to the style sheet used for `HTML` files shown in the Internet
Explorer control.

`Config_fontName=Lucida Console`
> The font type, which is used for all text (title and status bar, lists,
summaries and articles in text mode).

`Config_fontSize=8`
> The font size, which is used for all text (title and status bar, lists,
summaries and articles in text mode).

`Config_maxItems=100`
> The maximum number of items in the entry list (older entries are deleted,
when reloading the feed).

`Config_muaCommand=`
> The filepath to the executable of an email client, i. e. Sylpheed (other
email clients are not supported).

`Config_reloadTime=0`
> The time in milliseconds after which all feeds are reloaded automatically, if
`Config_autoReload` above is set to true (`=1`); `0` means no reload.

`Config_windowHeight=600`
> The initial window height of owl-u.

`Config_windowWidth=800`
> The initial window width of owl-u.

`Config_htmlTemplate=<!doctype html>\`n<html lang="en">\`n<head>\`n  <meta charset="<!-- charset -->">\`n  <link rel="stylesheet" href="./styles.css">\`n</head>\`n<body>\`n\`n<!-- body -->\`n</body>\`n</html>\`n`
> The HTML template text with variables being replaced by owl-u.

`Config_feed_xmlUrl=http://www.autohotkey.com/forum/rss.php`
> The Url, from which to download the feed. It is also used for calculating
cache ids.

`Config_feed_title=AutoHotkey Community`
> The title of the feed, which is displayed in the feed list and title bar.

`Config_feed_htmlUrl=http://www.autohotkey.com/forum/`
> The URL, which is used, when referencing an article or opening the web site
of the feed.

`Config_feed_cacheId=www_autohotkey_com_forum_rss_php`
> The identifier for the locally cached XML file of the feed.

`Config_feed_htmlSource=`
> Depending on the value of this variable, the original HTML source is filtered
and the resulting HTML source is displayed as the article. There are four
possible values (use without the quotation marks):
  + `` (unaltered, original HTML source)
  + `regex` (applying the regular expressions)
  + `body` (cutting the body from the original source and applying the regular
  expressions)
  + `text` (like "body" with all tags not containing text deleted)

`Config_feed_singleEntry=0`
> If false (`=0`), the XML file given by `Config_feed_xmlUrl` is parsed as a
feed with a list of entries. If true (`=1`), the XML file is processed by the
regular expressions (if there are any) and compared against the last saved
entry of the feed; if different, a new entry is created. With this you can
check web sites for changes, which do not provide a feed.

`Config_feed_singleReloadOnly=1`
> If false (`=0`), the feed is reloaded, when all feeds are reloaded, e. g. by
pressing the hotkey `Shift+R`.

`Config_feed_needleRegEx=`
> A regular expression, for which to search in the article (HTML) file. With
this you can filter the article text for the relevant part. If the next line in
`Config.ini` does not begin with `Config_feed_replacement=`,
`Config_feed_replacement=` is assumed, i. e. the matching string will be
deleted. You may set more than one 'needleRegEx'/'replacement' pair.

`Config_feed_replacement=`
> A string for replacing the text, matching the above needle regular
expression; it may include backreferences, e. g. `$1`, for the first
subpattern. Previous to a line for setting the variable
`Config_feed_replacement` must be a line for setting the variable
`Config_feed_needleRegEx`.
