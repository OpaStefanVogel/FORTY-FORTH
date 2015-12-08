#kopiert die RAM-Inhalte aus screenlog.xml hinein in P20_FFP.vhd
#lokalisiert die RAM-Inhalte mit den in #3# {...} aufgeführten Textstellen
#werden diese Textstellen geändert, dann auch in diesem Programm ändern. 

set read_file_1 [open "P20_FFP.vhd" "r"]
set read_file_2 [open "screenlog.xml" "r"]
set write_file [open "P20_FFP_NEU.vhd" "w"]

proc kopiere { fh par1 par2 endline } {
  set line 0
  while { $line != $endline } {
    gets $fh line;
    if { $line != $endline } {
      if { $par1 == true } { puts $::write_file $line }
      }
#    puts -nonewline .
    }
  puts $line
  if { $par2 == true } { puts $::write_file $line }
  return true
  }

#3#
kopiere $read_file_1 true  true  {signal ProgRAM: RAMTYPE:=(}
puts $write_file ""
kopiere $read_file_2 false false {<DUMPZ>}
kopiere $read_file_2 false false {<DUMPZ>}
kopiere $read_file_2 false false {<DUMPZ>}
kopiere $read_file_2 true  false {</DUMPZ></ok>}
puts $write_file ""
kopiere $read_file_1 false true  {  SHA(10*16-1 downto 9*16),}
kopiere $read_file_1 true  true  {signal ByteRAM: ByteRAMTYPE:=(}
puts $write_file ""
kopiere $read_file_2 false false {<DUMPZ>}
kopiere $read_file_2 true  false {</DUMPZ></ok>}
puts $write_file ""
kopiere $read_file_1 false true  {  others=>x"00");}
kopiere $read_file_1 true  true  {shared variable stapR: stapRAMTYPE:=(}
puts $write_file ""
kopiere $read_file_2 false false {<DUMPZ>}
kopiere $read_file_2 true  false {</DUMPZ></ok>}
puts $write_file ""
kopiere $read_file_1 false true  {  others=>x"0000");}
kopiere $read_file_1 true  true  {end Step_12;}

close $read_file_1
close $read_file_2
close $write_file

file delete P20_FFP.vhd
file rename P20_FFP_NEU.vhd P20_FFP.vhd

puts ende


