Tags     software / Microsoft Windows / feed reader / RSS / Atom / RDF / AutoHotkey
Title    owl-u
Author   joten
Version  0.2.0
Date     07.01.2012

With version 0.1.0 and the transition to AutoHotkey_L the configurtion
variables and cache structure changed; therefor the configuration file
and the saved feed lists of version 0.0.4 are not compatible. They should
be replaced or deleted; downloaded articles are compatible.

Please see docs/help.txt for more information on installing and running,
customizing and using owl-u.

Credits

  owl-u is written by joten, but some source was copied from the
  AutoHotkey forum (http://www.autohotkey.com/forum). These are explicitly
  marked in the source code at the end of the appropriate section.
  Additionally the following listing summarizes these sources (of ideas or
  code):

  Ideas or concepts
     * Andreas Krennmair: newsbeuter
	       http://www.newsbeuter.org
     * majkinetor: Rss Reader v0.21
	       http://www.autohotkey.com/forum/topic27155.html

  Code snippets
	 * HotKeyIt: [AHK_L+H] Struct() - Structures, Arrays, Vectors and more
           http://www.autohotkey.com/forum/viewtopic.php?p=364838#364838
	 * Laszlo: Code to convert from/to UNIX timestamp
           http://www.autohotkey.com/forum/topic2633.html
	 * polyethene: Date parser - convert any date format to YYYYMMDDHH24MISS
	       http://www.autohotkey.net/~polyethene/#dateparse
	 * tank: COM Object Reference [AutoHotkey_L]
           http://www.autohotkey.com/forum/topic61509-90.html
     * Sean: Dependancies to above
           http://www.autohotkey.com/forum/author-Sean.html
           http://www.autohotkey.net/~Sean/Lib/ComUtils.zip

License

  owl-u is licensed under the GPL version 3; please see docs/license.txt
  for the explicit license text.

Changes (* changed, + added, - removed)
  
  0.1.0 -> 0.2.0
     + summary of new entries as an additional feed
     - Config_fontColor#1 and Config_fontColor#2 (=> no different colors for the status bar text)
     + Config_muaCommand (path to the Sylpheed executable)
     + new "Config_feed_xmlUrl" type "mua://"
     * replacement of the custom text status bar with a Windows UI status bar
     * improved ListBox sizing (independant of row number)
     * debugged entry count string length (spaces)
     * debugged web scraper (new entries)
     * debugged opening of (downloaded) HTML files in the embedded Internet Explorer
     * debugged errors in external library "Struct.ahk" introduced with version 1.1.05.03 of AutoHotkey_L
     * minor debugging
  
  0.0.4 -> 0.1.0
     * transition from AutoHotkey (1.0.48.5) to AutoHotkey_L (1.1.0.0)
        - use of "#" instead of "[" and "]" for array variables
        - transition to UTF-8
     + additional configuration possibilities (i. a. hotkeys)
     * improved initial resize of the main window
     + introduction of timestamp for feed parsing and entry identification
     + additional function "Feed_parseEntry" (please see the help for more 
       information)
     * changed cache structure (moving of the file <cache-id>.ini to the 
       already existing directory <cache-id>\entries.ini)
     * extended HTML character conversion with hex values
     * replacement of text with HTML views (embedded Internet Explorer)
        - introducing HTML templates and CSS for a reduced HTML, text-like 
          view
        - replacing the text help with a HTML help view
     + implementation of a "back" hotkey for the embedded Internet Explorer 
       showing articles
     + implementation of a "toggle unread" hotkey for re-/setting the 
       un-/read state of entries
     * minor debugging
     - removed the function "Gui_showUrls"
    
    With the transition to AutoHotkey_L the configurtion variables changed;
    therefor the configuration file of version 0.0.4 is not compatible.
     * Config_fontColor[i] -> Config_fontColor#i
     - Config_textWidth
     * Config_feed[i]_htmlSourceView -> Config_feed_htmlSource (please see 
       the help for more information)
     * Config_feed[i]_* -> Config_feed_*
     * Config_feed[i]_needleRegEx[j] -> Config_feed_needleRegEx
     * Config_feed[i]_replacement[j] -> Config_feed_replacement
     - Config_feed[i]_needleRegExCount
     - Config_feedCount
     + Config_feed_singleEntry
     + Config_hotkey
    
    Please keep in mind that not all file encodings, i. e. for XML files 
    are supported, but can be easily added by editing the source code.

Copyright © 2010-2012 joten
