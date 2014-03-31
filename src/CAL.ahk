/* Title:   owl-u -- Feed Reader
   Version: 0.4.0
   Author:  joten
   License: GNU General Public License version 3 (GPLv3)
*/

CAL_init(i) {
  Local dirName

  dirName := SubStr(Config_CAL_#%i%_iniFile, 1, InStr(Config_CAL_#%i%_iniFile, "\", False, 0) - 1)
  If dirName
    Main_makeDir(dirName)
  List_init("CAL_", i, Config_CAL_#%i%_iniFile, Config_CAL_#%i%_title)
}

CAL_purgeDeleted(i) {
  ;; Delete items from the deletion list
  s := List_getDeleted("CAL_", i)
  StringTrimLeft, s, s, 1
  StringTrimRight, s, s, 1
  Sort, s, NRD`;
  Loop, PARSE, s, `;
    List_removeItem("CAL_", i, A_LoopField)
  List_setDeleted("CAL_", i, ";")
}
