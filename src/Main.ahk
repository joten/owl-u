/* Title:   owl-u -- Feed Reader
   Version: 0.3.0
   Author:  joten
   License: GNU General Public License version 3 (GPLv3)

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

NAME  := "owl-u"
VERSION := "0.3.0"

;; Script settings
FileEncoding, UTF-8
ListLines Off
OnExit, Main_cleanup
SetBatchLines, -1
SetTitleMatchMode, 3
SetTitleMatchMode, fast
#NoEnv
#NoTrayIcon
#SingleInstance force

; pseudo main function
  Suspend, On
  Main_init()
  Config_init()
  Gui_init()
  Gui_resize()
  If Not FileExist(A_WorkingDir "\cache")
    FileCreateDir, %A_WorkingDir%\cache
  Loop, % Config_feedCount {
    SB_SetText("Loading feed (" A_Index "/" Config_feedCount "): """ Config_feed#%A_Index%_title """ ...")
    Feed_init(A_Index)
    Gui_initFeed(A_Index)
  }
  SB_SetText("Loading summary of new entries ...")
  Feed_init(Config_feedCount + 1)
  Gui_loadEntryList(Config_feedCount + 1)
  SB_SetText("")
  Suspend, Off
  If Config_autoReload {
    Main_reloadFeeds()
    If Config_reloadTime
      SetTimer, Main_reloadFeeds, %Config_reloadTime%
  } Else
    Gui_navigate(0)
Return         ; end of the auto-execute section

;; Function & label definitions
Main_init() {
  Global Main_docDir

  Main_docDir := A_ScriptDir
  If (SubStr(A_ScriptDir, -3) = "\src")
    Main_docDir .= "\.."
  Main_docDir .= "\doc"
}

Main_cleanup:
  SB_SetText("Saving feed status ...")
  Loop, % Config_feedCount {
    Feed_cleanup(A_Index)
    Feed_save(A_Index)
  }
  SB_SetText("Cleaning up cache ...")
  FileDelete, %A_WorkingDir%\cache\*.tmp.xml
  Loop, %A_WorkingDir%\cache\*, 2, 0
    FileDelete, %A_LoopFileFullPath%\*.tmp.htm
  Gui_cleanup()
ExitApp

Main_download() {
  Local e, f

  If (Gui_a = 1) {
    GuiControlGet, Gui_aF, , Gui#2
    MsgBox, 8225, %NAME% %VERSION% - Download articles, % "Download all articles from """ Config_feed#%Gui_aF%_title """?"
    IfMsgBox OK
      Loop, % Feed#%Gui_aF%_eCount {
        If (Gui_aF = Config_feedCount + 1) {
          f := Feed#%Gui_aF%_e#%A_Index%_f
          e := Feed#%Gui_aF%_e#%A_Index%_e
        } Else {
          f := Gui_aF
          e := Gui_aE
        }
        SB_SetText("Downloading article " e "/" Feed#%f%_eCount " from """ Config_feed#%f%_title """ ...")
        Feed_downloadArticle(f, e)
      }
  } Else {
    If (Gui_a = 2)
      GuiControlGet, Gui_aE, , Gui#2
    If (Gui_aF = Config_feedCount + 1) {
      f := Feed#%Gui_aF%_e#%Gui_aE%_f
      e := Feed#%Gui_aF%_e#%Gui_aE%_e
    } Else {
      f := Gui_aF
      e := Gui_aE
    }
    SB_SetText("Downloading article " e " from """ Config_feed#%f%_title """ ...")
    Feed_downloadArticle(f, e)
  }
  SB_SetText("")
}

Main_importFeedList() {
  Global Gui_a

  If (Gui_a < 2) {
    Config_importFeedList()
    If Not Gui_a
      Gui_navigate(-1)
    Else
      Gui_navigate(0)
  }
}

Main_markEntry(f, e, flag) {
  Local pos, replace, search

  Feed#%f%_e#%e%_flag := flag

  search  := "|" SubStr(Gui_eCountStr1 e, -StrLen(Config_maxItems) + 1)
  pos     := InStr(Gui_f#%f%_eLs, search)
  replace := SubStr(Gui_f#%f%_eLs, 1, pos + StrLen(Config_maxItems) + 2)
  replace .= SubStr(Gui_eCountStr1 flag, -StrLen(Config_maxItems) + 1)
  replace .= SubStr(Gui_f#%f%_eLs, pos + 2 * StrLen(Config_maxItems) + 3)
  Gui_f#%f%_eLs := replace
}

Main_markEntryRead() {
  Local f

  If (Feed#%Gui_aF%_e#%Gui_aE%_flag = "N") {
    Feed#%Gui_aF%_unreadECount -= 1
    Main_markEntry(Gui_aF, Gui_aE, " ")
    If (Gui_aF = Config_feedCount + 1) {
      f := Feed#%Gui_aF%_e#%Gui_aE%_f
      Feed#%f%_unreadECount -= 1
      Main_markEntry(f, Feed#%Gui_aF%_e#%Gui_aE%_e, " ")
    }
  }
}

Main_markFeedRead() {
  Local e, f

  If (Gui_a = 2) {
    GuiControlGet, Gui_aE, , Gui#2

    Loop, % Feed#%Gui_aF%_eCount
      If (Feed#%Gui_aF%_e#%A_Index%_flag = "N") {
        Feed#%Gui_aF%_e#%A_Index%_flag := " "
        If (Gui_aF = Config_feedCount + 1) {
          f := Feed#%Gui_aF%_e#%A_Index%_f
          e := Feed#%Gui_aF%_e#%A_Index%_e
          Feed#%f%_e#%e%_flag := " "
        }
      }
    Feed#%Gui_aF%_unreadECount := 0
    If (Gui_aF = Config_feedCount + 1)
      Loop, % Config_feedCount {
        Feed#%A_Index%_unreadECount := 0
        Gui_loadEntryList(A_Index)
      }

    Gui_loadEntryList(Gui_aF)
    GuiControl, , Gui#1, % SubStr(Gui_eCountStr1 Feed#%Gui_aF%_eCount, -StrLen(Config_maxItems) + 1) "  " SubStr(Gui_eCountStr1 Feed#%Gui_aF%_unreadECount, -StrLen(Config_maxItems) + 1) "  " Config_feed#%Gui_aF%_title
    GuiControl, , Gui#2, % Gui_f#%Gui_aF%_eLs
    GuiControl, Choose, Gui#2, % Gui_aE
  }
}

Main_reloadFeed() {
  Global

  If (Gui_a = 1) {
    Suspend, On
    GuiControlGet, Gui_aF, , Gui#2
    If (Gui_aF = Config_feedCount + 1)
      Main_reloadFeeds()
    Else {
      SB_SetText("Reloading feed (" Gui_aF "/" Config_feedCount "): """ Config_feed#%Gui_aF%_title """ ...")
      If Feed_reload(Gui_aF)
        Gui_loadEntryList(Gui_aF)
      SB_SetText("")
      Gui_navigate(0)
    }
    Suspend, Off
  }
}

Main_reloadFeeds:
  Main_reloadFeeds(1)
Return

Main_reloadFeeds(flag = 0) {
  Global

  If (Gui_a = 1) Or flag {
    Suspend, On
    Loop, % Config_feedCount {
      SB_SetText("Reloading feed (" A_Index "/" Config_feedCount "): """ Config_feed#%A_Index%_title """ ...")
      If Not Config_feed#%A_Index%_singleReloadOnly
        If Feed_reload(A_Index) {
          Gui_loadEntryList(A_Index)
          If (Gui_a = 1) Or (Gui_a = 2 And Gui_aF = A_Index)
            Gui_navigate(0)
        }
    }
    SB_SetText("")
    If (Gui_a = 1)
      Gui_navigate(0)
    Suspend, Off
  }
}

Main_toggleDeleteMark() {
  Local e, f

  If (Gui_a > 1) {
    If (Gui_a = 2)
      GuiControlGet, Gui_aE, , Gui#2
    If (Gui_aF = Config_feedCount + 1) {
      f := Feed#%Gui_aF%_e#%Gui_aE%_f
      e := Feed#%Gui_aF%_e#%Gui_aE%_e
    } Else {
      f := Gui_aF
      e := Gui_aE
    }
    If InStr(Feed#%f%_delete, ";" e ";") {
      StringReplace, Feed#%f%_delete, Feed#%f%_delete, %e%`;,
      Main_markEntry(f, e, " ")
      If (Gui_aF = Config_feedCount + 1)
        Main_markEntry(Gui_aF, Gui_aE, " ")
    } Else {
      If (Feed#%f%_e#%e%_flag = "N")
        Feed#%f%_unreadECount -= 1
      Feed#%f%_delete .= e ";"
      Main_markEntry(f, e, "D")
      If (Gui_aF = Config_feedCount + 1)
        Main_markEntry(Gui_aF, Gui_aE, "D")
    }
    GuiControl, , Gui#2, % Gui_f#%Gui_aF%_eLs
    GuiControl, Choose, Gui#2, % Gui_aE
  }
}

Main_toggleUnreadMark() {
  Local f

  If (Gui_a > 1) {
    If (Gui_a = 2)
      GuiControlGet, Gui_aE, , Gui#2
    If (Feed#%Gui_aF%_e#%Gui_aE%_flag = " ") {
      Feed#%Gui_aF%_unreadECount += 1
      Main_markEntry(Gui_aF, Gui_aE, "N")
      If (Gui_aF = Config_feedCount + 1) {
        f := Feed#%Gui_aF%_e#%Gui_aE%_f
        Feed#%f%_unreadECount += 1
        Main_markEntry(f, Feed#%Gui_aF%_e#%Gui_aE%_e, "N")
      }
    } Else
      Main_markEntryRead()

    Gui_loadEntryList(Gui_aF)
    If (Gui_a = 2) {
      GuiControl, , Gui#1, % SubStr(Gui_eCountStr1 Feed#%Gui_aF%_eCount, -StrLen(Config_maxItems) + 1) "  " SubStr(Gui_eCountStr1 Feed#%Gui_aF%_unreadECount, -StrLen(Config_maxItems) + 1) "  " Config_feed#%Gui_aF%_title
      GuiControl, , Gui#2, % Gui_f#%Gui_aF%_eLs
      GuiControl, Choose, Gui#2, % Gui_aE
    }
  }
}

#Include Config.ahk
#Include Feed.ahk
#Include Gui.ahk
