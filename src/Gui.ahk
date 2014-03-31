/* Title:   owl-u -- Feed Reader
   Version: 0.4.0
   Author:  joten
   License: GNU General Public License version 3 (GPLv3)
*/

/* Gui#1: Title bar ==================================================================================================================
   Gui#2: ListBox containing either the configured feeds or the entries of the selected feed
   Gui#3: Embedded Internet Explorer showing the quick help, the summary (abstract) or the link target (article) of the selected entry
   Gui#4: Status bar =================================================================================================================
*/

Gui_init() {
  Global Config_iniFilePath, Config_reloadTime, Config_windowHeight, Config_windowWidth
  Global Gui_a, Gui_aF, Gui_barH, Gui_inA, Gui_statusBarH, Gui_wndHidden

  ;; Tray icon
  IfExist %A_ScriptDir%\icon.ico
    Menu, Tray, Icon, %A_ScriptDir%\icon.ico
  If Config_reloadTime
    GUI_createTrayIcon()

  ;; Main window
  Gui_wndHidden := False
  If FileExist(Config_iniFilePath)
    Gui_a := 1
  Else
    Gui_a := 0
  Gui_inA := 1
  Gui_aF  := 1

  GUI_createLoadingPage()
  GUI_getElementSize()
  GUI_createMainWindow(Config_windowWidth - 4, Config_windowHeight - Gui_barH - Gui_statusBarH)
}

Gui_initFeed(i) {
  Global

  Gui_f#%i%_htmlSource := Config_feed#%i%_htmlSource
}

Gui_cleanup() {
  Gui, Destroy
}

GuiClose:
  ExitApp
Return

GUI_convertHtmlToText(s) {
  s := RegExReplace(s, "<form.+?</form>")
  s := RegExReplace(s, "<iframe.+?</iframe>")
  s := RegExReplace(s, "<object.+?</object>")
  s := RegExReplace(s, "<script.+?</script>")
  s := RegExReplace(s, "<style.+?</style>")

  s := RegExReplace(s, "</?div[^>]*>")
  s := RegExReplace(s, "<img [^>]+>")
  s := RegExReplace(s, "<!--.+?-->")
  s := RegExReplace(s, "<a [^>]+>[\r\s]*</a>")
  s := RegExReplace(s, "<noscript>[\r\s]*</noscript>")
  s := RegExReplace(s, "<li [^>]+>[\r\s]*</li>")
  s := RegExReplace(s, "<ul [^>]+>[\r\s]*</ul>")
  s := "<div class=""fixed-width"">" s "</div>"

  Return, s
}

Gui_createHtAbstract() {
  Local body, ht

  ht := Config_htmlTemplate
  body := "<table>`n"
  body .= "<tr><th class=""abstract"">Title</th><td>" List_getItemField("Feed", Gui_aF, Gui_aE, "title") "</td></tr>`n"
  body .= "<tr><th class=""abstract"">Date</th><td>" List_getItemField("Feed", Gui_aF, Gui_aE, "updated") "</td></tr>`n"
  body .= "<tr><th class=""abstract"">Link</th><td>" List_getItemField("Feed", Gui_aF, Gui_aE, "link") "</td></tr>`n"
  If List_getItemField("Feed", Gui_aF, Gui_aE, "author")
    body .= "<tr><th class=""abstract"">From</th><td>" List_getItemField("Feed", Gui_aF, Gui_aE, "author") "</td></tr>`n"
  body .= "</table>`n`n"
  body .= "<p><div class=""fixed-width"">`n`t" List_getItemField("Feed", Gui_aF, Gui_aE, "summary") "</div></p>`n"

  StringReplace, ht, ht, <!-- charset -->, utf-8
  StringReplace, ht, ht, <!-- body -->, %body%
  FileDelete, % Feed_cacheDir "\abstract.tmp.htm"
  FileAppend, %ht%, % Feed_cacheDir "\abstract.tmp.htm"
}

Gui_createHtArticle() {
  Local body, charset, e, f, filename, ht

  Main_getFeedEntryIndices(Gui_aE, f, e)
  If Gui_f#%f%_htmlSource {
    filename := Feed_getHtmlFile(f, e)
    FileRead, ht, %filename%
    StringReplace, ht, ht, `r`n, , All
    StringReplace, ht, ht, `n, , All
    If (Gui_f#%f%_htmlSource = "body" Or Gui_f#%f%_htmlSource = "text") {
      charset := GUI_getHtmlCharset(ht)
      body := RegExReplace(ht, ".*<body.*?>(.*)</body>.*", "$1")
      Loop, % Config_feed#%f%_needleRegExCount
        body := RegExReplace(body, Config_feed#%f%_needleRegEx#%A_Index%, Config_feed#%f%_replacement#%A_Index%)
      If (Gui_f#%f%_htmlSource = "text")
        body := GUI_convertHtmlToText(body)
      ht := Config_htmlTemplate
      StringReplace, ht, ht, <!-- body -->, %body%
      StringReplace, ht, ht, <!-- charset -->, %charset%
    } Else
      Loop, % Config_feed#%f%_needleRegExCount
        ht := RegExReplace(ht, Config_feed#%f%_needleRegEx#%A_Index%, Config_feed#%f%_replacement#%A_Index%)
    FileDelete, % Feed_cacheDir "\article.tmp.htm"
    FileAppend, %ht%, % Feed_cacheDir "\article.tmp.htm"

    Return, Feed_cacheDir "\article.tmp.htm"
  } Else
    Return, List_getItemField("Feed", f, e, "link")
}

GUI_createLoadingPage() {
  Global Config_htmlTemplate, Feed_cacheDir

  ht := Config_htmlTemplate
  StringReplace, ht, ht, <!-- charset -->, utf-8
  StringReplace, ht, ht, <!-- body -->, <p id="loading">loading ...</p>
  FileDelete, % Feed_cacheDir "\loading.tmp.htm"
  FileAppend, %ht%, % Feed_cacheDir "\loading.tmp.htm"
}

GUI_createMainWindow(w, h) {
  Global Config_feedCount, Config_fontName, Config_fontSize, Config_windowWidth, Main_docDir, NAME
  Global Gui#1, Gui#2, Gui#3, Gui#4, Gui_a, Gui_barH, GUI_Feed_#1, GUI_Feed_#2, Gui_wndId

  Gui, 1: Default
  IfWinExist, %NAME%
    Gui, Destroy
  Gui, +LastFound +0xCF0000 -0x80000000
  Gui, Font, s%Config_fontSize%, %Config_fontName%
  Gui_wndId := WinExist()
  n := Config_feedCount + 1

  Gui, Add, Text, W%w% H%h% X4 Y0 vGui#1,
  If Not Gui_a {
;    Gui, Add, ListBox, +0x100 AltSubmit Disabled Hidden W%Config_windowWidth% H%h% X0 Y%Gui_barH% vGui#2, |
    Gui, Add, ListView, Disabled Hidden Count%n% -Multi W%Config_windowWidth% H%h% X0 Y%Gui_barH% vGUI_Feed_#1, #|Unseen|Total|Title
    LV_ModifyCol(1, "Integer Right")
    LV_ModifyCol(2, "Integer Right")
    LV_ModifyCol(3, "Integer Right")
    Gui, Add, ListView, Disabled Hidden Count%Config_maxItems% -Multi W%Config_windowWidth% H%h% X0 Y%Gui_barH% vGUI_Feed_#2, #|Flag|Title
    LV_ModifyCol(1, "Integer Right")
    LV_ModifyCol(2, "Integer Right")

    Gui Add, ActiveX, x0 y%Gui_barH% w%Config_windowWidth% h%h% vGui#3, Shell.Explorer
    Gui#3.silent := True      ;; Disable annoying script errors from the page
    Gui#3.Navigate("file:///" Main_docDir "/Quick_help.htm")
  } Else {
;    Gui, Add, ListBox, +0x100 AltSubmit W%Config_windowWidth% H%h% X0 Y%Gui_barH% vGui#2, |
    Gui, Add, ListView, Count%n% -Multi W%Config_windowWidth% H%h% X0 Y%Gui_barH% vGUI_Feed_#1, #|Unseen|Total|Title
    LV_ModifyCol(1, "Integer Right")
    LV_ModifyCol(2, "Integer Right")
    LV_ModifyCol(3, "Integer Right")
    Gui, Add, ListView, Disabled Hidden Count%Config_maxItems% -Multi W%Config_windowWidth% H%h% X0 Y%Gui_barH% vGUI_Feed_#2, #|Flag|Title
    LV_ModifyCol(1, "Integer Right")
    LV_ModifyCol(2, "Integer Right")

    Gui Add, ActiveX, Disabled Hidden x0 y%Gui_barH% w%Config_windowWidth% h%h% vGui#3, Shell.Explorer
    Gui#3.silent := True      ;; Disable annoying script errors from the page
    Gui#3.Navigate("about:blank")
  }
  Gui, Add, StatusBar, vGui#4, Initializing ...

  Gui, Show, AutoSize, %NAME%
}

GUI_createTrayIcon() {
  Menu, Tray, Icon
  Menu, Tray, NoStandard
  Menu, Tray, Add, Hide/Show window, Gui_hideShowWindow
  Menu, Tray, Add, Reload feeds, Main_reloadFeeds
  Menu, Tray, Add,
  Menu, Tray, Add, Quit, Gui_exitApp
  Menu, Tray, Default, Hide/Show window
}

Gui_exitApp:
  ExitApp
Return

GUI_getElementSize() {
  Global Config_fontName, Config_fontSize
  Global Gui_bar, Gui_barH, Gui_statusBar, Gui_statusBarH

  wndTitle := "owl-u_GUI_99"
  Gui, 99: Default
  Gui, Font, s%Config_fontSize%, %Config_fontName%
  Gui, Add, Text, x0 y0 vGui_bar, |
  GuiControlGet, Gui_bar, Pos
  Gui, Add, StatusBar, x0 y0 vGui_statusBar, |
  GuiControlGet, Gui_statusBar, Pos
  Gui, Destroy
  Gui, 1: Default
}

GUI_getHtmlCharset(s) {
  p := InStr(s, "charset=", False, InStr(s, "http-equiv=""Content-Type"""))
  If p
    charset := SubStr(s, p + 8, InStr(s, """", False, p + 8) - (p + 8))
  If Not charset
    charset := "utf-8"

  Return, charset
}

GUI_getSelectedItem() {
  Global Gui_aE, GUI_Feed_#2

  Gui, ListView, GUI_Feed_#2
  LV_GetText(Gui_aE, LV_GetNext())
  Gui_aE += 0
  If (Gui_aE = 0)
    Gui_aE := 1
}

GUI_getSelectedList() {
  Global Gui_aF, GUI_Feed_#1

  Gui, ListView, GUI_Feed_#1
  LV_GetText(Gui_aF, LV_GetNext())
  Gui_aF += 0
  If (Gui_aF = 0)
    Gui_aF := 1
}

Gui_helpSuspendHotkeys(flag) {
  If flag {
    ; enabled: i, q, +h, ^e, ^q, ^r, ^w
    Hotkey, BackSpace, Off
    Hotkey, d, Off
    Hotkey, Enter, Off
    Hotkey, h, Off
    Hotkey, n, Off
    Hotkey, o, Off
    Hotkey, p, Off
    Hotkey, r, Off
    Hotkey, u, Off
    Hotkey, 0, Off
    Hotkey, +a, Off
    Hotkey, +d, Off
    Hotkey, +r, Off
    Hotkey, ^u, Off
  } Else {
    Hotkey, BackSpace, On
    Hotkey, d, On
    Hotkey, Enter, On
    Hotkey, h, On
    Hotkey, n, On
    Hotkey, o, On
    Hotkey, p, On
    Hotkey, r, On
    Hotkey, u, On
    Hotkey, 0, On
    Hotkey, +a, On
    Hotkey, +d, On
    Hotkey, +r, On
    Hotkey, ^u, On
  }
}

Gui_hideShowWindow:
  If Not Gui_wndHidden
    WinHide, ahk_id %Gui_wndId%
  Else
    WinShow, ahk_id %Gui_wndId%
  Gui_wndHidden := Not Gui_wndHidden
Return

GUI_IE_navigate(d) {
  Local dir

  StringReplace, dir, Feed_cacheDir, \, /, All
  If (GUI_isArticleView() And d = "back" And Not Gui#3.LocationURL = List_getItemField("Feed", Gui_aF, Gui_aE, "link")) {
    If Not (Gui#3.LocationURL = "file:///" dir "/article.tmp.htm"
      Or Gui#3.LocationURL = "file:///" dir "/loading.tmp.htm"
      Or Gui#3.LocationURL = "file:///" Main_docDir "/Quick_help.htm") {
      Gui#3.GoBack()
      If (Gui#3.LocationURL = "file:///" dir "/loading.tmp.htm")
        Gui#3.GoForward()
    }
  }
}

GUI_isAbstractView() {
  Global Gui_a
  Return, (Gui_a = 3)
}

GUI_isArticleView() {
  Global Gui_a
  Return, (Gui_a = 4)
}

GUI_isHelpView() {
  Global Gui_a
  Return, (Gui_a = 0)
}

GUI_isItemView() {
  Global Gui_a
  Return, (Gui_a = 2)
}

GUI_isListView() {
  Global Gui_a
  Return, (Gui_a = 1)
}

GUI_isSummaryView() {
  Global Gui_aF, Config_feedCount
  Return, (Gui_aF = Config_feedCount + 1)
}

GUI_markEntry(f, e, flag) {
  Local pos, replace, search

  If (Gui_aF = f) {
    Gui, ListView, GUI_Feed_#2
    LV_Modify("Col2", e, flag)
  }
}

Gui_navigate(d) {
  Local dir

  If (Not GUI_isHelpView() And Not d = "h" And (Gui_a + d < 1 Or Gui_a + d > 4))
    Return
  If (d = "h")
    d := -Gui_a
  If (GUI_isArticleView() And d = -1)
    d = -2

  If d {
    If (GUI_isListView() And d > 0) {
      GUI_getSelectedList()
      If (List_getNumberOfItems("Feed", Gui_aF) < 1)
        Return
    }
    If (GUI_isListView() And d > 0)
      GUI_toggleView(1, 2)
    Else If (GUI_isListView() And Gui_a + d = 0)
      GUI_toggleView(1, 3)
    Else If (GUI_isItemView() And d > 0) Or (GUI_isItemView() And Gui_a + d = 0)
      GUI_toggleView(2, 3)
    Else If (GUI_isItemView() And d < 0)
      GUI_toggleView(2, 1)
    Else If (GUI_isHelpView() And Gui_inA = 1)
      GUI_toggleView(3, 1)
    Else If ((GUI_isAbstractView() Or GUI_isArticleView()) And (d = -1 Or d = -2)) Or (GUI_isHelpView() And Gui_inA = 2)
      GUI_toggleView(3, 2)
    If GUI_isHelpView() {
      Gui_a := Gui_inA
      Gui_helpSuspendHotkeys(0)
    } Else {
      If (Gui_a + d = 0) {
        Gui_inA := Gui_a
        Gui_helpSuspendHotkeys(1)
      }
      Gui_a += d
    }
  }

  If GUI_isListView() {
    GUI_setFeedList()
    Gui, ListView, GUI_Feed_#1
    LV_Modify(Gui_aF, "Focus Select")
    Gui_aE := 1
  } Else If GUI_isItemView() {
    If (d > 0)
      GUI_getSelectedList()
    GUI_setEntryList()
    Gui, ListView, GUI_Feed_#2
    LV_Modify(Gui_aE, "Focus Select")
  } Else If GUI_isAbstractView() {
    If (d > 0)
      GUI_getSelectedItem()
    GUI_setAbstractView()
    Main_markEntryRead()
  } Else If GUI_isArticleView() {     ;; Set the article view.
    If (SubStr(Config_feed#%Gui_aF%_xmlUrl, 1, 6) = "mua://")
      Run, % SubStr(Config_muaCommand, 1, InStr(Config_muaCommand, ".exe")) "exe"
    Else {
      StringReplace, dir, Feed_cacheDir, \, /, All
      Gui#3.Navigate("file:///" dir "/loading.tmp.htm")
      Gui#3.Navigate(Gui_createHtArticle())
    }
  } Else If GUI_isHelpView() {        ;; Set the help view.
    GuiControl, , Gui#1, % NAME " " VERSION
    Gui#3.Navigate("file:///" Main_docDir "/Quick_help.htm")
  }
}

Gui_openArticle() {
  Global

  If Not (GUI_isHelpView() Or GUI_isListView()) {
    If GUI_isItemView()
      GUI_getSelectedItem()
    Run, % Config_browser " " List_getItemField("Feed", Gui_aF, Gui_aE, "link")
  } Else If GUI_isListView() {
    GUI_getSelectedList()
    Run, % Config_browser " " Config_feed#%Gui_aF%_htmlUrl
  }
}

Gui_resize(w = 0, h = 0) {
  Global Gui#1, Gui#2, Gui#3, Gui_barH, GUI_Feed_#1, GUI_Feed_#2, Gui_statusBarH, Gui_wndId

  If (w = 0 Or h = 0) {
    Sleep, 250
    WinGetPos, x, y, w, h, ahk_id %Gui_wndId%
    h += 1
    WinMove, ahk_id %Gui_wndId%, , x, y, w, h
  } Else {
    h -= Gui_barH + Gui_statusBarH
    GuiControl, Move, Gui#2, X0 y%Gui_barH% W%w% H%h%
    GuiControl, Move, GUI_Feed_#1, X0 y%Gui_barH% W%w% H%h%
    GuiControl, Move, GUI_Feed_#2, X0 y%Gui_barH% W%w% H%h%
    GuiControl, Move, Gui#3, X0 y%Gui_barH% W%w% H%h%
    w -= 4
    GuiControl, Move, Gui#1, X4 Y0 W%w% H%Gui_barH%
  }
}

GUI_SB_getText() {
  Global Gui#4
  GuiControlGet, s, , Gui#4
  Return, s
}

GUI_setAbstractView() {
  Local dir, text

  text := Config_feed#%Gui_aF%_title " [" List_getNumberOfItems("Feed", Gui_aF) "| " Gui_aE " ]: """ List_getItemField("Feed", Gui_aF, Gui_aE, "title") """"
  StringReplace, text, text, &, &&, All
  GuiControl, , Gui#1, % text

  StringReplace, dir, Feed_cacheDir, \, /, All
  Gui_createHtAbstract()
  Gui#3.Navigate("file:///" dir "/abstract.tmp.htm")
}

GUI_setEntryList() {
  Local text, title

  text := Config_feed#%Gui_aF%_title " [" List_getNumberOfItems("Feed", Gui_aF) "| " List_getNumberOfUnseenItems("Feed", Gui_aF) " unseen ]"
  StringReplace, text, text, &, &&, All
  GuiControl, , Gui#1, % text

  Gui, ListView, GUI_Feed_#2
  GuiControl, -Redraw, GUI_Feed_#2
  LV_Delete()
  Loop, % List_getNumberOfItems("Feed", Gui_aF) {
    title := List_getItemField("Feed", Gui_aF, A_Index, "title")
    LV_Add("", A_Index, List_getItemField("Feed", Gui_aF, A_Index, "flag"), title)
  }
  GuiControl, +Redraw, GUI_Feed_#2
  LV_ModifyCol(3, "AutoHdr")
  LV_Modify(Gui_aE, "Focus Select")
}

GUI_setFeedList() {
  Local i, n = 0, u = 0

  Gui, ListView, GUI_Feed_#1
  GuiControl, -Redraw, GUI_Feed_#1
  LV_Delete()
  Loop, % Config_feedCount {
    n += List_getNumberOfItems("Feed", A_Index)
    u += List_getNumberOfUnseenItems("Feed", A_Index)
    LV_Add("", A_Index, List_getNumberOfUnseenItems("Feed", A_Index), List_getNumberOfItems("Feed", A_Index), Config_feed#%A_Index%_title)
  }
  SB_SetText("Loading summary of new entries ...")
  i := Config_feedCount + 1
  Feed_init(i)
  SB_SetText("")
  LV_Add("", i, List_getNumberOfUnseenItems("Feed", i), "", Config_feed#%i%_title)
  GuiControl, +Redraw, GUI_Feed_#1
  LV_ModifyCol(4, "AutoHdr")
  GuiControl, , Gui#1, % "Feed overview [" n "| " u " unseen ]"
;  LV_Modify(Gui_aF, "Focus Select")
}

Gui_showUnreadEntry(d) {
  Local i, text

  If Not (GUI_isHelpView() Or GUI_isListView() Or GUI_isItemView()) {
    If (List_getNumberOfUnseenItems("Feed", Gui_aF) > 0) {
      i := List_getFlaggedItem("Feed", Gui_aF, Gui_aE, d, "N")
      If (i > 0) {
        Gui_aE := i
        text := Config_feed#%Gui_aF%_title " [" List_getNumberOfItems("Feed", Gui_aF) "| " Gui_aE " ]: """ List_getItemField("Feed", Gui_aF, Gui_aE, "title") """"
        StringReplace, text, text, &, &&, All
        GuiControl, , Gui#1, % text
        Gui_navigate(0)
        Main_markEntryRead()
      } Else
        Gui_navigate(2 - Gui_a)
    } Else
      Gui_navigate(1 - Gui_a)
  }
}

GuiSize:
  Gui_resize(A_GuiWidth, A_GuiHeight)
Return

Gui_toggleSourceView() {
  Global

  If GUI_isArticleView() {
    Main_getFeedEntryIndices(Gui_aE, f, e)
    ;; "" -> "regex" -> "body" -> "text"
    If (Gui_f#%f%_htmlSource = "")
      Gui_f#%f%_htmlSource := "regex"
    Else If (Gui_f#%f%_htmlSource = "regex")
      Gui_f#%f%_htmlSource := "body"
    Else If (Gui_f#%f%_htmlSource = "body")
      Gui_f#%f%_htmlSource := "text"
    Else If (Gui_f#%f%_htmlSource = "text")
      Gui_f#%f%_htmlSource := ""
    Gui_navigate(0)
  }
}

GUI_toggleView(a, b) {
  Global

  If (a = 3) {
    GuiControl, Disable, Gui#3
    GuiControl, Hide, Gui#3
    Gui#3.Navigate("about:blank")
  } Else {
    GuiControl, Disable, GUI_Feed_#%a%
    GuiControl, Hide, GUI_Feed_#%a%
  }

  If (b = 3) {
    GuiControl, Show, Gui#3
    GuiControl, Enable, Gui#3
    GuiControl, Focus, Gui#3
    ControlFocus, Internet Explorer_Server1
  } Else {
    GuiControl, Show, GUI_Feed_#%b%
    GuiControl, Enable, GUI_Feed_#%b%
    GuiControl, Focus, GUI_Feed_#%b%
  }
}

GUI_updateView(id, i, j = 0) {
  If (id = "Feed" And j = 0) {
    Gui, ListView, GUI_Feed_#1
    LV_Modify(i, "Col2", List_getNumberOfUnseenItems(id, i))
    LV_Modify(i, "Col3", List_getNumberOfItems(id, i))
  }
}
