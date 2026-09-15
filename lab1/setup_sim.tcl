# Registers this project's testbench as the simulation top and makes the
# simulator run until $finish instead of stopping at the default 1000 ns.
#
# Run once per project, from Vivado's Tcl Console with the project open:
#     source <path to repo>/lab1/setup_sim.tcl

set proj_dir [get_property DIRECTORY [current_project]]
set tbs [glob -nocomplain $proj_dir/*.srcs/sim_1/new/tb_*.v]

if {[llength $tbs] == 0} {
    puts "No testbench found under $proj_dir/*.srcs/sim_1/new/"
} else {
    set tb     [lindex $tbs 0]
    set tbname [file rootname [file tail $tb]]

    # add it to the simulation fileset if it isn't already there
    if {[lsearch -exact [get_files -quiet -of [get_filesets sim_1]] $tb] == -1} {
        add_files -fileset sim_1 -norecurse $tb
    }

    set_property top     $tbname          [get_filesets sim_1]
    set_property top_lib xil_defaultlib   [get_filesets sim_1]
    update_compile_order -fileset sim_1

    # 'all' runs until the testbench calls $finish
    set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

    puts "Simulation top set to $tbname, runtime set to 'all'."
}
