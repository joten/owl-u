/* Title:   owl-u -- Feed Reader
   Version: 0.4.0
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

NAME    := "owl-u"
VERSION := "0.4.0"

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

;; Pseudo main function
  Suspend, On
  Main_dataDir = %1%
  Main_init()
  Config_init()
  Gui_init()
  Gui_resize()
  List_Feed_itemFields := "author;flag;link;summary;title;updated"
  StringSplit, List_Feed_itemField_#, List_Feed_itemFields, `;
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
  Gui_resize()
Return      ;; End of the auto-execute section

;; Function & label definitions
Main_init() {
  Global Config_iniFilePath, Feed_cacheDir, Main_dataDir, Main_docDir

  Main_docDir := A_ScriptDir
  If (SubStr(A_ScriptDir, -3) = "\src")
    Main_docDir .= "\.."
  Main_docDir .= "\doc"

  If Not Main_dataDir {
    EnvGet, winAppDataDir, APPDATA
    Main_dataDir := winAppDataDir "\owl-u"
  }
  Main_makeDir(Main_dataDir)

  Config_iniFilePath := Main_dataDir "\Config.ini"

  Feed_cacheDir := Main_dataDir "\cache"
  Main_makeDir(Feed_cacheDir)
}

Main_cleanup:
  SB_SetText("Saving feed status ...")
  Loop, % Config_feedCount {
    Feed_purgeDeleted(A_Index)
    List_save("Feed", A_Index)
  }
  ;; Feed cleanup
  SB_SetText("Cleaning up cache ...")
  FileDelete, %Feed_cacheDir%\*.tmp.htm
  FileDelete, %Feed_cacheDir%\*.tmp.xml
  Loop, %Feed_cacheDir%\*, 2, 0
    FileDelete, %A_LoopFileFullPath%\*.tmp.htm
  Gui_cleanup()
ExitApp

Main_download() {
  Local e, f

  If (Gui_a = 1) {
    GuiControlGet, Gui_aF, , Gui#2
    MsgBox, 8225, %NAME% %VERSION% -- Download articles, % "Download all articles from """ Config_feed#%Gui_aF%_title """?"
    IfMsgBox OK
      Loop, % Feed#%Gui_aF%_eCount {
        Main_getFeedEntryIndices(A_Index, f, e)
        SB_SetText("Downloading article " e "/" Feed#%f%_eCount " from """ Config_feed#%f%_title """ ...")
        Feed_downloadArticle(f, e)
      }
  } Else {
    If (Gui_a = 2)
      GuiControlGet, Gui_aE, , Gui#2
    Main_getFeedEntryIndices(Gui_aE, f, e)
    SB_SetText("Downloading article " e " from """ Config_feed#%f%_title """ ...")
    Feed_downloadArticle(f, e)
  }
  SB_SetText("")
}

Main_getFeedEntryIndices(j, ByRef f, ByRef e) {
  Global

  If (Gui_aF = Config_feedCount + 1) {
    f := Feed#%Gui_aF%_e#%j%_f
    e := Feed#%Gui_aF%_e#%j%_e
  } Else {
    f := Gui_aF
    e := Gui_aE
  }
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

Main_makeDir(dirName) {
  attrib := FileExist(dirName)
  If Not attrib {
    FileCreateDir, %dirName%
    If ErrorLevel {
      MsgBox, Error (%ErrorLevel%) when creating '%dirName%'. Aborting.
      ExitApp
    }
  } Else If Not InStr(attrib, "D") {
    MsgBox, The file path '%dirName%' already exists and is not a directory. Aborting.
    ExitApp
  }
}

Main_markEntryRead() {
  Local e, f

  If List_itemHasFlag("Feed", Gui_aF, Gui_aE, "N") {
    List_seenItem("Feed", Gui_aF, Gui_aE)
    GUI_markEntry(Gui_aF, Gui_aE, " ")
    If (Gui_aF = Config_feedCount + 1) {
      f := Feed#%Gui_aF%_e#%Gui_aE%_f
      e := Feed#%Gui_aF%_e#%Gui_aE%_e
      List_seenItem("Feed", f, e)
      GUI_markEntry(f, e, " ")
    }
  }
}

Main_markFeedRead() {
  Local e, f

  If (Gui_a = 2) {
    GuiControlGet, Gui_aE, , Gui#2

    Loop, % Feed#%Gui_aF%_eCount
      If List_itemHasFlag("Feed", Gui_aF, A_Index, "N") {
        List_seenItem("Feed", Gui_aF, A_Index)
        If (Gui_aF = Config_feedCount + 1) {
          f := Feed#%Gui_aF%_e#%A_Index%_f
          e := Feed#%Gui_aF%_e#%A_Index%_e
          List_seenItem("Feed", f, e)
        }
      }
    If (Gui_aF = Config_feedCount + 1)
      Loop, % Config_feedCount
        Gui_loadEntryList(A_Index)

    Gui_loadEntryList(Gui_aF)
    GUI_setEntryList()
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
    Main_getFeedEntryIndices(Gui_aE, f, e)
    If List_itemHasFlag("Feed", f, e, "D") {
      List_undeleteItem("Feed", f, e)
      GUI_markEntry(f, e, " ")
      If (Gui_aF = Config_feedCount + 1) {
        List_changeItemFlag("Feed", Gui_aF, Gui_aE, " ")
        GUI_markEntry(Gui_aF, Gui_aE, " ")
      }
    } Else {
      If List_itemHasFlag("Feed", f, e, "N")
        List_seenItem("Feed", f, e)
      List_deleteItem("Feed", f, e)
      GUI_markEntry(f, e, "D")
      If (Gui_aF = Config_feedCount + 1) {
        List_changeItemFlag("Feed", Gui_aF, Gui_aE, "D")
        GUI_markEntry(Gui_aF, Gui_aE, "D")
      }
    }
    GUI_setEntryList()
  }
}

Main_toggleUnreadMark() {
  Local e, f

  If (Gui_a > 1) {
    If (Gui_a = 2)
      GuiControlGet, Gui_aE, , Gui#2
    If List_itemHasFlag("Feed", Gui_aF, Gui_aE, " ") {
      List_unseenItem("Feed", Gui_aF, Gui_aE)
      GUI_markEntry(Gui_aF, Gui_aE, "N")
      If (Gui_aF = Config_feedCount + 1) {
        f := Feed#%Gui_aF%_e#%Gui_aE%_f
        e := Feed#%Gui_aF%_e#%Gui_aE%_e
        List_unseenItem("Feed", f, e)
        GUI_markEntry(f, e, "N")
      }
    } Else
      Main_markEntryRead()

    Gui_loadEntryList(Gui_aF)
    If (Gui_a = 2)
      GUI_setEntryList()
  }
}

#Include Config.ahk
#Include Feed.ahk
#Include Gui.ahk
#Include List.ahk
