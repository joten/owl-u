## owl-u -- Feed Reader

owl-u is a [feed reader](https://en.wikipedia.org/wiki/Feed_reader) for
Microsoft Windows. It is written in the scripting language
[AutoHotkey](http://ahkscript.org/download/).

### What it can do

* Aggregate web content like news headlines, blogs, podcasts and vlogs from
multiple web sites
* Read a feed from an `ATOM`, `RDF` or `RSS` formatted `XML` file
* Simplify the regular checking of web sites by detecting updates
* Call the Sylpheed email client checking for new emails
* Provide a single view interface
* Be completely controlled by keyboard
* Provide a background task for periodically auto-reloading all feeds
* Show a tray icon for i. a. minimizing owl-u to the tray

### Installing and running bug.n

#### Requirements

* Microsoft Windows 2000 or higher
* [AutoHotkey](http://ahkscript.org/download/) v1.1.03 or higher (if running
owl-u from source as a script)

You may either
[download the latest released version](https://github.com/joten/owl-u/releases/latest),
or
[download the current development version](https://github.com/joten/owl-u/archive/master.zip).
Either way, you will have a `zip` file including an executable (`owl-u*.exe`),
the source (`src\*`) and documentation (`doc\*`) files.

There is no installation process for owl-u. Unpack the `zip` file, and you
should be able to run either the executable as it is or the main script
(`src\Main.ahk`) with [AutoHotkey](http://ahkscript.org/download/).

By default owl-u stores the session data (configuration and cache) to the
user's APPDATA directory, e. g. `C:\Users\joten\AppData\Roaming\owl-u`.

Please see the [documentation](./doc) for more information on installing and
running, customizing and using owl-u and for a list of changes made with the
current version, in particular the changes in the user interface (configuration
variables and hotkeys).

### License

owl-u is licensed under the GNU General Public License version 3. Please see
the [LICENSE file](./LICENSE.md) for the full license text.

### Credits

owl-u and its documentation is written by joten, but some source was copied
from the AutoHotkey forum (http://www.autohotkey.com/forum). These are
explicitly marked in the source code at the end of the appropriate section.
Additionally the following listing summarizes these sources (of ideas or code):

#### Ideas or concepts

* Andreas Krennmair: [newsbeuter](http://www.newsbeuter.org)
* majkinetor: [Rss Reader v0.21](http://www.autohotkey.com/forum/topic27155.html)

#### Code snippets

* Laszlo: [Code to convert from/to UNIX timestamp](http://www.autohotkey.com/forum/topic2633.html)
* polyethene: [Date parser - convert any date format to YYYYMMDDHH24MISS](http://www.autohotkey.net/~polyethene/#dateparse)
