# ##########################################################################################
# Project: Time Card OS Production
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

# Ensure constrs_golden fileset exists
if {[string equal [get_filesets -quiet constrs_golden] ""]} {
    puts "Creating constrs_golden fileset..."
    create_fileset -constrset constrs_golden
    set obj [get_filesets constrs_golden]
    
    # Add constraint files
    set file "$ScriptFolder/Constraints/PinoutConstraint.xdc"
    if {[file exists $file]} {
        add_files -norecurse -fileset $obj $file
        set file_obj [get_files -of_objects [get_filesets constrs_golden] [list "*PinoutConstraint.xdc"]]
        set_property "file_type" "XDC" $file_obj
    }
    
    set file "$ScriptFolder/Constraints/TimingConstraint.sdc"
    if {[file exists $file]} {
        add_files -norecurse -fileset $obj $file
        set file_obj [get_files -of_objects [get_filesets constrs_golden] [list "*TimingConstraint.sdc"]]
        set_property "file_type" "SDC" $file_obj
        set_property used_in_synthesis false $file_obj
    }
    
    set file "$ScriptFolder/Constraints/GoldenImageConstraint.xdc"
    if {[file exists $file]} {
        add_files -norecurse -fileset $obj $file
        set file_obj [get_files -of_objects [get_filesets constrs_golden] [list "*GoldenImageConstraint.xdc"]]
        set_property "file_type" "XDC" $file_obj
    }
    
    set_property "target_constrs_file" "$ScriptFolder/Constraints/PinoutConstraint.xdc" $obj
}

# Get Vivado version for flow names
set VivadoVersion [lindex [split [version -short] "."] 0]
set Synthesis_Flow "Vivado Synthesis $VivadoVersion"
set Implementation_Flow "Vivado Implementation $VivadoVersion"

# Create 'synth_golden' run if not found
if {[string equal [get_runs -quiet synth_golden] ""]} {
    puts "Creating synth_golden run..."
    create_run -name synth_golden -part xc7a100tfgg484-1 -flow $Synthesis_Flow -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_golden
} else {
    set_property strategy "Vivado Synthesis Defaults" [get_runs synth_golden]
    set_property flow $Synthesis_Flow [get_runs synth_golden]
}
set obj [get_runs synth_golden]
set_property -name "strategy" -value "Vivado Synthesis Defaults" -objects $obj
set_property -name "steps.synth_design.args.more options" -value "-generic GoldenImage_Gen=true" -objects $obj

# Create 'impl_golden' run if not found
if {[string equal [get_runs -quiet impl_golden] ""]} {
    puts "Creating impl_golden run..."
    create_run -name impl_golden -part xc7a100tfgg484-1 -flow $Implementation_Flow -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_golden -parent_run synth_golden
} else {
    set_property strategy "Vivado Implementation Defaults" [get_runs impl_golden]
    set_property flow $Implementation_Flow [get_runs impl_golden]
}
set obj [get_runs impl_golden]
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.BIN_FILE" -value "1" -objects $obj

# current time
set SystemTime [clock seconds]

# set the current synth run
current_run -synthesis [get_runs synth_golden]
# set the current impl run
current_run -implementation [get_runs impl_golden]

# run synthese
reset_run synth_golden
launch_runs synth_golden -jobs 8
wait_on_run synth_golden

# run implementation and bitstream
reset_run impl_golden
launch_runs impl_golden -to_step write_bitstream -jobs 8
wait_on_run impl_golden

set TimestampDate [clock format $SystemTime -format %Y_%m_%d]
set TimestampTime [clock format $SystemTime -format %H_%M_%S]
set Timestamp "$TimestampDate $TimestampTime Golden"
set BinaryFolder "$ScriptFolder/Binaries/$Timestamp"

file mkdir $BinaryFolder

# date specific
file copy -force $ScriptFolder/TimeCard/TimeCard.runs/impl_golden/TimeCardTop.bit $BinaryFolder/Golden_TimeCardOS_Production.bit
file copy -force $ScriptFolder/TimeCard/TimeCard.runs/impl_golden/TimeCardTop.bin $BinaryFolder/Golden_TimeCardOS_Production.bin
write_hwdef -force -file $BinaryFolder/Golden_TimeCardOS_Production.hdf

# latest always here
file copy -force $ScriptFolder/TimeCard/TimeCard.runs/impl_golden/TimeCardTop.bit $ScriptFolder/Binaries/Golden_TimeCardOS_Production.bit
file copy -force $ScriptFolder/TimeCard/TimeCard.runs/impl_golden/TimeCardTop.bin $ScriptFolder/Binaries/Golden_TimeCardOS_Production.bin
write_hwdef -force -file $ScriptFolder/Binaries/Golden_TimeCardOS_Production.hdf