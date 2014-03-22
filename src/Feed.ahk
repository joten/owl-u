/* Title:   owl-u -- Feed Reader
   Version: 0.4.0
   Author:  joten
   License: GNU General Public License version 3 (GPLv3)
*/

Feed_init(i) {
  Local filename, j, k, var, val

  If (i = Config_feedCount + 1) {
    j := 0
    Loop, % Config_feedCount {
      k := A_Index
      Loop, % Feed#%k%_eCount
        If (Feed#%k%_e#%A_Index%_flag = "N") {
          j += 1
          Feed#%i%_e#%j%_f       := k
          Feed#%i%_e#%j%_e       := A_index
          Feed#%i%_e#%j%_author  := Feed#%k%_e#%A_Index%_author
          Feed#%i%_e#%j%_flag    := "N"
          Feed#%i%_e#%j%_link    := Feed#%k%_e#%A_Index%_link
          Feed#%i%_e#%j%_summary := Feed#%k%_e#%A_Index%_summary
          Feed#%i%_e#%j%_title   := "[" SubStr(Gui_fCountStr k, -StrLen(Config_feedCount) + 1) "]"
          Feed#%i%_e#%j%_title   .= "[" SubStr(Gui_eCountStr0 A_Index, -StrLen(Config_maxItems * Config_feedCount) + 1) "] " Feed#%k%_e#%A_Index%_title
          Feed#%i%_e#%j%_updated := Feed#%k%_e#%A_Index%_updated
        }
    }
    Feed#%i%_eCount := j
    Feed#%i%_unreadECount := j
  } Else {
    If Not Config_feed#%i%_htmlUrl
      Config_feed#%i%_htmlUrl := SubStr(Config_feed#%i%_xmlUrl, 1, InStr(Config_feed#%i%_xmlUrl, "/", False, InStr(Config_feed#%i%_xmlUrl, ".")))
    If Not Config_feed#%i%_cacheId
      Config_feed#%i%_cacheId := Feed_getCacheId(Config_feed#%i%_xmlUrl)
    filename := Feed_cacheDir "\" Config_feed#%i%_cacheId
    If Not FileExist(filename)
      FileCreateDir, %filename%
    filename .= "\entries.ini"
    If FileExist(filename)
      Loop, READ, %filename%
        If (SubStr(A_LoopReadLine, 1, 2) = "e#" Or SubStr(A_LoopReadLine, 1, 6) = "eCount" Or SubStr(A_LoopReadLine, 1, 9) = "timestamp"
        Or SubStr(A_LoopReadLine, 1, 12) = "unreadECount") {
          var := SubStr(A_LoopReadLine, 1, InStr(A_LoopReadLine, "=") - 1)
          val := SubStr(A_LoopReadLine, InStr(A_LoopReadLine, "=") + 1)
          Feed#%i%_%var% := val
        }
    If Not Feed#%i%_timestamp
      Feed#%i%_timestamp := 0
    If Not Feed#%i%_eCount
      Feed#%i%_eCount := 0
    If Not Feed#%i%_unreadECount
      Feed#%i%_unreadECount := 0
    Feed#%i%_delete := ";"
  }
}

Feed_cleanup(i) {
  Local filename, j, k

  StringTrimLeft, Feed#%i%_delete, Feed#%i%_delete, 1
  StringTrimRight, Feed#%i%_delete, Feed#%i%_delete, 1
  Sort, Feed#%i%_delete, NRD`;
  Loop, PARSE, Feed#%i%_delete, `;
  {
    filename := Feed_getCacheId(Feed#%i%_e#%A_LoopField%_link, Config_feed#%i%_htmlUrl)
    filename := Feed_cacheDir "\" Config_feed#%i%_cacheId "\" filename
    FileMove, %filename%.htm, %filename%.tmp.htm
    Loop, % Feed#%i%_eCount - A_LoopField {
      j := A_LoopField + A_Index
      k := j - 1
      Feed#%i%_e#%k%_author     := Feed#%i%_e#%j%_author
      Feed#%i%_e#%k%_flag       := Feed#%i%_e#%j%_flag
      Feed#%i%_e#%k%_link       := Feed#%i%_e#%j%_link
      Feed#%i%_e#%k%_summary    := Feed#%i%_e#%j%_summary
      Feed#%i%_e#%k%_title      := Feed#%i%_e#%j%_title
      Feed#%i%_e#%k%_updated    := Feed#%i%_e#%j%_updated
    }
    k := Feed#%i%_eCount
    Feed#%i%_e#%k%_author     := ""
    Feed#%i%_e#%k%_flag       := ""
    Feed#%i%_e#%k%_link       := ""
    Feed#%i%_e#%k%_summary    := ""
    Feed#%i%_e#%k%_title      := ""
    Feed#%i%_e#%k%_updated    := ""
    Feed#%i%_eCount -= 1
  }
  Feed#%i%_delete := ";"
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

  url := Feed#%i%_e#%j%_link
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

Feed_getCacheId(string, replacement = "") {
  If replacement
    StringReplace, string, string, %replacement%,
  StringReplace, string, string, http://,
  string := RegExReplace(string, "[/\\:\*\?<>|\. @]+", "_")

  Return, string
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
  ; Laszlo: Code to convert from/to UNIX timestamp. (http://www.autohotkey.com/forum/topic2633.html)

  d := d + (t6 > 0 ? (t5 . (t6 * 3600)) + 0 : 0)
  Return, d
}
; polyethene: Date parser - convert any date format to YYYYMMDDHH24MISS (http://www.autohotkey.net/~polyethene/#dateparse)

Feed_parseEntry(i, data) {
  Local filter, id, j, nCount, updated

  If Config_feed#%i%_htmlSource {
    StringReplace, data, data, `r`n, , All
    StringReplace, data, data, `n, , All
    If (Config_feed#%i%_htmlSource = "body" Or Config_feed#%i%_htmlSource = "text") {
      data := RegExReplace(data, ".*<body.*?>(.*)</body>.*", "$1")
      Loop, % Config_feed#%i%_needleRegExCount
        data := RegExReplace(data, Config_feed#%i%_needleRegEx#%A_Index%, Config_feed#%i%_replacement#%A_Index%)
      If (Config_feed#%i%_htmlSource = "text") {
        data := RegExReplace(data, "<form.+?</form>")
        data := RegExReplace(data, "<object.+?</object>")
        data := RegExReplace(data, "<script.+?</script>")
        data := RegExReplace(data, "<style.+?</style>")

        data := RegExReplace(data, "</?div.*?>")
        data := RegExReplace(data, "<img .+?>")
        data := RegExReplace(data, "<!--.+?-->")
        data := "<div class=""fixed-width"">" data "</div>"
      }
    } Else
      Loop, % Config_feed#%i%_needleRegExCount
        data := RegExReplace(data, Config_feed#%i%_needleRegEx#%A_Index%, Config_feed#%i%_replacement#%A_Index%)
  }

  Feed#N%i%_eCount := 0
  FormatTime, updated
  If (SubStr(Config_feed#%i%_xmlUrl, 1, 6) = "mua://") {
    filter := SubStr(Config_feed#%i%_xmlUrl, 7)
    Loop, PARSE, data, `n, `r
    {
      nCount := RegExReplace(A_LoopField, Config_feed#%i%_needleRegEx#1, Config_feed#%i%_replacement#1)
      If nCount {
        id := RegExReplace(A_LoopField, Config_feed#%i%_needleRegEx#2, Config_feed#%i%_replacement#2)
        If id And RegExMatch(id, filter) {
          Feed#N%i%_eCount += 1
          j := Feed#N%i%_eCount
          Feed#N%i%_e#%j%_link := "about:blank?id=" id "&updated=" Feed_getTimestamp(updated)
          Feed#N%i%_e#%j%_summary := A_LoopField
          Feed#N%i%_e#%j%_title := nCount " new e-mail" (nCount > 1 ? "s" : "") " in " RegExReplace(id, filter, "$1") "."
          Feed#N%i%_e#%j%_updated := updated
        }
      }
    }
  } Else {
    data := SubStr(data, 1, 4096)
    If Not (data = Feed#%i%_e#1_summary) {
      Feed#N%i%_eCount := 1
      Feed#N%i%_e#1_link := Config_feed#%i%_htmlUrl
      Feed#N%i%_e#1_summary := data
      Feed#N%i%_e#1_title := Config_feed#%i%_title
      Feed#N%i%_e#1_updated := updated
    }
  }

  Feed#N%i%_timestamp := Feed_getTimestamp(updated)
  ; Laszlo: Code to convert from/to UNIX timestamp. (http://www.autohotkey.com/forum/topic2633.html)
}

Feed_parseEntries(i, data) {
  Local entryTag, feedTag, link, n = 0, pos1, pos2, pos3, pos4, summary, summaryTag, timestamp, title, updated, updatedTag

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
  Feed#N%i%_timestamp := Feed#%i%_timestamp
  pos1 := InStr(data, "<" feedTag)
  If InStr(data, "</" feedTag ">") And InStr(data, "</" entryTag ">")
    Loop {
      pos1 := InStr(data, "<" entryTag, False, pos1)
      pos4 := InStr(data, "</" entryTag ">", False, pos1)
      If pos1 And pos4 And (n < Config_maxItems) {
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

        timestamp := Feed_getTimestamp(updated)
        If (timestamp <= Feed#%i%_timestamp Or link = Feed#%i%_e#1_link)
          Break
        Else {
          n += 1
          If (timestamp > Feed#N%i%_timestamp)
            Feed#N%i%_timestamp := timestamp
          Feed#N%i%_e#%n%_link    := link
          Feed#N%i%_e#%n%_summary := summary
          Feed#N%i%_e#%n%_updated := updated
        }

        pos2 := InStr(data, "<author", False, pos1)
        pos3 := InStr(data, "</author>", False, pos2)
        If pos2 And pos3 And (pos3 < pos4) {
          pos2 := InStr(data, ">", False, pos2) + 1
          Feed#N%i%_e#%n%_author := SubStr(data, pos2, pos3 - pos2)
        }

        pos2 := InStr(data, "<title", False, pos1)
        pos3 := InStr(data, "</title>", False, pos2)
        If pos2 And pos3 And (pos3 < pos4) {
          pos2 := InStr(data, ">", False, pos2) + 1
          title := SubStr(data, pos2, pos3 - pos2)
          StringReplace, title, title, <![CDATA[, , All
          StringReplace, title, title, ]]>, , All
          Feed#N%i%_e#%n%_title := Feed_decodeHtmlChar(title)
        }

        pos1 := pos4
      } Else
        Break
    }

  Feed#N%i%_eCount := n
}

Feed_reload(i) {
  Local d = 0, data, encoding, filename, j, k, m = 0, muaFilename, n = 0, p, statusStr, u = 0, url

  GuiControlGet, statusStr, , Gui#4

  SB_SetText(statusStr " downloading")
  url := Config_feed#%i%_xmlUrl
  filename := Feed_cacheDir "\" i "_" A_Now A_MSec ".tmp.xml"
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
  FileRead, data, %filename%
  p := InStr(data, "encoding=", False, InStr(data, "<\?xml")) + 10
  encoding := SubStr(data, p, InStr(data, """", False, p) - p)
  StringLower, encoding, encoding
  If (encoding = "iso-8859-1")
    FileRead, data, *P28591 %filename%
  Else If (encoding = "iso-8859-15")
    FileRead, data, *P28605 %filename%

  SB_SetText(statusStr)

  If data {
    If Config_feed#%i%_singleEntry
      Feed_parseEntry(i, data)
    Else
      Feed_parseEntries(i, data)
    n := Feed#N%i%_eCount
    If (Feed#%i%_eCount And n < Config_maxItems) {
      Feed_cleanup(i)
      m := Config_maxItems - n
      If (Feed#%i%_eCount < m)
        m := Feed#%i%_eCount
      Else
        d := Feed#%i%_eCount - m
      Loop, % d {
        j := m + d - A_Index + 1
        k := Config_maxItems + d - A_Index + 1
        Feed#%i%_delete .= k ";"
        Feed#%i%_e#%k%_author     := Feed#%i%_e#%j%_author
        Feed#%i%_e#%k%_flag       := "D"
        Feed#%i%_e#%k%_link       := Feed#%i%_e#%j%_link
        Feed#%i%_e#%k%_summary    := Feed#%i%_e#%j%_summary
        Feed#%i%_e#%k%_title      := Feed#%i%_e#%j%_title
        Feed#%i%_e#%k%_updated    := Feed#%i%_e#%j%_updated
      }
      Loop, % m {
        j := m - A_Index + 1
        k := n + m - A_Index + 1
        Feed#%i%_e#%k%_author     := Feed#%i%_e#%j%_author
        Feed#%i%_e#%k%_flag       := Feed#%i%_e#%j%_flag
        If (Feed#%i%_e#%k%_flag = "N")
          u += 1
        Feed#%i%_e#%k%_link       := Feed#%i%_e#%j%_link
        Feed#%i%_e#%k%_summary    := Feed#%i%_e#%j%_summary
        Feed#%i%_e#%k%_title      := Feed#%i%_e#%j%_title
        Feed#%i%_e#%k%_updated    := Feed#%i%_e#%j%_updated
      }
    } Else If (n > Config_maxItems)
      n := Config_maxItems
    Loop, % Feed#N%i%_eCount {
      If (A_Index <= n) {
        Feed#%i%_e#%A_Index%_author     := Feed#N%i%_e#%A_Index%_author
        Feed#%i%_e#%A_Index%_flag       := "N"
        Feed#%i%_e#%A_Index%_link       := Feed#N%i%_e#%A_Index%_link
        Feed#%i%_e#%A_Index%_summary    := Feed#N%i%_e#%A_Index%_summary
        Feed#%i%_e#%A_Index%_title      := Feed#N%i%_e#%A_Index%_title
        Feed#%i%_e#%A_Index%_updated    := Feed#N%i%_e#%A_Index%_updated
      }
      Feed#N%i%_e#%A_Index%_author     := ""
      Feed#N%i%_e#%A_Index%_link       := ""
      Feed#N%i%_e#%A_Index%_summary    := ""
      Feed#N%i%_e#%A_Index%_title      := ""
      Feed#N%i%_e#%A_Index%_updated    := ""
    }
    StringReplace, Config_feed#%i%_title, Config_feed#%i%_title, % " [ERROR!]", , All
    Feed#%i%_timestamp := Feed#N%i%_timestamp
    Feed#%i%_eCount := n + m + d
    Feed#%i%_unreadECount := u + n

    Feed#N%i%_eCount :=
    Feed#N%i%_timestamp :=

    Return, True
  } Else {
    Config_feed#%i%_title .= " [ERROR!]"
    Feed#%i%_unreadECount := "?"

    Return, False
  }
}

Feed_save(i) {
  Local field, filename, text

  filename := Feed_cacheDir "\" Config_feed#%i%_cacheId "\entries.ini"
  text := ";; " NAME " v" VERSION " -- " Config_feed#%i%_title " (" A_DD "." A_MM "." A_YYYY ")`n`n"

  text .= "timestamp=" Feed#%i%_timestamp "`n"
  text .= "eCount=" Feed#%i%_eCount "`n"
  text .= "unreadECount=" Feed#%i%_unreadECount "`n"
  Loop, % Feed#%i%_eCount {
    text .= "`n"
    Loop, % Feed_entryField_#0 {
      field := Feed_entryField_#%A_Index%
      If (field = "summary")
        StringReplace, Feed#%i%_e#%A_Index%_summary, Feed#%i%_e#%A_Index%_summary, `n, <br/>, All
      text .= "e#" A_Index "_" field "=" Feed#%i%_e#%A_Index%_%field% "`n"
    }
  }

  FileDelete, %filename%
  FileAppend, %text%, %filename%
}
