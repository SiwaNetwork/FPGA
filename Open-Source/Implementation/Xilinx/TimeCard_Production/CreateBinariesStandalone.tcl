# ##########################################################################################
# Project: Time Card OS Production
# Standalone version - opens project if needed
#
# Author: Thomas Schaub, NetTimeLogic GmbH
#
# License: Copyright (c) 2022, NetTimeLogic GmbH, Switzerland, <contact@nettimelogic.com>
# All rights reserved.
#
# THIS PROGRAM IS FREE SOFTWARE: YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU LESSER GENERAL PUBLIC LICENSE AS
# PUBLISHED BY THE FREE SOFTWARE FOUNDATION, VERSION 3.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# LESSER GENERAL LESSER PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU LESSER GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM. IF NOT, SEE <http://www.gnu.org/licenses/>.
#
# ##########################################################################################

set ScriptFile [file normalize [info script]]
set ScriptFolder [file dirname $ScriptFile]

cd $ScriptFolder

# Open project if not already open
set proj_name "TimeCard"
set proj_file "$ScriptFolder/$proj_name/$proj_name.xpr"

if {[current_project -quiet] == ""} {
    puts "Opening project: $proj_file"
    open_project $proj_file
} else {
    puts "Project already open: [current_project]"
}

# current time
set SystemTime [clock seconds]

# set the current synth run
current_run -synthesis [get_runs synth_1]
# set the current impl run
current_run -implementation [get_runs impl_1]

puts "Starting synthesis..."
# run synthese
reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1

if {[get_property STATUS [get_runs synth_1]] != "synth_design Complete!"} {
    puts "ERROR: Synthesis failed!"
    exit 1
}

puts "Starting implementation..."
# run implementation and bitstream
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

if {[get_property STATUS [get_runs impl_1]] != "route_design Complete!"} {
    puts "ERROR: Implementation failed!"
    exit 1
}

puts "Copying binaries..."

set TimestampDate [clock format $SystemTime -format %Y_%m_%d]
set TimestampTime [clock format $SystemTime -format %H_%M_%S]
set Timestamp "$TimestampDate $TimestampTime"
set BinaryFolder "$ScriptFolder/Binaries/$Timestamp"

file mkdir $BinaryFolder

# date specific
file copy -force $ScriptFolder/TimeCard/TimeCard.runs/impl_1/TimeCardTop.bit $BinaryFolder/TimeCardOS_Production.bit
file copy -force $ScriptFolder/TimeCard/TimeCard.runs/impl_1/TimeCardTop.bin $BinaryFolder/TimeCardOS_Production.bin
write_hwdef -force -file $BinaryFolder/TimeCardOS_Production.hdf

# latest always here
file copy -force $ScriptFolder/TimeCard/TimeCard.runs/impl_1/TimeCardTop.bit $ScriptFolder/Binaries/TimeCardOS_Production.bit
file copy -force $ScriptFolder/TimeCard/TimeCard.runs/impl_1/TimeCardTop.bin $ScriptFolder/Binaries/TimeCardOS_Production.bin
write_hwdef -force -file $ScriptFolder/Binaries/TimeCardOS_Production.hdf

# Check if Golden image exists
if {[file exists "$ScriptFolder/Binaries/Golden_TimeCardOS_Production.bit"]} {
    write_cfgmem -format BIN -interface SPIx4 -size 16 -loadbit "up 0x00000000 $ScriptFolder/Binaries/Golden_TimeCardOS_Production.bit up 0x0400000 $ScriptFolder/Binaries/TimeCardOS_Production.bit" -file $ScriptFolder/Binaries/Factory_TimeCardOS_Production.bin -force
    puts "Factory binary created: $ScriptFolder/Binaries/Factory_TimeCardOS_Production.bin"
} else {
    puts "WARNING: Golden_TimeCardOS_Production.bit not found, skipping Factory binary creation"
}

puts ""
puts "============================================"
puts "Build completed successfully!"
puts "============================================"
puts "Binaries location: $ScriptFolder/Binaries/"
puts "Timestamped backup: $BinaryFolder"
puts ""
