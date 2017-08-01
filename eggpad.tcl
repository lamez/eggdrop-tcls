########################################################################
#          eggpad.tcl v1.0.0 - by strikelight ([sL]@EFNet)             #
#                 (for eggdrop1.1.5 to eggdrop1.6.x)                   #
########################################################################
#                                                                      #
# Contact:                                                             #
#                                                                      #
# iRC    : #Scripting @ EFNet                                          #
# Web    : http://www.TCLScript.com - for more great scripts           #
# E-Mail : strikelight@tclscript.com                                   #
#                                                                      #
########################################################################
#                                                                      #
# Description:                                                         #
#                                                                      #
# Pretty self-explanatory.  It's a text editor for eggdrop :)          #
#                                                                      #
########################################################################
#                                                                      #
# Installation:                                                        #
#                                                                      #
# - Edit the configuration below to your liking                        #
# - Place the script in your eggdrop/scripts directory                 #
# - Add the line: "source scripts/eggpad.tcl" to your eggdrop's .conf  #
# - Restart / .rehash your bot, and enjoy.                             #
#                                                                      #
########################################################################
#                                                                      #
# Usage:                                                               #
#                                                                      #
# from dcc, type .eggpad <filename> to create a new text file or to    #
# modify an existing text file.                                        #
#                                                                      #
# Refer to the help menu that appears when you do so, for more tips    #
# and commands while in edit-mode.                                     #
#                                                                      #
# from dcc, type .eggpad -send <filename> <nick> to send a created     #
# eggpad text file to you or <nick>.                                   #
#                                                                      #
# Some examples of where eggpad might be useful:                       #
# - Create tcl scripts on the fly for your bot                         #
# - Edit your bot's configuration file on the fly                      #
# - Write yourself quick memos                                         #
# - etc.. etc.. etc..                                                  #
#                                                                      #
# Special Note:                                                        #
#                                                                      #
# In regards to the special characters while editting,                 #
# if you actually want, for example "^t" in your text, and not a tab   #
# then you would use "^^t" (two carrots), and the same for the other   #
# special characters.                                                  #
#                                                                      #
########################################################################
#                                                                      #
# History:                                                             #
#                                                                      #
# v1.0.0 (04/02/02)                                                    #
# =================                                                    #
# - Initial release                                                    #
#                                                                      #
########################################################################

## CONFIGURATION ##

# Flags required to use eggpad?
set eggpad(flags) "n"

# Path to create/edit text files in? (used for security purposes)
# (You will need to create the path if it doesn't exist)
set eggpad(path) "textfiles/"


### END OF CONFIGURATION ###

set eggpad(vers) "1.0.0"

bind dcc $eggpad(flags) eggpad eggpad_dcc

proc eggpad_help {idx} {
  if {![valididx $idx]} {return}
  putidx $idx "---------------------------------------------------------"
  putidx $idx "\002Commands\002 (\037from a blank line\037):"
  putidx $idx " "
  putidx $idx "\002.a\002 = abort file                  |  \002.x\002 = exit"
  putidx $idx "\002.s\002 = save  file                  |  \002.q\002 = save + exit"
  putidx $idx "\002.v\002 = view  file                  |  \002.r\002 = replace all"
  putidx $idx "\002.l\002 = view  file w/ line numbers  |  \002.e\002 = edit a line"
  putidx $idx "\002.h\002 = help (this text)            |  \002.d\002 = delete lines"
  putidx $idx "\002.u\002 = undo last change            |  \002.i\002 = insert lines"
  putidx $idx "\002.f\002 = find text"
  putidx $idx " "
  putidx $idx "Special character-sequences while editing:"
  putidx $idx " "
  putidx $idx "\002^n\002 = blank line"
  putidx $idx "\002^s\002 = insert leading space"
  putidx $idx "\002^t\002 = insert tab"
  putidx $idx "---------------------------------------------------------"
}

proc filt {data} {
  regsub -all -- \\\\ $data \\\\\\\\ data ; regsub -all -- \\\[ $data \\\\\[ data ; regsub -all -- \\\] $data \\\\\] data
  regsub -all -- \\\} $data \\\\\} data ; regsub -all -- \\\{ $data \\\\\{ data ; regsub -all -- \\\" $data \\\\\" data ; return $data
}

proc eggpad_dcc {hand idx text} {
  global eggpad_filename eggpad_text eggpad eggpad_mode eggpad_textbackup
  global eggpad_modified
  set filename [lindex $text 0]
  if {$filename == ""} {
    putidx $idx "Usage: eggpad <filename>"
    putidx $idx "or   : eggpad -send <filename> <nick>"
    return 0
  }
  set filename [file tail $filename]
  if {[string tolower $filename] == "-send"} {
    set filename [lindex $text 1]
    set unick [lindex $text 2]
    if {($filename == "") || ($unick == "")} {
      putidx $idx "Usage: eggpad -send <filename> <nick>"
      return 0
    }
    if {![file exists $eggpad(path)${filename}]} {
      putidx $idx "Invalid file $filename"
      return 0
    }
    putidx $idx "Sending $filename to $unick"
    dccsend $eggpad(path)${filename} $unick
    return 1
  }
  putidx $idx " "
  set eggpad_filename($idx) $filename
  if {[file exists $eggpad(path)${filename}]} {
    putidx $idx "\026\002\[ eggpad: [format %47s "$filename (existing file) \]"]\026\002"
    set infile [open "$eggpad(path)${filename}" r]
    set eggpad_text($idx) ""
    while {![eof $infile]} {
      gets $infile dataline
      lappend eggpad_text($idx) $dataline
    }
    close $infile
    set eggpad_textbackup($idx) $eggpad_text($idx)
    eggpad_help $idx
    eggpad_viewmsg $idx 0 0
    putidx $idx "---------------------------------------------------------"
  } else {
    putidx $idx "\026\002\[ eggpad: [format %47s "$filename (new file) \]"]\026\002"
    set eggpad_text($idx) ""
    set eggpad_textbackup($idx) ""
    eggpad_help $idx
  }
  putidx $idx "\002You may now begin editing.\002"
  putidx $idx "---------------------------------------------------------"
  set eggpad_modified($idx) 0
  set eggpad_mode($idx) "edit"
  control $idx eggpad_control
  return 1
}

proc eggpad_viewmsg {idx {linenumbers 0} {headers 1}} {
  global eggpad_filename eggpad_text
  if {$headers} {
    putidx $idx "---------------------------------------------------------"
    putidx $idx "Viewing $eggpad_filename($idx)"
    putidx $idx "---------------------------------------------------------"
  }
  set i 0
  foreach line $eggpad_text($idx) {
    set dline ""
    incr i
    if {$linenumbers} {
      append dline "$i. "
    }
    append dline "$line"
    putidx $idx "$dline"
  }
  if {$headers} {
    putidx $idx "#eof# ($i lines)"
  }
}

proc eggpad_cleanup {idx} {
  global eggpad_filename eggpad_text eggpad_mode eggpad_edit eggpad_modified
  global eggpad_textbackup eggpad_delete eggpad_insert eggpad_inserttext
  catch {unset eggpad_filename($idx)}
  catch {unset eggpad_text($idx)}
  catch {unset eggpad_mode($idx)}
  catch {unset eggpad_replace($idx)}
  catch {unset eggpad_edit($idx)}
  catch {unset eggpad_textbackup($idx)}
  catch {unset eggpad_delete($idx)}
  catch {unset eggpad_insert($idx)}
  catch {unset eggpad_inserttext($idx)}
  catch {unset eggpad_modified($idx)}
  return 1
}

proc eggpad_savefile {idx} {
  global eggpad_filename eggpad_path eggpad_text eggpad
  if {[catch {set outfile [open $eggpad(path)$eggpad_filename($idx) w]}]} {
    if {![file isdirectory $eggpad(path)]} {
      putidx $idx "Error Saving File: path $eggpad(path) does not exist!"
    } else {
      putidx $idx "Unknown Error Saving File."
    }
    putidx $idx "Data not saved to file."
    catch {close $outfile}
    return 0
  }
  set i 0
  foreach line $eggpad_text($idx) {
    incr i
    if {$i == [llength $eggpad_text($idx)]} {
      puts -nonewline $outfile "$line"
    } else {
      puts $outfile "$line"
    }
  }
  close $outfile
  return 1
}

proc eggpad_control {idx input} {
  global eggpad_filename eggpad_text eggpad eggpad_mode eggpad_replace eggpad_modified
  global eggpad_edit eggpad_textbackup eggpad_delete eggpad_insert eggpad_inserttext
  if {$input == ""} {
    eggpad_cleanup $idx
    return 0
  }
  set cinput [string tolower $input]
  if {$eggpad_mode($idx) == "edit"} {
    if {$cinput == ".a"} {
      putidx $idx "file $eggpad_filename($idx) has been aborted."
      putidx $idx "(Returning you to the partyline...)"
      eggpad_cleanup $idx
      return 1
    } elseif {$cinput == ".h"} {
      eggpad_help $idx
    } elseif {$cinput == ".s"} {
      eggpad_savefile $idx
      set eggpad_modified($idx) 0
      putidx $idx "saved $eggpad_filename($idx) with [llength $eggpad_text($idx)] lines."
      putidx $idx "(Continue editing your file...)"
    } elseif {$cinput == ".v"} {
      eggpad_viewmsg $idx
      putidx $idx "(Continue editing your file...)"
    } elseif {$cinput == ".l"} {
      eggpad_viewmsg $idx 1
      putidx $idx "(Continue editing your file...)"
    } elseif {$cinput == ".x"} {
      if {$eggpad_modified($idx)} {
        putidx $idx "$eggpad_filename($idx) has changed. Save file before exitting? \[y/n\] (.c to cancel):"
        set eggpad_mode($idx) "exitquery"
      } else {
        putidx $idx "(Returning you to the partyline...)"
        eggpad_cleanup $idx
        return 1
      }
    } elseif {$cinput == ".r"} {
      putidx $idx "Enter text to replace: (.c to cancel)"
      set eggpad_mode($idx) "replace"
    } elseif {$cinput == ".f"} {
      putidx $idx "Enter text to find: (.c to cancel)"
      set eggpad_mode($idx) "find"
    } elseif {$cinput == ".e"} {
      putidx $idx "Enter line number to edit: (.c to cancel)"
      set eggpad_mode($idx) "editline"
    } elseif {$cinput == ".d"} {
      putidx $idx "Enter starting line number to delete: (.c to cancel)"
      set eggpad_mode($idx) "deletestart"
    } elseif {$cinput == ".i"} {
      putidx $idx "Enter line number to start inserting from: (.c to cancel)"
      set eggpad_mode($idx) "insert"
    } elseif {$cinput == ".u"} {
      set eggpad_modified($idx) 1
      set tmptxt $eggpad_text($idx)
      set eggpad_text($idx) $eggpad_textbackup($idx)
      set eggpad_textbackup($idx) $tmptxt
      putidx $idx "reverted content back to before last change"
      putidx $idx "(Continue editing your file...)"
    } elseif {$cinput == ".q"} {
      eggpad_savefile $idx
      putidx $idx "saved $eggpad_filename($idx) with [llength $eggpad_text($idx)] lines."
      putidx $idx "(Returning you to the partyline...)"
      eggpad_cleanup $idx
      return 1
    } else {
      set eggpad_textbackup($idx) $eggpad_text($idx)
      if {[string match "*^t*" $cinput]} {
        regsub -all "\\^\\^t" $input "!!epadtmp" input
        regsub -all "\\^t" $input "     " input
        regsub -all "!!epadtmp" $input "^t" input
      }
      if {[string match "*^s*" $cinput]} {
        regsub -all "\\^\\^s" $input "!!epadtmp" input
        regsub -all "\\^s" $input " " input
        regsub -all "!!epadtmp" $input "^s" input
      }
      if {[string match "*^n*" $cinput]} {
        if {$cinput == "^n"} {
          lappend eggpad_text($idx) " "
        } else {
          regsub -all "\\^\\^n" $input "!!epadtmp" input
          regsub -all "\\^n" $input "\n" input
          foreach line [split $input "\n"] {
            regsub -all "!!epadtmp" $line "^n" line
            lappend eggpad_text($idx) $line
          }
        }
      } else {
        lappend eggpad_text($idx) $input
      }
      set eggpad_modified($idx) 1
    }
  } elseif {$eggpad_mode($idx) == "replace"} {
    if {$cinput == ".c"} {
      catch {unset eggpad_replace($idx)}
      putidx $idx "- cancelled replace operation -"
      putidx $idx "(Continue editing your file...)"
      set eggpad_mode($idx) "edit"
    } else {
      set eggpad_replace($idx) $input
      putidx $idx "Replace with: (.c to cancel)"
      set eggpad_mode($idx) "replacewith"
    }
  } elseif {$eggpad_mode($idx) == "replacewith"} {
    if {$cinput == ".c"} {
      catch {unset eggpad_replace($idx)}
      putidx $idx "- cancelled replace operation -"
      putidx $idx "(Continue editing your file...)"
      set eggpad_mode($idx) "edit"
    } else {
      set replace [filt $eggpad_replace($idx)]
      set count 0
      set newtext ""
      foreach line $eggpad_text($idx) {
        set tcnt [regsub -all "$replace" $line "$input" nline]
        set count [expr $count + $tcnt]
        lappend newtext $nline
      }
      set eggpad_textbackup($idx) $eggpad_text($idx)
      set eggpad_text($idx) $newtext
      set eggpad_modified($idx) 1
      putidx $idx "Replaced $count matches."
      putidx $idx "(Continue editing your file...)"
      catch {unset eggpad_replace($idx)}
      set eggpad_mode($idx) "edit"
    }
  } elseif {$eggpad_mode($idx) == "find"} {
    if {$cinput == ".c"} {
      putidx $idx "- cancelled find operation -"
      putidx $idx "(Continue editing your file...)"
      set eggpad_mode($idx) "edit"
    } else {
      set fnd 0
      set linecnt 0
      putidx $idx "Search results for: $cinput"
      foreach line $eggpad_text($idx) {
        incr linecnt
        if {[string match "*[filt $cinput]*" [string tolower $line]]} {
          putidx $idx "\002$linecnt\002: $line"
          incr fnd
        }
      }
      putidx $idx "Done. $fnd matches found."
      putidx $idx "(Continue editing your file...)"
      set eggpad_mode($idx) "edit"
    }
  } elseif {$eggpad_mode($idx) == "insert"} {
    if {$cinput == ".c"} {
      putidx $idx "- cancelled insert operation -"
      putidx $idx "(Continue editing your file...)"
      set eggpad_mode($idx) "edit"
    } else {
      if {[string trim $input "0123456789"] != ""} {
        putidx $idx "Invalid input. Must be an integer value."
        putidx $idx "Enter line number to start inserting from: (.c to cancel)"
      } elseif {($input <= 0) || ($input > [llength $eggpad_text($idx)])} {
        putidx $idx "Invalid integer range.  Must be between 1 and [llength $eggpad_text($idx)]."
        putidx $idx "Enter line number to start inserting from: (.c to cancel)"
      } else {
        set eggpad_insert($idx) $input
        putidx $idx "Begin entering text to insert: (.c to cancel, .d when done)"
        set eggpad_mode($idx) "insertlines"
        set eggpad_inserttext($idx) ""
      }
    }
  } elseif {$eggpad_mode($idx) == "insertlines"} {
    if {$cinput == ".c"} {
      catch {unset eggpad_insert($idx)}
      catch {unset eggpad_inserttext($idx)}
      putidx $idx "- cancelled insert operation -"
      putidx $idx "(Continue editing your file...)"
      set eggpad_mode($idx) "edit"
    } elseif {$cinput == ".d"} {
      set eggpad_textbackup($idx) $eggpad_text($idx)
      set cnt [expr $eggpad_insert($idx) - 1]
      foreach line $eggpad_inserttext($idx) {
        set eggpad_text($idx) [linsert $eggpad_text($idx) $cnt $line]
        incr cnt
      }
      putidx $idx "inserted lines beginning at line $eggpad_insert($idx)"
      putidx $idx "(Continue editing your file...)"
      catch {unset eggpad_insert($idx)}
      catch {unset eggpad_inserttext($idx)}
      set eggpad_modified($idx) 1
      set eggpad_mode($idx) "edit"
    } else {
      lappend eggpad_inserttext($idx) $input
    }
  } elseif {$eggpad_mode($idx) == "editline"} {
    if {$cinput == ".c"} {
      putidx $idx "- cancelled edit line operation -"
      putidx $idx "(Continue editing your file...)"
      set eggpad_mode($idx) "edit"
    } else {
      if {[string trim $input "0123456789"] != ""} {
        putidx $idx "Invalid input. Must be an integer value."
        putidx $idx "Enter line number to edit: (.c to cancel)"
      } elseif {($input <= 0) || ($input > [llength $eggpad_text($idx)])} {
        putidx $idx "Invalid integer range.  Must be between 1 and [llength $eggpad_text($idx)]."
        putidx $idx "Enter line number to edit: (.c to cancel)"
      } else {
        putidx $idx "Line $input:"
        putidx $idx "[lindex $eggpad_text($idx) [expr $input - 1]]"
        putidx $idx "Please enter new line: (.c to cancel)"
        set eggpad_mode($idx) "editlinewith"
        set eggpad_edit($idx) [expr $input - 1]
      }
    }
  } elseif {$eggpad_mode($idx) == "editlinewith"} {
    if {$cinput == ".c"} {
      putidx $idx "- cancelled edit line operation -"
      putidx $idx "(Continue editing your file...)"
      catch {unset eggpad_edit($idx)}
      set eggpad_mode($idx) "edit"
    } else {
      set eggpad_textbackup($idx) $eggpad_text($idx)
      set eggpad_text($idx) [lreplace $eggpad_text($idx) $eggpad_edit($idx) $eggpad_edit($idx) $input]
      set eggpad_modified($idx) 1
      putidx $idx "changed line [expr $eggpad_edit($idx) + 1]"
      putidx $idx "(Continue editting your file...)"
      set eggpad_mode($idx) "edit"
      catch {unset eggpad_edit($idx)}
    }
  } elseif {$eggpad_mode($idx) == "deletestart"} {
    if {$cinput == ".c"} {
      putidx $idx "- cancelled delete lines operation -"
      putidx $idx "(Continue editing your file...)"
      set eggpad_mode($idx) "edit"
    } else {
      if {[string trim $input "0123456789"] != ""} {
        putidx $idx "Invalid input. Must be an integer value."
        putidx $idx "Enter starting line number to delete: (.c to cancel)"
      } elseif {($input <= 0) || ($input > [llength $eggpad_text($idx)])} {
        putidx $idx "Invalid integer range.  Must be between 1 and [llength $eggpad_text($idx)]."
        putidx $idx "Enter starting line number to delete: (.c to cancel)"
      } else {
        set eggpad_delete($idx) $input
        putidx $idx "Enter ending line number to delete: (.c to cancel)"
        set eggpad_mode($idx) "deleteend"
      }
    }
  } elseif {$eggpad_mode($idx) == "deleteend"} {
    if {$cinput == ".c"} {
      putidx $idx "- cancelled delete lines operation -"
      putidx $idx "(Continue editing your file...)"
      catch {unset eggpad_delete($idx)}
      set eggpad_mode($idx) "edit"
    } else {
      if {[string trim $input "0123456789"] != ""} {
        putidx $idx "Invalid input. Must be an integer value."
        putidx $idx "Enter ending line number to delete: (.c to cancel)"
      } elseif {($input < $eggpad_delete($idx)) || ($input > [llength $eggpad_text($idx)])} {
        putidx $idx "Invalid integer range.  Must be between $eggpad_delete($idx) and [llength $eggpad_text($idx)]."
        putidx $idx "Enter ending line number to delete: (.c to cancel)"
      } else {
        set eggpad_modified($idx) 1
        set eggpad_textbackup($idx) $eggpad_text($idx)
        set eggpad_text($idx) [lreplace $eggpad_text($idx) [expr $eggpad_delete($idx) - 1] [expr $input - 1]]
        putidx $idx "lines $eggpad_delete($idx) to $input deleted"
        putidx $idx "(Continue editing your file...)"
        catch {unset eggpad_delete($idx)}
        set eggpad_mode($idx) "edit"
      }
    }
  } elseif {$eggpad_mode($idx) == "exitquery"} {
    if {$cinput == ".c"} {
      putidx $idx "- cancelled exit operation -"
      putidx $idx "(Continue editing your file...)"
      set eggpad_mode($idx) "edit"
    } else {
      if {[string tolower $input] == "y"} {
        eggpad_savefile $idx
        putidx $idx "saved $eggpad_filename($idx) with [llength $eggpad_text($idx)] lines."
        putidx $idx "(Returning you to the partyline...)"
        eggpad_cleanup $idx
        return 1
      } elseif {[string tolower $input] == "n"} {
        putidx $idx "ignored changes to file $eggpad_filename($idx)."
        putidx $idx "(Returning you to the partyline...)"
        eggpad_cleanup $idx
        return 1
      } else {
        putidx $idx "Invalid option $input. Please enter Y or N (or .c to cancel exit):"
      }
    }
  } else {
    set eggpad_mode($idx) "edit"
  }
  return 0
}

putlog "Eggpad v$eggpad(vers) by strikelight (\[sL\]@Efnet) loaded."
