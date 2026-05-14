#*****************************************************************************************
# Vivado Simulation Runner
#*****************************************************************************************
# Usage: vivado -mode batch -source simulation/run_sim.tcl -tclargs <testbench_name>
# Example: vivado -mode batch -source simulation/run_sim.tcl -tclargs Tb_FpgaVersion
#*****************************************************************************************

set testbench [lindex $argv 0]
if {$testbench eq ""} {
    puts "ERROR: No testbench specified."
    puts "Usage: vivado -mode batch -source simulation/run_sim.tcl -tclargs <testbench_name>"
    exit 1
}

set project_name "sim_$testbench"
set project_dir [file dirname [info script]]
set source_dir [file normalize "$project_dir/.."]

create_project -force $project_name "$project_dir/$project_name" -part xc7a100tfgg484-1

# Set VHDL 2008
set_property target_language VHDL [current_project]
set_property default_lib work [current_project]

# Add source files
read_vhdl -library TimecardLib "$source_dir/Open-Source/Package/TimeCard_Package.vhd"
read_vhdl "$source_dir/simulation/Tb_Package.vhd"

# Add all IP cores (simplified - add only the ones needed)
# For a full simulation, all IP sources would be added here.
# The run_sim.tcl supports the three testbenches shipped with the project.

if {$testbench eq "Tb_FpgaVersion"} {
    read_vhdl "$source_dir/Open-Source/Ips/FpgaVersion/FpgaVersion.vhd"
    read_vhdl "$source_dir/simulation/FpgaVersion/Tb_FpgaVersion.vhd"
} elseif {$testbench eq "Tb_PpsGenerator"} {
    read_vhdl "$source_dir/Open-Source/Ips/PpsGenerator/PpsGenerator.vhd"
    read_vhdl "$source_dir/simulation/PpsGenerator/Tb_PpsGenerator.vhd"
} elseif {$testbench eq "Tb_SignalTimestamper"} {
    read_vhdl "$source_dir/Open-Source/Ips/SignalTimestamper/SignalTimestamper.vhd"
    read_vhdl "$source_dir/simulation/SignalTimestamper/Tb_SignalTimestamper.vhd"
} else {
    puts "ERROR: Unknown testbench '$testbench'."
    puts "Supported: Tb_FpgaVersion, Tb_PpsGenerator, Tb_SignalTimestamper"
    exit 1
}

# Run simulation
set_property top $testbench [get_filesets sim_1]
launch_simulation
run all
close_sim

puts "Simulation of $testbench completed."
