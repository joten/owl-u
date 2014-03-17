/* Title:   owl-u -- Feed Reader
   Version: 0.3.0
   Author:  joten
   License: GNU General Public License version 3 (GPLv3)
*/

/**
 *  Gui#1: Title bar ==================================================================================================================
 *  Gui#2: ListBox containing either the configured feeds or the entries of the selected feed
 *  Gui#3: Embedded Internet Explorer showing the quick help, the summary (abstract) or the link target (article) of the selected entry
 *  Gui#4: Status bar =================================================================================================================
 */

Gui_init() {
	Global Config_fontName, Config_fontSize, Config_feedCount, Config_iniFilePath, Config_maxItems, Config_reloadTime, Config_windowHeight, Config_windowWidth, NAME
	Global Gui#0, Gui#1, Gui#2, Gui#3, Gui#3_wndId, Gui#4
	Global Gui_a, Gui_aF, Gui_bar, Gui_barH, Gui_eCountStr0, Gui_eCountStr1, Gui_fCountStr, Gui_inA, Gui_statusBar, Gui_statusBarH, Gui_wndHidden, Gui_wndId, Gui_wndResize

	IfExist %A_ScriptDir%\images\%NAME%.ico
		Menu, Tray, Icon, %A_ScriptDir%\images\%NAME%.ico
	If Config_reloadTime {
		Menu, Tray, Icon
		Menu, Tray, NoStandard
		Menu, Tray, Add, Hide/Show window, Gui_hideShowWindow
		Menu, Tray, Add, Reload feeds, Main_reloadFeeds
		Menu, Tray, Add,
		Menu, Tray, Add, Quit, Gui_exitApp
		Menu, Tray, Default, Hide/Show window
	}
	Gui, 1: Default
	IfWinExist, %NAME%
		Gui, Destroy
	Gui, +LastFound +0xCF0000 -0x80000000
	Gui_wndHidden := False
	Gui_wndId := WinExist()
	Gui_wndResize := True

	Gui, Font, s%Config_fontSize%, %Config_fontName%

	wndTitle := "OWLU_GUI_99"
	Gui, 99: Default
	Gui, Font, s%Config_fontSize%, %Config_fontName%
	Gui, Add, Text, x0 y0 vGui_bar, |
	GuiControlGet, Gui_bar, Pos
	Gui, Add, StatusBar, x0 y0 vGui_statusBar, |
	GuiControlGet, Gui_statusBar, Pos
	Gui, Destroy
	Gui, 1: Default

	h := Config_windowHeight - Gui_barH - Gui_statusBarH
	w := Config_windowWidth - 4

	If FileExist(Config_iniFilePath)
		Gui_a := 1
	Else
		Gui_a := 0
	Gui_inA := 1
	Gui_aF  := 1
	Gui_fCountStr := ""
	Loop, % StrLen(Config_feedCount)
		Gui_fCountStr .= " "
	Gui_eCountStr0 := ""
	Loop, % StrLen(Config_maxItems * Config_feedCount)
		Gui_eCountStr0 .= " "
	Gui_eCountStr1 := ""
	Loop, % StrLen(Config_maxItems)
		Gui_eCountStr1 .= " "
	StringTrimRight, Gui_eCountStr1, Gui_eCountStr1, 1

	Gui, Add, Text, W%w% H%h% X4 Y0 vGui#1,
	If Not Gui_a {
		Gui, Add, ListBox, +0x100 AltSubmit Disabled Hidden W%Config_windowWidth% H%h% X0 Y%Gui_barH% vGui#2, |

		StringReplace, workingDir, A_WorkingDir, \, /, All
		Gui#3_wndId := Atl_AxCreateContainer(Gui_wndId, 0, Gui_barH, Config_windowWidth, h, "Shell.Explorer")
		Gui#3 := Atl_AxGetControl(Gui#3_wndId)			; get the iwebbrowser2 interface pointer
		Gui#3.silent := True							; disable annoying script errors from the page
		Gui#3.Navigate("file:///" workingDir "/html/quick_help.htm")
		; tank: COM Object Reference [AutoHotkey_L] (http://www.autohotkey.com/forum/topic61509-90.html)
	} Else {
		Gui, Add, ListBox, +0x100 AltSubmit W%Config_windowWidth% H%h% X0 Y%Gui_barH% vGui#2, |

		Gui#3_wndId := Atl_AxCreateContainer(Gui_wndId, 0, Gui_barH, Config_windowWidth, h, "Shell.Explorer")
		Gui#3 := Atl_AxGetControl(Gui#3_wndId)			; get the iwebbrowser2 interface pointer
		Gui#3.silent := True							; disable annoying script errors from the page
		Gui#3.Navigate("about:blank")
		; tank: COM Object Reference [AutoHotkey_L] (http://www.autohotkey.com/forum/topic61509-90.html)

		WinHide, % "ahk_id " Gui#3_wndId
	}
	Gui, Add, StatusBar, vGui#4, Initializing ...

	Gui, Show, AutoSize, %NAME%
}

Gui_initFeed(i) {
	Global

	Gui_f#%i%_htmlSource := Config_feed#%i%_htmlSource
	Gui_loadEntryList(i)
}

Gui_cleanup() {
	Gui, Destroy
}

GuiClose:
	ExitApp
Return

Gui_createHtAbstract() {
	Local body, ht

	FileRead, ht, % A_WorkingDir "\html\template.htm"
	body := "<table>`n"
	body .= "<tr><th class=""abstract"">Title</th><td>" Feed#%Gui_aF%_e#%Gui_aE%_title "</td></tr>`n"
	body .= "<tr><th class=""abstract"">Date</th><td>" Feed#%Gui_aF%_e#%Gui_aE%_updated "</td></tr>`n"
	body .= "<tr><th class=""abstract"">Link</th><td>" Feed#%Gui_aF%_e#%Gui_aE%_link "</td></tr>`n"
	If Feed#%Gui_aF%_e#%Gui_aE%_author
		body .= "<tr><th class=""abstract"">From</th><td>" Feed#%Gui_aF%_e#%Gui_aE%_author "</td></tr>`n"
	body .= "</table>`n`n"
	body .= "<p><div class=""fixed-width"">`n`t" Feed#%Gui_aF%_e#%Gui_aE%_summary "</div></p>`n"

	StringReplace, ht, ht, <!-- charset -->, utf-8
	StringReplace, ht, ht, <!-- body -->, %body%
	FileDelete, % A_WorkingDir "\html\abstract.tmp.htm"
	FileAppend, %ht%, % A_WorkingDir "\html\abstract.tmp.htm"
}

Gui_createHtArticle() {
	Local body, charset, e, f, filename, ht, p, url

	If (Gui_aF = Config_feedCount + 1) {
		f := Feed#%Gui_aF%_e#%Gui_aE%_f
		e := Feed#%Gui_aF%_e#%Gui_aE%_e
	} Else {
		f := Gui_aF
		e := Gui_aE
	}
	url := Feed#%f%_e#%e%_link
	filename := Feed_getCacheId(url, Config_feed#%f%_htmlUrl)
	filename := A_WorkingDir "\cache\" Config_feed#%f%_cacheId "\" filename
	If FileExist(filename ".htm")
		filename .= ".htm"
	Else {
		filename .= ".tmp.htm"
		If Not FileExist(filename)
			UrlDownloadToFile, %url%, %filename%
	}

	If Gui_f#%f%_htmlSource {
		FileRead, ht, %filename%
		StringReplace, ht, ht, `r`n, , All
		StringReplace, ht, ht, `n, , All
		If (Gui_f#%f%_htmlSource = "body" Or Gui_f#%f%_htmlSource = "text") {
			p := InStr(ht, "charset=", False, InStr(ht, "http-equiv=""Content-Type"""))
			If p
				charset := SubStr(ht, p + 8, InStr(ht, """", False, p + 8) - (p + 8))
			If Not charset
				charset := "utf-8"
			body := RegExReplace(ht, ".*<body.*?>(.*)</body>.*", "$1")
			Loop, % Config_feed#%f%_needleRegExCount
				body := RegExReplace(body, Config_feed#%f%_needleRegEx#%A_Index%, Config_feed#%f%_replacement#%A_Index%)
			If (Gui_f#%f%_htmlSource = "text") {
				body := RegExReplace(body, "<form.+?</form>")
				body := RegExReplace(body, "<iframe.+?</iframe>")
				body := RegExReplace(body, "<object.+?</object>")
				body := RegExReplace(body, "<script.+?</script>")
				body := RegExReplace(body, "<style.+?</style>")

				body := RegExReplace(body, "</?div[^>]*>")
				body := RegExReplace(body, "<img [^>]+>")
				body := RegExReplace(body, "<!--.+?-->")
				body := RegExReplace(body, "<a [^>]+>[\r\s]*</a>")
				body := RegExReplace(body, "<noscript>[\r\s]*</noscript>")
				body := RegExReplace(body, "<li [^>]+>[\r\s]*</li>")
				body := RegExReplace(body, "<ul [^>]+>[\r\s]*</ul>")
				body := "<div class=""fixed-width"">" body "</div>"
			}
			FileRead, ht, % A_WorkingDir "\html\template.htm"
			StringReplace, ht, ht, <!-- body -->, %body%
			StringReplace, ht, ht, <!-- charset -->, %charset%
		} Else
			Loop, % Config_feed#%f%_needleRegExCount
				ht := RegExReplace(ht, Config_feed#%f%_needleRegEx#%A_Index%, Config_feed#%f%_replacement#%A_Index%)
		FileDelete, % A_WorkingDir "\html\article.tmp.htm"
		FileAppend, %ht%, % A_WorkingDir "\html\article.tmp.htm"

		Return, A_WorkingDir "\html\article.tmp.htm"
	} Else
		Return, url
}

Gui_exitApp:
	ExitApp
Return

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

Gui_loadEntryList(i) {
	Local title

	Gui_f#%i%_eLs := ""
	Loop, % Feed#%i%_eCount {
		StringReplace, title, Feed#%i%_e#%A_Index%_title, |, �, All
		Gui_f#%i%_eLs .= "|" SubStr(Gui_eCountStr1 A_Index, -StrLen(Config_maxItems) + 1) "  " Gui_eCountStr1 Feed#%i%_e#%A_Index%_flag "  " title
	}
	If Not Gui_f#%i%_eLs
		Gui_f#%i%_eLs := "|"
}

Gui_navigate(d) {
	Local eCount, fLs, i, text, unreadECount, workingDir

	If Gui_wndResize {
		Gui_resize()
		Gui_wndResize := False
	}

	StringReplace, workingDir, A_WorkingDir, \, /, All
	If (Gui_a = 4 And d = "back" And Not Gui#3.LocationURL = Feed#%Gui_aF%_e#%Gui_aE%_link) {
		If Not (Gui#3.LocationURL = "file:///" workingDir "/html/article.tmp.htm"
			Or Gui#3.LocationURL = "file:///" workingDir "/html/loading.htm"
			Or Gui#3.LocationURL = "file:///" workingDir "/html/quick_help.htm") {
			Gui#3.GoBack()
			If (Gui#3.LocationURL = "file:///" workingDir "/html/loading.htm")
				Gui#3.GoForward()
			Return
		}
	}
	If (Gui_a > 0 And Not d = "h" And (Gui_a + d < 1 Or Gui_a + d > 4))
		Return
	If (d = "h")
		d := -Gui_a
	If (Gui_a = 4 And d = -1)
		d = -2

	If d {
		If (Gui_a = 1 And d > 0) {
			GuiControlGet, Gui_aF, , Gui#2
			If (Feed#%Gui_aF%_eCount < 1)
				Return
		}
		If (Gui_a = 2 And d > 0) Or ((Gui_a = 1 Or Gui_a = 2) And Gui_a + d = 0) {
			GuiControl, Disable, Gui#2
			GuiControl, Hide, Gui#2

			WinShow, % "ahk_id " Gui#3_wndId
			ControlFocus, Internet Explorer_Server1, % "ahk_id " Gui#3_wndId
		} Else If (Gui_a > 2 And (d = -1 Or d = -2)) Or (Gui_a = 0 And (Gui_inA = 1 Or Gui_inA = 2)) {
			WinHide, % "ahk_id " Gui#3_wndId
			Gui#3.Navigate("about:blank")

			GuiControl, Show, Gui#2
			GuiControl, Enable, Gui#2
			GuiControl, Focus, Gui#2
		}
		If (Gui_a = 0) {
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

	If (Gui_a = 1) {
		Loop, % Config_feedCount {
			eCount += Feed#%A_Index%_eCount
			unreadECount += Feed#%A_Index%_unreadECount
			fLs .= "|" SubStr(Gui_fCountStr A_Index, -StrLen(Config_feedCount) + 1)
			fLs .= "  [" SubStr(Gui_eCountStr0 Feed#%A_Index%_unreadECount, -StrLen(Config_maxItems * Config_feedCount) + 1)
			fLs .= "/" SubStr(Gui_eCountStr0 Feed#%A_Index%_eCount, -StrLen(Config_maxItems * Config_feedCount) + 1)
			fLs .= "]  " Config_feed#%A_Index%_title
		}
		SB_SetText("Loading summary of new entries ...")
		i := Config_feedCount + 1
		Feed_init(i)
		Gui_loadEntryList(i)
		SB_SetText("")
		fLs .= "|" SubStr(Gui_fCountStr " ", -StrLen(Config_feedCount) + 1)
		fLs .= "   " SubStr(Gui_eCountStr0 Feed#%i%_unreadECount, -StrLen(Config_maxItems * Config_feedCount) + 1)
		fLs .= " " SubStr(Gui_eCountStr0 " ", -StrLen(Config_maxItems * Config_feedCount) + 1)
		fLs .= "   " Config_feed#%i%_title
		GuiControl, , Gui#1, % SubStr(Gui_fCountStr Config_feedCount, -StrLen(Config_feedCount) + 1) "  [" SubStr(Gui_eCountStr0 unreadECount, -StrLen(Config_maxItems * Config_feedCount) + 1) "/" SubStr(Gui_eCountStr0 eCount, -StrLen(Config_maxItems * Config_feedCount) + 1) "]"
		GuiControl, , Gui#2, % fLs
		GuiControl, Choose, Gui#2, % Gui_aF
		Gui_aE := 1
	} Else If (Gui_a = 2) {
		If (d > 0)
			GuiControlGet, Gui_aF, , Gui#2
		text := SubStr(Gui_eCountStr1 Feed#%Gui_aF%_eCount, -StrLen(Config_maxItems) + 1) "  " SubStr(Gui_eCountStr1 Feed#%Gui_aF%_unreadECount, -StrLen(Config_maxItems) + 1) "  " Config_feed#%Gui_aF%_title
		StringReplace, text, text, &, &&, All
		GuiControl, , Gui#1, % text
		GuiControl, , Gui#2, % Gui_f#%Gui_aF%_eLs
		GuiControl, Choose, Gui#2, % Gui_aE
	} Else If (Gui_a = 3) {
		If (d > 0)
			GuiControlGet, Gui_aE, , Gui#2
		text := Config_feed#%Gui_aF%_title " (" Gui_aE "/" Feed#%Gui_aF%_eCount "): """ Feed#%Gui_aF%_e#%Gui_aE%_title """"
		StringReplace, text, text, &, &&, All
		GuiControl, , Gui#1, % text
		Gui_createHtAbstract()
		Gui#3.Navigate("file:///" workingDir "/html/abstract.tmp.htm")
		Main_markEntryRead()
	} Else If (Gui_a = 4) {
		If (SubStr(Config_feed#%Gui_aF%_xmlUrl, 1, 6) = "mua://")
			Run, % SubStr(Config_muaCommand, 1, InStr(Config_muaCommand, ".exe")) "exe"
		Else {
			Gui#3.Navigate("file:///" workingDir "/html/loading.htm")
			Gui#3.Navigate(Gui_createHtArticle())
		}
	} Else If (Gui_a = 0) {
		GuiControl, , Gui#1, % NAME " " VERSION
		Gui#3.Navigate("file:///" workingDir "/html/quick_help.htm")
	}
}

Gui_openArticle() {
	Global

	If (Gui_a > 1) {
		If (Gui_a = 2)
			GuiControlGet, Gui_aE, , Gui#2
		Run, % Config_browser " " Feed#%Gui_aF%_e#%Gui_aE%_link
	} Else If (Gui_a = 1) {
		GuiControlGet, Gui_aF, , Gui#2
		Run, % Config_browser " " Config_feed#%Gui_aF%_htmlUrl
	}
}

Gui_resize(w = 0, h = 0) {
	Global Gui#1, Gui#2, Gui#3, Gui#3_wndId, Gui_barH, Gui_statusBarH, Gui_wndId

	If (w = 0 Or h = 0) {
		Sleep, 250
		WinGetPos, x, y, w, h, ahk_id %Gui_wndId%
		h += 1
		WinMove, ahk_id %Gui_wndId%, , x, y, w, h
	} Else {
		h -= Gui_barH + Gui_statusBarH
		GuiControl, Move, Gui#2, X0 y%Gui_barH% W%w% H%h%
		WinMove, % "ahk_id " Gui#3_wndId, , 0, Gui_barH, w, h
		w -= 4
		GuiControl, Move, Gui#1, X4 Y0 W%w% H%Gui_barH%
	}
}

Gui_showUnreadEntry(d) {
	Local a, b, eStr, i, text

	If (Gui_a > 2) {
		If (Feed#%Gui_aF%_unreadECount > 0) {
			a := InStr(Gui_f#%Gui_aF%_eLs, "|" SubStr(Gui_eCountStr1 Gui_aE, -StrLen(Config_maxItems) + 1) "  ")
			If (d > 0) {
				eStr := SubStr(Gui_f#%Gui_aF%_eLs, 1, a)
				b := InStr(eStr, "  " Gui_eCountStr1 "N  ", False, 0)
			} Else If (d < 0) {
				eStr := SubStr(Gui_f#%Gui_aF%_eLs, a)
				b := InStr(eStr, "  " Gui_eCountStr1 "N  ")
			} Else {
				eStr := Gui_f#%Gui_aF%_eLs
				b := InStr(eStr, "  " Gui_eCountStr1 "N  ", False, 0)
			}
			If (b > 0)
				i := SubStr(eStr, b - StrLen(Config_maxItems), StrLen(Config_maxItems))

			If (i > 0) {
				Gui_aE := i + 0
				text := Config_feed#%Gui_aF%_title " (" Gui_aE "/" Feed#%Gui_aF%_eCount "): """ Feed#%Gui_aF%_e#%Gui_aE%_title """"
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

	If (Gui_a = 4) {
		If (Gui_aF = Config_feedCount + 1)
			f := Feed#%Gui_aF%_e#%Gui_aE%_f
		Else
			f := Gui_aF
		; "" -> "regex" -> "body" -> "text"
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