## Installing and running owl-u

#### Requirements

* Microsoft Windows 2000 or higher
* [AutoHotkey](http://ahkscript.org/download/) v1.1.03 or higher (if running
owl-u from source as a script)

You may either
[download the last version of owl-u](https://github.com/joten/owl-u/blob/master/owl-u_0.2.0.zip)
from the repository, or
[download the current development version](https://github.com/joten/owl-u/archive/master.zip)
as the repository itself. Either way, you will have a `zip` file including an
executable (`owl-u*.exe`), the source (`src\*`) and documentation (`doc\*`)
files.

There is no installation process for owl-u. Unpack the `zip` file, and you
should be able to run either the executable as it is or the main script
(`src\Main.ahk`) with [AutoHotkey](http://ahkscript.org/download/).

You may copy owl-u anywhere you like -- at least if you have write acces
there -- e. g. `C:\Program Files\owl-u` or link it to the 'Windows Start Menu'
or the 'Windows Taskbar', for example.

By default owl-u stores the session data (configuration and cache) to the
user's APPDATA directory, e. g. `C:\Users\joten\AppData\Roaming\owl-u`.

You may redirect the owl-u data directory by setting the first argument either
of the executable or the main script (`Main.ahk`), when running owl-u, e. g.
`C:\Program Files\owl-u\owl-u.exe D:\owl-u`; but you will need to have write
access to this directory.

You can run owl-u manually, either by using the executable and starting it like
any other application, or by using the main script (`Main.ahk`) and starting it
with [AutoHotkey](http://ahkscript.org/download/).
If using the script, the working directory must be the directory, where the
file `Main.ahk` is saved; therewith owl-u can find the other script files. One
possibility, to do so, is to install AutoHotkey, open the directory, where
`Main.ahk` is saved, and execute the file.
