/* Title:   owl-u -- Feed Reader
   Version: 0.4.0
   Author:  joten
   License: GNU General Public License version 3 (GPLv3)
*/

List_init(id, i, filename, title) {
  Local var, val

  %id%#%i%_filename := filename
  %id%#%i%_title := title

  If FileExist(filename)
    Loop, READ, %filename%
      If Not (A_LoopReadLine = "" Or SubStr(A_LoopReadLine, 1, 1) = " " Or SubStr(A_LoopReadLine, 1, 1) = ";") {
        var := SubStr(A_LoopReadLine, 1, InStr(A_LoopReadLine, "=") - 1)
        val := SubStr(A_LoopReadLine, InStr(A_LoopReadLine, "=") + 1)
        %id%#%i%_%var% := val
      }
  If Not %id%#%i%_timestamp
    %id%#%i%_timestamp := 0
  If Not List_getNumberOfItems(id, i)
    %id%#%i%_eCount := 0
  If Not List_getNumberOfUnseenItems(id, i)
    %id%#%i%_unreadECount := 0
  %id%#%i%_delete := ";"
}

List_addItem(id, i, f1, f2, f3, f4, f5, f6) {
  Local field, j

  %id%#%i%_eCount += 1
  j := %id%#%i%_eCount
  Loop, % List_%id%_itemField_#0 {
    field := List_%id%_itemField_#%A_Index%
    %id%#%i%_e#%j%_%field% := f%A_Index%
  }
  If List_itemHasFlag(id, i, j, "N")
    %id%#%i%_unreadECount += 1

  Return, j
}

List_blankMemory(id, i) {
  Local field, j

  Loop, % List_getNumberOfItems(id, i) {
    j := A_Index
    Loop, % %id%_entryField_#0 {
      field := %id%_entryField_#%A_Index%
      %id%#%i%_e#%j%_%field% := ""
    }
  }
  %id%#%i%_timestamp    := 0
  %id%#%i%_eCount       := 0
  %id%#%i%_unreadECount := 0
}

List_changeItemFlag(id, i, j, flag) {
  Global
  %id%#%i%_e#%j%_flag := flag
}

List_deleteItem(id, i, j) {
  Global
  %id%#%i%_delete .= j ";"
  List_changeItemFlag(id, i, j, "D")
}
List_undeleteItem(id, i, j) {
  Global
  StringReplace, %id%#%i%_delete, %id%#%i%_delete, %j%`;,
  List_changeItemFlag(id, i, j, " ")
}

List_getDeleted(id, i) {
  Global
  Return, %id%#%i%_delete
}
List_setDeleted(id, i, value) {
  Global
  %id%#%i%_delete := value
}

List_getFlaggedItem(id, i, j, d, flag) {
  Local k

  If (d > 0) {
    Loop, % j - 1 {
      k := j - A_Index
      If List_itemHasFlag(id, i, k, flag)
        Return, k
    }
  } Else If (d < 0) {
    Loop, % List_getNumberOfItems(id, i) - j {
      k := j + A_Index
      If List_itemHasFlag(id, i, k, flag)
        Return, k
    }
  } Else {
    Loop, % List_getNumberOfItems(id, i) {
      k := List_getNumberOfItems(id, i) - A_Index + 1
      If List_itemHasFlag(id, i, k, flag)
        Return, k
    }
  }
  Return, 0
}

List_getItemField(id, i, j, field) {
  Global
  Return, %id%#%i%_e#%j%_%field%
}
List_setItemField(id, i, j, field, value) {
  Global
  %id%#%i%_e#%j%_%field% := value
}

List_getNumberOfItems(id, i) {
  Global
  Return, %id%#%i%_eCount
}
List_setNumberOfItems(id, i, value) {
  Global
  %id%#%i%_eCount := value
}

List_getNumberOfUnseenItems(id, i) {
  Global
  Return, %id%#%i%_unreadECount
}
List_setNumberOfUnseenItems(id, i, value) {
  Global
  %id%#%i%_unreadECount := value
}

List_getTimestamp(id, i) {
  Global
  Return, %id%#%i%_timestamp
}
List_setTimestamp(id, i, value) {
  Global
  %id%#%i%_timestamp := value
}

List_itemHasFlag(id, i, j, flag) {
  Global
  Return, (%id%#%i%_e#%j%_flag = flag)
}

List_moveDeletedItems(id, i, d, m) {
  Local field, j, k

  ;; Delete `d` items and move them behind the end of the list (backwards)
  Loop, % d {
    j := m + d - A_Index + 1
    k := Config_maxItems + d - A_Index + 1
    Loop, % List_%id%_itemField_#0 {
      field := List_%id%_itemField_#%A_Index%
      %id%#%i%_e#%k%_%field% := %id%#%i%_e#%j%_%field%
    }
    List_deleteItem(id, i, k)
  }
}

List_moveNewItems(id, i, n) {
  Local field, j

  Loop, % %id%N#%i%_eCount  {
    j := A_Index
    If (j <= n) {
      Loop, % List_%id%_itemField_#0 {
        field := List_%id%_itemField_#%A_Index%
        %id%#%i%_e#%j%_%field% := %id%N#%i%_e#%j%_%field%
      }
      List_changeItemFlag(id, i, j, "N")
    }
    Loop, % List_%id%_itemField_#0 {
      field := List_%id%_itemField_#%j%
      %id%N#%i%_e#%j%_%field% := ""
    }
  }
}

List_moveOldItems(id, i, m, n){
  Local field, j, k, u = 0

  ;; Move the existing items to the end (behind the new items) of the list (backwards)
  Loop, % m {
    j := m - A_Index + 1
    k := n + m - A_Index + 1
    Loop, % List_%id%_itemField_#0 {
      field := List_%id%_itemField_#%A_Index%
      %id%#%i%_e#%k%_%field% := %id%#%i%_e#%j%_%field%
      If (field = "flag" And List_itemHasFlag(id, i, k, "N"))
        u += 1
    }
  }

  Return, u
}

List_removeItem(id, i, j) {
  Local field, p, q

  ;; Move all items with a higher index than `j` down by 1
  If (j > 0 And j <= List_getNumberOfItems(id, i)) {
    Loop, % List_getNumberOfItems(id, i) - j {
      p := j + A_Index
      q := p - 1
      Loop, % List_%id%_itemField_#0 {
        field := List_%id%_itemField_#%A_Index%
        %id%#%i%_e#%q%_%field% := %id%#%i%_e#%p%_%field%
      }
    }
    j := -1
  }

  ;; Remove the last item of the list
  If (j = -1) {
    j := List_getNumberOfItems(id, i)
    Loop, % List_%id%_itemField_#0 {
      field := List_%id%_itemField_#%A_Index%
      %id%#%i%_e#%j%_%field% := ""
    }
    %id%#%i%_eCount -= 1
  }
}

List_save(id, i) {
  Local field, j, text

  text := ";; " NAME " " VERSION " -- " %id%#%i%_title " (" A_DD "." A_MM "." A_YYYY ")`n`n"
  text .= "timestamp=" %id%#%i%_timestamp "`n"
  text .= "eCount=" List_getNumberOfItems(id, i) "`n"
  text .= "unreadECount=" List_getNumberOfUnseenItems(id, i) "`n"
  Loop, % List_getNumberOfItems(id, i) {
    j := A_Index
    text .= "`n"
    Loop, % List_%id%_itemField_#0 {
      field := List_%id%_itemField_#%A_Index%
      If (field = "summary") {
        StringReplace, %id%#%i%_e#%j%_%field%, %id%#%i%_e#%j%_%field%, `r`n, <br/>, All
        StringReplace, %id%#%i%_e#%j%_%field%, %id%#%i%_e#%j%_%field%, `n, <br/>, All
        StringReplace, %id%#%i%_e#%j%_%field%, %id%#%i%_e#%j%_%field%, `r, <br/>, All
      }
      text .= "e#" j "_" field "=" %id%#%i%_e#%j%_%field% "`n"
    }
  }

  FileDelete, % %id%#%i%_filename
  FileAppend, %text%, % %id%#%i%_filename
}

List_setItemSeen(id, i, j) {
  Global
  %id%#%i%_unreadECount -= 1
  List_changeItemFlag(id, i, j, " ")
}
List_setItemUnseen(id, i, j) {
  Global
  %id%#%i%_unreadECount += 1
  List_changeItemFlag(id, i, j, "N")
}
