
FPC Sources for AROS' examples
==============================

These examples were originally written in c by The AROS Development Team and are available [here](http://www.aros.org/documentation/developers/samples.php).

Here you can find those examples, rewritten for Free Pascal and compilable
for Amiga, AROS and MorphOS (using [Trinity](https://github.com/magorium/fpc-triforce/tree/master/Base/Trinity)).

Note that these examples are copyrighted :copyright: by their respective owners.


| C                                                                                          | P   | Name                   | Category             | Description                                                                                               |
| ------------------------------------------------------------------------------------------ | --- | ---------------------- | -------------------- | --------------------------------------------------------------------------------------------------------- |
| [:link:](http://www.aros.org/documentation/developers/samplecode/helloworld.c)             | [:link:](./01_Introduction/helloworld.pas)          | helloworld             | Introduction | Prints some text to standard output                               |
| [:link:](http://www.aros.org/documentation/developers/samplecode/graphics_simple.c)        | [:link:](./02_Graphics/graphics_simple.pas)         | graphics_simple        | Graphics     | Some simple drawing functions                                     |
| [:link:](http://www.aros.org/documentation/developers/samplecode/graphics_bitmap.c)        | [:link:](./02_Graphics/graphics_bitmap.pas)         | graphics_bitmap        | Graphics     | Creates a bitmap, draws in it and blits its content to a window   |
| [:link:](http://www.aros.org/documentation/developers/samplecode/graphics_area.c)          | [:link:](./02_Graphics/graphics_area.pas)           | graphics_area          | Graphics     | Renders some shapes with the area functions                       |
| [:link:](http://www.aros.org/documentation/developers/samplecode/graphics_font.c)          | [:link:](./02_Graphics/graphics_font.pas)           | graphics_font          | Graphics     | Opens a font and writes some text                                 |
| [:link:](http://www.aros.org/documentation/developers/samplecode/intuition_events.c)       | [:link:](./03_Intuition/intuition_events.pas)       | intuition_events       | Intuition    | Event handling                                                    |
| [:link:](http://www.aros.org/documentation/developers/samplecode/intuition_refresh.c)      | [:link:](./03_Intuition/intuition_refresh.pas)      | intuition_refresh      | Intuition    | Examine difference between simplerefresh and smartrefresh windows |
| [:link:](http://www.aros.org/documentation/developers/samplecode/intuition_appscreen.c)    | [:link:](./03_Intuition/intuition_appscreen.pas)    | intuition_appscreen    | Intuition    | Opens a screen for applications                                   |
| [:link:](http://www.aros.org/documentation/developers/samplecode/intuition_customscreen.c) | [:link:](./03_Intuition/intuition_customscreen.pas) | intuition_customscreen | Intuition    | Opens a screen with a backdrop window                             |
| [:link:](http://www.aros.org/documentation/developers/samplecode/intuition_easyreq.c)      | [:link:](./03_Intuition/intuition_easyreq.pas)      | intuition_easyreq      | Intuition    | Demonstrates EasyRequesters                                       |
| [:link:](http://www.aros.org/documentation/developers/samplecode/asl.c)                    | [:link:](./04_ASL/asl_asl.pas)                      | asl_asl                | ASL          | File-, Font- and Screenmoderequester                              |
| [:link:](http://www.aros.org/documentation/developers/samplecode/dos_file.c)               | [:link:](./05_DOS/dos_file.pas)                     | dos_file               | DOS          | Reads a file and writes content to another file                   |
| [:link:](http://www.aros.org/documentation/developers/samplecode/dos_readargs.c)           | [:link:](./05_DOS/dos_readargs.pas)                 | dos_readargs           | DOS          | Command line parsing with ReadArgs()                              |
| [:link:](http://www.aros.org/documentation/developers/samplecode/dos_readargs_help.c)      | [:link:](./05_DOS/dos_readargs_help.pas)            | dos_readargs_help      | DOS          | ReadArgs() with help text                                         |
| [:link:](http://www.aros.org/documentation/developers/samplecode/icon_start.c)             | [:link:](./06_Icon/icon_start.pas)                  | icon_start             | Icon         | Reads ToolTypes from icons                                        |
| [:link:](http://www.aros.org/documentation/developers/samplecode/icon_change.c)            | [:link:](./06_Icon/icon_change.pas)                 | icon_change            | Icon         | Shows how to change ToolTypes                                     |
| [:link:](http://www.aros.org/documentation/developers/samplecode/exec_rawdofmt.c)          | [:link:](./07_Exec/exec_rawdofmt.pas)               | exec_rawdofmt          | Exec         | RawDoFmt allows printf()-like formatting                          |
