/* Title:   owl-u -- Feed Reader
   Version: 0.4.0
   Author:  joten
   License: GNU General Public License version 3 (GPLv3)
*/

Config_init() {
  Local i

  Config_autoReload   := False
  Config_browser      := "C:\Program Files\Internet Explorer\iexplore.exe"
  Config_cssFilePath  := Main_dataDir "\styles.css"
  Config_fontName     := "Lucida Console"
  Config_fontSize     := 8
  Config_maxItems     := 100
  Config_muaCommand   := ""
  Config_reloadTime   := 0
  Config_windowHeight := 600
  Config_windowWidth  := 800
  Config_htmlTemplate =
    (LTrim
      <!doctype html>`n<html lang="en">
      <head>`n  <meta charset="<!-- charset -->">`n  <link rel="stylesheet" href="../styles.css">`n</head>
      <body>`n`n<!-- body -->`n</body>`n</html>
    )

  If Not FileExist(Config_iniFilePath) {
    Config_feed#1_xmlUrl  := "https://github.com/joten/owl-u/commits/master.atom"
    Config_feed#1_title   := "owl-u@GitHub"
    Config_feed#1_htmlUrl := "https://github.com/joten/owl-u"
    Config_feed#1_singleReloadOnly := True

    Config_feedCount := 1
  } Else
    Config_readIni()

  i := Config_feedCount + 1
  Config_feed#%i%_title := "Summary of new entries"
}

Config_blankFeedMemory() {
  Global

  Loop, % Config_feedCount
    List_blankMemory("Feed", A_Index)
  Config_feedCount := 0
}

Config_editIni() {
  Global Config_iniFilePath

  If Not FileExist(Config_iniFilePath)
    Config_writeIni()
  Run, edit %Config_iniFilePath%
}

Config_hotkeyLabel:
  Config_redirectHotkey(A_ThisHotkey)
Return

Config_importFeedList() {
  Local data, filename, htmlUrl, pos1, pos4, title, xmlUrl, xmlUrlExist

  FileSelectFile, filename, 3, , %NAME% %VERSION% -- Select file
  FileRead, data, %filename%
  If InStr(data, "</opml>") And InStr(data, "</body>") {
    If Not FileExist(Config_iniFilePath)
      Config_blankFeedMemory()
    pos4 := InStr(data, "<body")
    Loop {
      pos1 := InStr(data, "<outline", False, pos4)
      pos4 := InStr(data, "/>", False, pos1)
      If pos1 And pos4 {
        If Not Config_parseOpmlEntry(data, pos1, pos4, xmlUrl, htmlUrl, title)
          Continue
        xmlUrlExist := False
        Loop, % Config_feedCount
          If (xmlUrl = Config_feed#%A_Index%_xmlUrl) {
            xmlUrlExist := True
            Break
          }
        If xmlUrlExist
          Continue

        Config_feedCount += 1
        Config_feed#%Config_feedCount%_cacheId := Feed_getCacheId(xmlUrl)
        Config_feed#%Config_feedCount%_xmlUrl  := xmlUrl
        Config_feed#%Config_feedCount%_htmlUrl := htmlUrl
        Config_feed#%Config_feedCount%_title   := title
        Feed_init(Config_feedCount)
      } Else
        Break
    }
    Config_writeIni()
  }
}

Config_parseOpmlEntry(data, pos1, pos4, ByRef xmlUrl, ByRef htmlUrl, ByRef title) {
  pos2 := InStr(data, "type", False, pos1)
  If pos2 And (pos2 < pos4)
    type := SubStr(data, InStr(data, """", False, pos2) + 1, 3)
  If Not InStr(type, "rss")
    Return, False

  pos2 := InStr(data, "xmlUrl", False, pos1)
  If pos2 And (pos2 < pos4) {
    pos3 := InStr(data, """", False, pos2) + 1
    xmlUrl := SubStr(data, pos3, InStr(data, """", False, pos3) - pos3)
  }
  If Not xmlUrl
    Return, False

  pos2 := InStr(data, "htmlUrl", False, pos1)
  If pos2 And (pos2 < pos4) {
    pos3 := InStr(data, """", False, pos2) + 1
    htmlUrl := SubStr(data, pos3, InStr(data, """", False, pos3) - pos3)
  }

  pos2 := InStr(data, "title", False, pos1)
  If pos2 And (pos2 < pos4) {
    pos3 := InStr(data, """", False, pos2) + 1
    title := SubStr(data, pos3, InStr(data, """", False, pos3) - pos3)
  }

  Return, True
}

Config_readIni() {
  Local i, p, var, val

  Loop, READ, %Config_iniFilePath%
    If (SubStr(A_LoopReadLine, 1, 7) = "Config_") {
      var := SubStr(A_LoopReadLine, 1, InStr(A_LoopReadLine, "=") - 1)
      val := SubStr(A_LoopReadLine, InStr(A_LoopReadLine, "=") + 1)
      If (SubStr(var, 1, 12) = "Config_feed_") {
        var := SubStr(var, 13)
        If (var = "xmlUrl")
          Config_feedCount += 1
        If (var = "needleRegEx") {
          Config_feed#%Config_feedCount%_needleRegExCount += 1
          i := Config_feed#%Config_feedCount%_needleRegExCount
          Config_feed#%Config_feedCount%_needleRegEx#%i% := val
        } Else If (var = "replacement")
          Config_feed#%Config_feedCount%_replacement#%i% := val
        Else
          Config_feed#%Config_feedCount%_%var% := val
      } Else If (var = "Config_hotkey") {
        Config_hotkeyCount += 1
        p := InStr(val, "::")
        Config_hotkey#%Config_hotkeyCount%_key := SubStr(val, 1, p - 1)
        Config_hotkey#%Config_hotkeyCount%_command := SubStr(val, p + 2)
        If Not Config_hotkey#%Config_hotkeyCount%_command
          Hotkey, % Config_hotkey#%Config_hotkeyCount%_key, Off
        Else
          Hotkey, % Config_hotkey#%Config_hotkeyCount%_key, Config_hotkeyLabel
      } Else
        %var% := val
    }
}

Config_redirectHotkey(key) {
  Local fuArgs, fuName, i, j

  Loop, % Config_hotkeyCount
    If (key = Config_hotkey#%A_index%_key) {
      i := InStr(Config_hotkey#%A_index%_command, "(")
      j := InStr(Config_hotkey#%A_index%_command, ")", False, i)
      If i And j {
        fuName := SubStr(Config_hotkey#%A_index%_command, 1, i - 1)
        fuArgs := SubStr(Config_hotkey#%A_index%_command, i + 1, j - (i + 1))
        %fuName%(fuArgs)
      }
      Break
    }
}

Config_writeIni() {
  Local ht, i, text

  text := ";; " NAME " " VERSION " (" A_DD "." A_MM "." A_YYYY ")`n"

  text .= "`nConfig_autoReload=" Config_autoReload "`n"
  text .= "Config_browser=" Config_browser "`n"
  text .= "Config_cssFilePath=" Config_cssFilePath "`n"
  text .= "Config_fontName=" Config_fontName "`n"
  text .= "Config_fontSize=" Config_fontSize "`n"
  text .= "Config_maxItems=" Config_maxItems "`n"
  text .= "Config_muaCommand=" Config_muaCommand "`n"
  text .= "Config_reloadTime=" Config_reloadTime "`n"

  StringReplace, ht, Config_htmlTemplate, `n, , All
  text .= "Config_htmlTemplate=" ht "`n"

  text .= "Config_windowHeight=" Config_windowHeight "`n"
  text .= "Config_windowWidth=" Config_windowWidth "`n"

  Loop, % Config_feedCount {
    i := A_Index
    text .= "`nConfig_feed_xmlUrl=" Config_feed#%i%_xmlUrl "`n"
    text .= "Config_feed_title=" Config_feed#%i%_title "`n"
    text .= "Config_feed_htmlUrl=" Config_feed#%i%_htmlUrl "`n"
    text .= "Config_feed_cacheId=" Config_feed#%i%_cacheId "`n"
    If Config_feed#%i%_htmlSource
      text .= "Config_feed_htmlSource=" Config_feed#%i%_htmlSource "`n"
    If Config_feed#%i%_singleEntry
      text .= "Config_feed_singleEntry=" Config_feed#%i%_singleEntry "`n"
    If Config_feed#%i%_singleReloadOnly
      text .= "Config_feed_singleReloadOnly=" Config_feed#%i%_singleReloadOnly "`n"
    Loop, % Config_feed#%i%_needleRegExCount {
      text .= "Config_feed_needleRegEx=" Config_feed#%i%_needleRegEx#%A_Index% "`n"
      If Config_feed#%i%_replacement#%A_Index%
        text .= "Config_feed_replacement=" Config_feed#%i%_replacement#%A_Index% "`n"
    }
  }

  FileDelete, %Config_iniFilePath%
  FileAppend, %text%, %Config_iniFilePath%
}

;; Key definitions
#IfWinActive owl-u ahk_class AutoHotkeyGUI
{
  BackSpace::Gui_IE_navigate("back")
  d::Main_download()
  Enter::Gui_navigate(+1)
  h::Gui_navigate("h")
  i::Main_importFeedList()
  n::Gui_showUnreadEntry(+1)
  o::Gui_openArticle()
  p::Gui_showUnreadEntry(-1)
  q::Gui_navigate(-1)
  r::Main_reloadFeed()
  u::Main_toggleUnreadMark()
  0::Gui_showUnreadEntry(0)
  +a::Main_markFeedRead()
  +d::Main_toggleDeleteMark()
  +h::Run, explore %Main_docDir%
  +r::Main_reloadFeeds()
  ^e::Config_editIni()
  ^q::ExitApp
  ^r::Reload
  ^u::Gui_toggleSourceView()
  ^w::Config_writeIni()
}
