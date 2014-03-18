## Customizing owl-u

owl-u can be customized by setting configuration variables and hotkeys (the key
bindings for the owl-u functions).

To change either of them, first create a configuration file (`Config.ini`) by
using the hotkey `^w`, i. e. `Ctrl+W`, or `I` for importing a feed list in OPML
format. The file is either saved in the directory you specified with the first
command line argument, when running owl-u, or in the Windows user directory
(e. g. `C:\Users\joten\AppData\Roaming\owl-u`).

You may then edit the file with a text editor, i. a. using the hotkey `^e`
(`Ctrl+E`), and add a new line for each configuration variable with its value;
the general format is `<variable>=<value>` not using quotation marks
surrounding the values. If you want to set a boolean value, use `1` for "True"
and `0` for "False"; e. g. `Config_autoReload=0`. You will have to restart
owl-u for the changes to take effect.

To configure a feed you do not need to set any indexing number to variables,
but start the configuration block with the variable `Config_feed_xmlUrl`. The
feeds are then indexed in the order, in which they appear in `Config.ini`. You
may set additional variable in the lines following `Config_feed_xmlUrl`; i. a.:

* `Config_feed_title`
* `Config_feed_htmlUrl`
* `Config_feed_cacheId`
* `Config_feed_htmlSource`
* `Config_feed_htmlSource`
* `Config_feed_singleReloadOnly`
* `Config_feed_needleRegEx`
* `Config_feed_replacement`

See the document "[Default configuration](./Default_configuration.md)" for a
description of these variables.

To configure owl-u to check the Sylpheed email client for new emails, use the
following feed configuration:

    Config_feed_xmlUrl=mua://#mh/mail/(.+)
    Config_feed_title=New e-mails (Sylpheed)
    Config_feed_htmlUrl=
    Config_feed_cacheId=mua_#mh_mail
    Config_feed_singleEntry=1
    Config_feed_needleRegEx=^\s*([0-9]+).+
    Config_feed_replacement=$1
    Config_feed_needleRegEx=^[0-9\s]+(.*)
    Config_feed_replacement=$1

To set a hotkey, use the variable name `Config_hotkey` and [the hotkey notation
from AutoHotkey](http://ahkscript.org/docs/Hotkeys.htm) as value:
`Config_hotkey=<key name>::<command or function name>`.
You may overwrite default or add new hotkeys. To deacivate a hotkey from the
default configuration, add a new line in the format
`Config_hotkey=<key name>::` (without a function name).

The available configuration variables are listed in the document
"[Default configuration](./Default_configuration.md)"; the hotkeys with their
associated functions are listed in the document
"[Default hotkeys](./Default_hotkeys.md)".

Additionally you may edit the `.css` file, which is saved in the data
directory, i. e. either in the directory you specified  with the first command
line argument, when running owl-u, or in the Windows user directory (e. g.
`C:\Users\joten\AppData\Roaming\owl-u`).

Please keep in mind that not all file encodings for XML files are supported,
but can be easily added by editing the source code.
