/* Title:   owl-u -- Feed Reader
   Version: 0.4.0
   Author:  joten
   License: GNU General Public License version 3 (GPLv3)
*/

List_changeItemFlag(id, i, j, flag) {
  %id%#%i%_e#%j%_flag := flag
}

List_deleteItem(id, i, j) {
  %id%#%i%_delete .= j ";"
  List_changeItemFlag(id, i, j, "D")
}
List_undeleteItem(id, i, j) {
  StringReplace, %id%#%i%_delete, %id%#%i%_delete, %j%`;,
  List_changeItemFlag(id, i, j, " ")
}

List_itemHasFlag(id, i, j, flag) {
  Return, (%id%#%i%_e#%j%_flag = flag)
}

List_seenItem(id, i, j) {
  %id%#%i%_unreadECount -= 1
  List_changeItemFlag(id, i, j, " ")
}
List_unseenItem(id, i, j) {
  %id%#%i%_unreadECount += 1
  List_changeItemFlag(id, i, j, "N")
}
