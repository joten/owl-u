/* Title:   owl-u -- Feed Reader
   Version: 0.3.0
   Author:  joten
   License: GNU General Public License version 3 (GPLv3)
*/

Config_init() {
  Local i, p, var, val

  Config_autoReload   := False
  Config_browser      := "C:\Program Files\Internet Explorer\iexplore.exe"
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
  <head>`n  <meta charset="<!-- charset -->">`n  <link rel="stylesheet" href="./styles.css">`n</head>
  <body>`n`n<!-- body -->`n</body>`n</html>
  )

  Config_iniFilePath := A_WorkingDir "\Config.ini"
  If Not FileExist(Config_iniFilePath) {
    Config_feed#1_xmlUrl  := "http://www.autohotkey.com/forum/rss.php"
    Config_feed#1_title   := "AutoHotkey Community"
    Config_feed#1_htmlUrl := "http://www.autohotkey.com/forum/"
    Config_feed#1_singleReloadOnly := True

    Config_feed#2_xmlUrl  := "http://www.autohotkey.com/forum/topic33189-0-desc-0.html"
    Config_feed#2_title   := "bug.n @ autohotkey.com forum"
    Config_feed#2_htmlUrl := "http://www.autohotkey.com/forum/topic33189-0-desc-0.html"
    Config_feed#2_htmlSource    := "text"
    Config_feed#2_singleEntry   := True
    Config_feed#2_singleReloadOnly := True
    Config_feed#2_needleRegEx#1 := ".*<th class=.thRight. nowrap=.nowrap.>Message</th>\s</tr>"
    Config_feed#2_needleRegEx#2 := "<span class=.nav.><a href=.#top. class=.nav.>Back to top</a></span>.*"
    Config_feed#2_needleRegEx#3 := "&amp;sid=[0-9a-f]+"
    Config_feed#2_needleRegExCount := 3

    Config_feedCount := 2
  } Else
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

  i := Config_feedCount + 1
  Config_feed#%i%_title := "Summary of new entries"
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
  Local data, filename, i, pos1, pos2, pos3, pos4, type, xmlUrl, xmlUrlExist

  FileSelectFile, filename, 3, , %NAME% %VERSION% - Select file
  FileRead, data, %filename%
  If InStr(data, "</opml>") And InStr(data, "</body>") {
    If Not FileExist(Config_iniFilePath) {
      Loop, % Config_feedCount {
        i := A_Index
        Loop, % Feed#%i%_eCount {
          Feed#%i%_e#%A_Index%_author  := ""
          Feed#%i%_e#%A_Index%_flag    := ""
          Feed#%i%_e#%A_Index%_link    := ""
          Feed#%i%_e#%A_Index%_summary := ""
          Feed#%i%_e#%A_Index%_title   := ""
          Feed#%i%_e#%A_Index%_updated := ""
        }
        Feed#%i%_timestamp := 0
        Feed#%i%_eCount := 0
        Feed#%i%_unreadECount := 0
      }
      Config_feedCount := 0
    }
    pos4 := InStr(data, "<body")
    Loop {
      pos1 := InStr(data, "<outline", False, pos4)
      pos4 := InStr(data, "/>", False, pos1)
      If pos1 And pos4 {
        pos2 := InStr(data, "type", False, pos1)
        If pos2 And (pos2 < pos4)
          type := SubStr(data, InStr(data, """", False, pos2) + 1, 3)
        If Not InStr(type, "rss")
          Continue
        pos2 := InStr(data, "xmlUrl", False, pos1)
        If pos2 And (pos2 < pos4) {
          pos3 := InStr(data, """", False, pos2) + 1
          xmlUrl := SubStr(data, pos3, InStr(data, """", False, pos3) - pos3)
        }
        If Not xmlUrl
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
        Config_feed#%Config_feedCount%_xmlUrl := xmlUrl
        pos2 := InStr(data, "htmlUrl", False, pos1)
        If pos2 And (pos2 < pos4) {
          pos3 := InStr(data, """", False, pos2) + 1
          Config_feed#%Config_feedCount%_htmlUrl := SubStr(data, pos3, InStr(data, """", False, pos3) - pos3)
        }
        pos2 := InStr(data, "title", False, pos1)
        If pos2 And (pos2 < pos4) {
          pos3 := InStr(data, """", False, pos2) + 1
          Config_feed#%Config_feedCount%_title := SubStr(data, pos3, InStr(data, """", False, pos3) - pos3)
        }
        Feed_init(Config_feedCount)
      } Else
        Break
    }
    Config_writeIni()
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
  Local i, text

  text := "; " NAME " - feed reader`n; @version " VERSION " (" A_DD "." A_MM "." A_YYYY ")`n"

  text .= "`nConfig_autoReload=" Config_autoReload "`n"
  text .= "Config_browser=" Config_browser "`n"
  text .= "Config_fontName=" Config_fontName "`n"
  text .= "Config_fontSize=" Config_fontSize "`n"
  text .= "Config_maxItems=" Config_maxItems "`n"
  text .= "Config_muaCommand=" Config_muaCommand "`n"
  text .= "Config_reloadTime=" Config_reloadTime "`n"
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

/**
 *  key definitions
 *
 *  format: <modifier><key>::<function>(<argument>)
 *  modifier: ! = Alt (Mod1Mask), ^ = Ctrl (ControlMask), + = Shift (ShiftMask), # = LWin (Mod4Mask)
 */
#IfWinActive owl-u ahk_class AutoHotkeyGUI
{
  BackSpace::Gui_navigate("back")      ; Go back in the embedded Internet Explorer, if it shows an article.
  d::Main_download()            ; Download the article(s) of the selected entry or feed (all entries).
  Enter::Gui_navigate(+1)          ; Go to the next view (feeds -> entries -> abstract -> article).
  h::Gui_navigate("h")          ; Show the list of supported hotkeys.
  i::Main_importFeedList()        ; Import a feed list from an OPML file (only available in the feed list view or help).
  n::Gui_showUnreadEntry(+1)        ; Show the next (in time) unread entry in the list (only available in the abstract or article view).
  o::Gui_openArticle()          ; Open the article for the selected entry in a web browser.
  p::Gui_showUnreadEntry(-1)        ; Show the previous (in time) unread entry in the list (only available in the abstract or article view).
  q::Gui_navigate(-1)            ; Go to the previous view (article -> abstract -> entries -> feeds).
  r::Main_reloadFeed()          ; Reload the selected feed (only available in the feed list view). This action blocks all hotkeys to prevent interference.
  u::Main_toggleUnreadMark()        ; Toggle the unread mark ("N") for the selected entry.
  0::Gui_showUnreadEntry(0)        ; Show the first (in time = oldest) unread entry in the list (only available in the abstract or article view).
  +a::Main_markFeedRead()          ; Mark all entries in the current feed read (only available in the entry list view).
  +d::Main_toggleDeleteMark()        ; Toggle the deletion mark ("D") for the selected entry (delete the entry and the associated cached files).
  +h::Run, explore %Main_docDir%    ; Open the documentation directory with the help file in explorer.
  +r::Main_reloadFeeds()          ; Reload all feeds (only available in the feed list view). This action blocks all hotkeys to prevent interference.
  ^e::Config_editIni()          ; Edit the configuration file (Config_iniFilePath).
  ^q::ExitApp                ; Quit owl-u from any view.
  ^r::Reload                ; Reload owl-u. This i. a. reloads the configuration variables.
  ^u::Gui_toggleSourceView()        ; Toggle the article view full HTML -> "regex" -> "body" -> "text" (only available in the article view).
  ^w::Config_writeIni()          ; Write the configuration file (Config_iniFilePath).
}
