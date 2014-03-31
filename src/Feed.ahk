/* Title:   owl-u -- Feed Reader
   Version: 0.4.0
   Author:  joten
   License: GNU General Public License version 3 (GPLv3)
*/

Feed_init(i) {
  Local filename

  If (i = Config_feedCount + 1)
    Feed_initSummary(i)
  Else {
    If Not Config_feed#%i%_htmlUrl
      Config_feed#%i%_htmlUrl := SubStr(Config_feed#%i%_xmlUrl, 1, InStr(Config_feed#%i%_xmlUrl, "/", False, InStr(Config_feed#%i%_xmlUrl, ".")))
    If Not Config_feed#%i%_cacheId
      Config_feed#%i%_cacheId := Feed_getCacheId(Config_feed#%i%_xmlUrl)
    filename := Feed_cacheDir "\" Config_feed#%i%_cacheId
    Main_makeDir(filename)
    filename .= "\entries.ini"
    List_init("Feed", i, filename, Config_feed#%i%_title)
  }
}

Feed_initSummary(i) {
  Local author, j, k, link, summary, title, updated

  List_blankMemory("Feed", i)
  Loop, % Config_feedCount {
    k := A_Index
    Loop, % List_getNumberOfItems("Feed", k)
      If List_itemHasFlag("Feed", k, A_Index, "N") {
        author  := List_getItemField("Feed", k, A_Index, "author")
        link    := List_getItemField("Feed", k, A_Index, "link")
        summary := List_getItemField("Feed", k, A_Index, "summary")
        title   := "[" k "]" "[" A_Index "] " List_getItemField("Feed", k, A_Index, "title")
        updated := List_getItemField("Feed", k, A_Index, "updated")
        j := List_addItem("Feed", i, author, "N", link, summary, title, updated)
        List_setItemField("Feed", i, j, "f", k)
        List_setItemField("Feed", i, j, "e", A_Index)
      }
  }
}

Feed_decodeHtmlChar(text) {
  If RegExMatch(text, "&[a-zA-Z]+;") {
    StringCaseSense, On
    StringReplace, text, text, &Auml`;, Ä, All
    StringReplace, text, text, &Ouml`;, Ö, All
    StringReplace, text, text, &Uuml`;, Ü, All
    StringCaseSense, Off
    StringReplace, text, text, &quot`;, ", All
    htChar := "aacute;á&acirc;â&acute;´&aelig;æ&agrave;à&apos;'&aring;å&atilde;ã&auml;ä&bdquo;„"
    . "&brvbar;¦&bull;•&ccedil;ç&cedil;¸&cent;¢&circ;ˆ&copy;©&curren;¤&dagger;†&deg;°&divide;÷"
    . "&eacute;é&ecirc;ê&egrave;è&eth;ð&euml;ë&euro;€&fnof;ƒ&frac12;½&frac14;¼&frac34;¾&gt;>"
    . "&hellip;…&iacute;í&icirc;î&iexcl;¡&igrave;ì&iquest;¿&iuml;ï&laquo;«&ldquo;“&lsaquo;‹&lsquo;‘&lt;<"
    . "&macr;¯&mdash;—&micro;µ&middot;·&nbsp; &ndash;–&not;¬&ntilde;ñ"
    . "&oacute;ó&ocirc;ô&oelig;œ&ograve;ò&ordf;ª&ordm;º&oslash;ø&otilde;õ&ouml;ö"
    . "&para;¶&permil;‰&plusmn;±&pound;£&raquo;»&rdquo;”&reg;®&rsaquo;›&rsquo;’"
    . "&sbquo;‚&scaron;š&sect;§&shy; &sup1;¹&sup2;²&sup3;³&szlig;ß&thorn;þ&tilde;˜&times;×&trade;™"
    . "&uacute;ú&ucirc;û&ugrave;ù&uml;¨&uuml;ü&yacute;ý&yen;¥&yuml;ÿ"
    Loop, PARSE, htChar, &
    {
      StringSplit, char, A_LoopField, `;
      StringReplace, text, text, &%char1%`;, %char2%, All
    }

    Loop, 256 {
      StringReplace, text, text, % "&#" A_Index - 1 ";", % Chr(A_Index - 1), All
      If (A_Index < 11)
        StringReplace, text, text, % "&#00" A_Index - 1 ";", % Chr(A_Index - 1), All
      If (A_Index < 101)
        StringReplace, text, text, % "&#0" A_Index - 1 ";", % Chr(A_Index - 1), All
      SetFormat, integer, hex
      i := A_Index - 1
      SetFormat, integer, d
      StringTrimLeft, i, i, 1
      StringReplace, text, text, % "&#" i ";", % Chr(A_Index - 1), All
    }
    StringReplace, text, text, &amp`;, &, All
  }

  Return, text
}

Feed_downloadArticle(i, j) {
  Local filename, text, url

  url := List_getItemField("Feed", i, j, "link")
  If Not (SubStr(url, 1, 6) = "mua://") {
    filename := Feed_getCacheId(url, Config_feed#%i%_htmlUrl)
    filename := Feed_cacheDir "\" Config_feed#%i%_cacheId "\" filename
    If FileExist(filename ".htm")
      Return
    Else If FileExist(filename ".tmp.htm")
      FileMove, %filename%.tmp.htm, %filename%.htm
    Else
      UrlDownloadToFile, %url%, %filename%.htm
    FileRead, text, %filename%.htm
    StringReplace, text, text, <head>, % "<head>`n`t<base href=""" Config_feed#%i%_htmlUrl """>`n"
    FileDelete, %filename%.htm
    FileAppend, %text%, %filename%.htm
  }
}

Feed_downloadToFile(i, filename) {
  Local muaFilename, url

  url := Config_feed#%i%_xmlUrl
  If (SubStr(url, 1, 6) = "mua://") {
    muaFilename := SubStr(Config_muaCommand, 1, InStr(Config_muaCommand, ".exe")) "exe"
    muaFilename := SubStr(muaFilename, InStr(muaFilename, "\", False, 0) + 1)
    Process, Exist, %muaFilename%
    If ErrorLevel {
      RunWait, % comspec " /c """ Config_muaCommand """ > " filename, , Hide
      WinActivate, ahk_id %Gui_wndId%
    }
  } Else
    UrlDownloadToFile, %url%, %filename%
}

Feed_filterHtmlPage(i, data) {
  Global

  If Config_feed#%i%_htmlSource {
    StringReplace, data, data, `r`n, , All
    StringReplace, data, data, `n, , All
    If (Config_feed#%i%_htmlSource = "body" Or Config_feed#%i%_htmlSource = "text") {
      data := RegExReplace(data, ".*<body.*?>(.*)</body>.*", "$1")
      Loop, % Config_feed#%i%_needleRegExCount
        data := RegExReplace(data, Config_feed#%i%_needleRegEx#%A_Index%, Config_feed#%i%_replacement#%A_Index%)
      If (Config_feed#%i%_htmlSource = "text")
        data := GUI_convertHtmlToText(data)
    } Else
      Loop, % Config_feed#%i%_needleRegExCount
        data := RegExReplace(data, Config_feed#%i%_needleRegEx#%A_Index%, Config_feed#%i%_replacement#%A_Index%)
  }

  Return, data
}

Feed_getCacheId(string, replacement = "") {
  If replacement
    StringReplace, string, string, %replacement%,
  StringReplace, string, string, http://,
  string := RegExReplace(string, "[/\\:\*\?<>|\. @]+", "_")

  Return, string
}

Feed_getHtmlFile(i, j) {
  Local filename, url

  url := List_getItemField("Feed", i, j, "link")
  filename := Feed_getCacheId(url, Config_feed#%i%_htmlUrl)
  filename := Feed_cacheDir "\" Config_feed#%i%_cacheId "\" filename
  If FileExist(filename ".htm")
    filename .= ".htm"
  Else {
    filename .= ".tmp.htm"
    If Not FileExist(filename)
      UrlDownloadToFile, %url%, %filename%
  }

  Return, filename
}

Feed_getTagNames(data, ByRef feedTag, ByRef entryTag, ByRef summaryTag, ByRef updatedTag) {
  If InStr(data, "</feed>") And InStr(data, "</entry>") {
    feedTag    := "feed"
    entryTag   := "entry"
    summaryTag := "summary"
    updatedTag := "updated"
  } Else If InStr(data, "</rss>") And InStr(data, "</item>") {
    feedTag    := "rss"
    entryTag   := "item"
    summaryTag := "description"
    updatedTag := "pubDate"
  } Else If InStr(data, "</rdf:RDF>") And InStr(data, "</item>") {
    feedTag    := "rdf:RDF"
    entryTag   := "item"
    summaryTag := "description"
    updatedTag := "dc:date"
  }
}

Feed_getTimestamp(str) {
  static e2 = "i)(?:(\d{1,2}+)[\s\.\-\/,]+)?(\d{1,2}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*)[\s\.\-\/,]+(\d{2,4})"
  str := RegExReplace(str, "((?:" . SubStr(e2, 42, 47) . ")\w*)(\s*)(\d{1,2})\b", "$3$2$1", "", 1)
  If RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?"
    . "(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?"
    . "(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", i)
    d3 := i1, d2 := i3, d1 := i4, t1 := i5, t2 := i7, t3 := i8, t5 := i10, t6 := i11
  Else If !RegExMatch(str, "^\W*(\d{1,2}+)(\d{2})\W*$", t)
    RegExMatch(str, "i)(\d{1,2})\s*:\s*(\d{1,2})(?:\s*:\s*(\d{1,2}))?(?:\s*([ap]m))?(?:\s*(\+|\-)(\d{1,2}))?", t)
    , RegExMatch(str, e2, d)
  f = %A_FormatFloat%
  SetFormat, Float, 02.0
  d := (d3 ? (StrLen(d3) = 2 ? 20 : "") . d3 : A_YYYY)
    . ((d2 := d2 + 0 ? d2 : (InStr(e2, SubStr(d2, 1, 3)) - 40) // 4 + 1.0) > 0 ? d2 + 0.0 : A_MM)
    . ((d1 += 0.0) ? d1 : A_DD)
    . (t1 := t1 + 0.0 ? t1 + (t1 = 12 ? t4 = "am" ? -12.0 : 0.0 : (t4 = "pm" && t1 < 12) ? 12.0 : 0.0) : 00)
    . (t2 := t2 + 0.0 ? t2 : 00)
    . (t3 := t3 + 0.0 ? t3 : 00)
  SetFormat, Float, %f%

  d -= 19700101000000,seconds
  ;; Laszlo: Code to convert from/to UNIX timestamp. (http://www.autohotkey.com/forum/topic2633.html)

  d := d + (t6 > 0 ? (t5 . (t6 * 3600)) + 0 : 0)
  Return, d
}
;; polyethene: Date parser - convert any date format to YYYYMMDDHH24MISS (http://www.autohotkey.net/~polyethene/#dateparse)

Feed_parseEntry(i, data) {
  Local filter, id, j, link, nCount, title, updated

  List_blankMemory("FeedN", i)
  FormatTime, updated
  If (SubStr(Config_feed#%i%_xmlUrl, 1, 6) = "mua://") {
    filter := SubStr(Config_feed#%i%_xmlUrl, 7)
    Loop, PARSE, data, `n, `r
    {
      nCount := RegExReplace(A_LoopField, Config_feed#%i%_needleRegEx#1, Config_feed#%i%_replacement#1)
      If nCount {
        id := RegExReplace(A_LoopField, Config_feed#%i%_needleRegEx#2, Config_feed#%i%_replacement#2)
        If id And RegExMatch(id, filter) {
          link  := "about:blank?id=" id "&updated=" Feed_getTimestamp(updated)
          title := nCount " new e-mail" (nCount > 1 ? "s" : "") " in " RegExReplace(id, filter, "$1") "."
          List_addItem("FeedN", i, "", "N", link, A_LoopField, title, updated)
        }
      }
    }
  } Else {
    data := Feed_filterHtmlPage(i, data)
    data := SubStr(data, 1, 4096)     ;; @TODO: Is there a technical reason for that limit (4096)?
    If Not (data = List_getItemField("Feed", i, 1, "summary"))
      List_addItem("FeedN", i, "", "N", Config_feed#%i%_htmlUrl, data, Config_feed#%i%_title, updated)
  }

  List_setTimestamp("FeedN", i, Feed_getTimestamp(updated))
  ;; Laszlo: Code to convert from/to UNIX timestamp. (http://www.autohotkey.com/forum/topic2633.html)
}

Feed_parseEntries(i, data) {
  Local author, entryTag, feedTag, link, pos1, pos4, summary, summaryTag, timestamp, title, updated, updatedTag

  Feed_getTagNames(data, feedTag, entryTag, summaryTag, updatedTag)
  List_blankMemory("FeedN", i)
  List_setTimestamp("FeedN", i, List_getTimestamp("Feed", i))
  pos1 := InStr(data, "<" feedTag)
  If InStr(data, "</" feedTag ">") And InStr(data, "</" entryTag ">")
    Loop {
      pos1 := InStr(data, "<" entryTag, False, pos1)
      pos4 := InStr(data, "</" entryTag ">", False, pos1)
      If pos1 And pos4 And (List_getNumberOfItems("FeedN", i) < Config_maxItems) {
        link    := Feed_parseEntryLink(data, pos1, pos4, feedTag, entryTag)
        summary := Feed_parseEntrySummary(data, pos1, pos4, summaryTag)
        updated := Feed_parseEntryUpdate(data, pos1, pos4, updatedTag, feedTag, entryTag, summary)

        timestamp := Feed_getTimestamp(updated)
        If (timestamp <= List_getTimestamp("Feed", i) Or link = List_getItemField("Feed", i, 1, "link"))
          Break

        author := Feed_parseEntryAuthor(data, pos1, pos4)
        title  := Feed_parseEntryTitle(data, pos1, pos4)
        List_addItem("FeedN", i, author, "N", link, summary, title, updated)

        If (timestamp > List_getTimestamp("FeedN", i))
          List_setTimestamp("FeedN", i, timestamp)
        pos1 := pos4
      } Else
        Break
    }
}

Feed_parseEntryAuthor(data, pos1, pos4) {
  pos2 := InStr(data, "<author", False, pos1)
  pos3 := InStr(data, "</author>", False, pos2)
  If pos2 And pos3 And (pos3 < pos4) {
    pos2 := InStr(data, ">", False, pos2) + 1
    author := SubStr(data, pos2, pos3 - pos2)
  }

  Return, author
}

Feed_parseEntryLink(data, pos1, pos4, feedTag, entryTag) {
  pos2 := InStr(data, "<link", False, pos1)
  If (feedTag = "feed" And entryTag = "entry") {
    If pos2 And (pos2 < pos4) {
      pos2 := InStr(data, "href", False, pos2)
      pos2 := InStr(data, """", False, pos2) + 1
      link := SubStr(data, pos2, InStr(data, """", False, pos2) - pos2)
    }
  } Else {
    pos3 := InStr(data, "</link>", False, pos2)
    If pos2 And pos3 And (pos3 < pos4) {
      pos2 := InStr(data, ">", False, pos2) + 1
      link := SubStr(data, pos2, pos3 - pos2)
    }
  }

  Return, link
}

Feed_parseEntrySummary(data, pos1, pos4, summaryTag) {
  pos2 := InStr(data, "<" summaryTag, False, pos1)
  pos3 := InStr(data, "</" summaryTag ">", False, pos2)
  If pos2 And pos3 And (pos3 < pos4) {
    pos2 := InStr(data, ">", False, pos2) + 1
    summary := SubStr(data, pos2, pos3 - pos2)
    If RegExMatch(summary, "&lt;/[a-zA-Z]+&gt;")
      summary := Feed_decodeHtmlChar(summary)
    summary := RegExReplace(summary, "<img [^>]+>")
    StringReplace, summary, summary, ]]>, , All
  }

  Return, summary
}

Feed_parseEntryTitle(data, pos1, pos4) {
  pos2 := InStr(data, "<title", False, pos1)
  pos3 := InStr(data, "</title>", False, pos2)
  If pos2 And pos3 And (pos3 < pos4) {
    pos2 := InStr(data, ">", False, pos2) + 1
    title := SubStr(data, pos2, pos3 - pos2)
    StringReplace, title, title, <![CDATA[, , All
    StringReplace, title, title, ]]>, , All
    title := Feed_decodeHtmlChar(title)
  }

  Return, title
}

Feed_parseEntryUpdate(data, pos1, pos4, updatedTag, feedTag, entryTag, summary) {
  pos2 := InStr(data, "<" updatedTag, False, pos1)
  pos3 := InStr(data, "</" updatedTag ">", False, pos2)
  If pos2 And pos3 And (pos3 < pos4) {
    pos2 := InStr(data, ">", False, pos2) + 1
    updated := SubStr(data, pos2, pos3 - pos2)
  } Else If (feedTag = "rss" And entryTag = "item" And InStr(summary, "Posted: ")) {
    updated := RegExReplace(summary, ".*Posted: ")
    updated := RegExReplace(updated, "\R.*")
    updated := RegExReplace(updated, "<.*")
  }

  Return, updated
}

Feed_purgeDeleted(i) {
  Local filename, s

  ;; Delete entries from the deletion list
  s := List_getDeleted("Feed", i)
  StringTrimLeft, s, s, 1
  StringTrimRight, s, s, 1
  Sort, s, NRD`;
  Loop, PARSE, s, `;
  {
    filename := Feed_getCacheId(List_getItemField("Feed", i, A_LoopField, "link"), Config_feed#%i%_htmlUrl)
    filename := Feed_cacheDir "\" Config_feed#%i%_cacheId "\" filename
    FileMove, %filename%.htm, %filename%.tmp.htm
    List_removeItem("Feed", i, A_LoopField)
  }
  List_setDeleted("Feed", i, ";")
}

Feed_readEncodedFile(filename) {
  FileRead, data, %filename%
  p := InStr(data, "encoding=", False, InStr(data, "<\?xml")) + 10
  encoding := SubStr(data, p, InStr(data, """", False, p) - p)
  StringLower, encoding, encoding
  If (encoding = "iso-8859-1")
    FileRead, data, *P28591 %filename%
  Else If (encoding = "iso-8859-15")
    FileRead, data, *P28605 %filename%

  Return, data
}

Feed_reload(i) {
  Local d = 0, data, filename, m = 0, n = 0, statusStr, u = 0

  statusStr := GUI_SB_getText()
  SB_SetText(statusStr " downloading")
  filename := Feed_cacheDir "\" i "_" A_Now A_MSec ".tmp.xml"
  Feed_downloadToFile(i, filename)
  data := Feed_readEncodedFile(filename)
  SB_SetText(statusStr)

  If data {
    If Config_feed#%i%_singleEntry
      Feed_parseEntry(i, data)
    Else
      Feed_parseEntries(i, data)
    n := List_getNumberOfItems("FeedN", i)            ;; Number of new entries
    If (List_getNumberOfItems("Feed", i) > 0 And n < Config_maxItems) {
      Feed_purgeDeleted(i)
      m := Config_maxItems - n                        ;; Number of old entries, to be kept
      If (List_getNumberOfItems("Feed", i) < m)
        m := List_getNumberOfItems("Feed", i)
      Else
        d := List_getNumberOfItems("Feed", i) - m     ;; Number of old entries, to be deleted
      List_moveDeletedItems("Feed", i, d, m)
      u := List_moveOldItems("Feed", i, m, n)
    } Else If (n > Config_maxItems)
      n := Config_maxItems
    List_moveNewItems("Feed", i, n)
    StringReplace, Config_feed#%i%_title, Config_feed#%i%_title, % " [ERROR!]", , All
    List_setTimestamp("Feed", i, List_getTimestamp("FeedN", i))
    List_setNumberOfItems("Feed", i, n + m + d)
    List_setNumberOfUnseenItems("Feed", i, u + n)

    Return, True
  } Else {
    Config_feed#%i%_title .= " [ERROR!]"
    List_setNumberOfUnseenItems("Feed", i, "?")

    Return, False
  }
}
