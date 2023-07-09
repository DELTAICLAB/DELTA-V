#!/usr/bin/env tclsh


# Get the directory or name and mode from command line arguments
set mode [lindex $argv 1]
set input [lindex $argv 0]


#set directory [file join $scriptDir $input]


# Check if mode is either 'core' or 'code'
if {($mode ne "core") && ($mode ne "code")} {
    puts "Error: mode should be either 'core' or 'code'."
    exit 1
}

# If mode is 'code', run Docker container and exit
if {$mode eq "code"} {


puts "============================================================================================"
puts "|  ▄▄▄▄▄▄▄▄▄▄   ▄▄▄▄▄▄▄▄▄▄▄  ▄       ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄           ▄               ▄  |"
puts "| ▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌         ▐░▌             ▐░▌ |"
puts "| ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌      ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌          ▐░▌           ▐░▌  |"
puts "| ▐░▌       ▐░▌▐░▌          ▐░▌          ▐░▌     ▐░▌       ▐░▌           ▐░▌         ▐░▌   |"
puts "| ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌          ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌ ▄▄▄▄▄▄▄▄▄▄▄▐░▌       ▐░▌    |"
puts "| ▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌          ▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌     ▐░▌     |"
puts "| ▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌          ▐░▌     ▐░█▀▀▀▀▀▀▀█░▌ ▀▀▀▀▀▀▀▀▀▀▀  ▐░▌   ▐░▌      |"
puts "| ▐░▌       ▐░▌▐░▌          ▐░▌          ▐░▌     ▐░▌       ▐░▌               ▐░▌ ▐░▌       |"
puts "| ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄ ▐░▌     ▐░▌       ▐░▌                ▐░▐░▌        |"
puts "| ▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌     ▐░▌       ▐░▌                 ▐░▌         |"
puts "|  ▀▀▀▀▀▀▀▀▀▀   ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀       ▀         ▀                   ▀          |"
puts "============================================================================================"

# Input is interpreted as a directory name in the script's directory
set scriptDir [file dirname [info script]]
set directory [file join $scriptDir $input]
if {![file isdirectory $directory]} {
    puts "Error: directory not found"
    exit 1
}

# Now let's find the files in the directory
set files [glob -nocomplain -directory $directory *.c *.h]
set mainFile ""
set functionFile ""
set headerFile ""

foreach file $files {
    set baseName [file tail $file]
    if {$baseName eq "main.c"} {
        set mainFile $baseName
    } elseif {[file extension $baseName] eq ".c"} {
        set functionFile $baseName
    } elseif {[file extension $baseName] eq ".h"} {
        set headerFile $baseName
    }
}




# Now setting pjFile with full path
if {[info exists mainFile] && [info exists functionFile] && [info exists headerFile]} {
    set pjFile [file join $directory $functionFile]
    puts "project file = ${pjFile}"
    puts "project directory= ${directory}"
} else {
    puts "One or more required files (main.c, functionname.c, functionname.h) are missing in the directory."
    exit 1
}

# The second script begins from here
# The libraryFile is the project file (pjFile)

set libraryFile $pjFile
set file_path [file split $libraryFile]
    set file_name [file rootname [lindex $file_path end]]
    set rtl_dir "${file_name}_CPU"


# Create new directory for C and H files
set c_dir [file join $rtl_dir "cfiles"]
file mkdir $c_dir

# Find C and H files in original directory
set ch_files [glob -nocomplain -directory $directory *]

# Copy C and H files to the new directory
foreach ch_file $ch_files {
    set target_file [file join $c_dir [file tail $ch_file]]
    file copy -force $ch_file $target_file
}

# Call Docker container
set dockerContainer "meyanik/deltav:release0"
set scriptInDocker "/root/deneme/other/deltav.sh"
set full_path_rtl_dir [file normalize $rtl_dir]
set volume "${full_path_rtl_dir}:/root/deneme/vhdfiles"


    set dockerOutput [exec docker run  --rm -v $volume -w /root/deneme/vhdfiles $dockerContainer --skip bash /root/deneme/other/deltav.sh $file_name $mode 2>&1 || true]
    puts $dockerOutput
    puts "Mode is 'code', exiting after running Docker container."
    exit
}




puts "============================================================================================"
puts "|  ▄▄▄▄▄▄▄▄▄▄   ▄▄▄▄▄▄▄▄▄▄▄  ▄       ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄           ▄               ▄  |"
puts "| ▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌         ▐░▌             ▐░▌ |"
puts "| ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌      ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌          ▐░▌           ▐░▌  |"
puts "| ▐░▌       ▐░▌▐░▌          ▐░▌          ▐░▌     ▐░▌       ▐░▌           ▐░▌         ▐░▌   |"
puts "| ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌          ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌ ▄▄▄▄▄▄▄▄▄▄▄▐░▌       ▐░▌    |"
puts "| ▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌          ▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌     ▐░▌     |"
puts "| ▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌          ▐░▌     ▐░█▀▀▀▀▀▀▀█░▌ ▀▀▀▀▀▀▀▀▀▀▀  ▐░▌   ▐░▌      |"
puts "| ▐░▌       ▐░▌▐░▌          ▐░▌          ▐░▌     ▐░▌       ▐░▌               ▐░▌ ▐░▌       |"
puts "| ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄ ▐░▌     ▐░▌       ▐░▌                ▐░▐░▌        |"
puts "| ▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌     ▐░▌       ▐░▌                 ▐░▌         |"
puts "|  ▀▀▀▀▀▀▀▀▀▀   ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀       ▀         ▀                   ▀          |"
puts "============================================================================================"




# Define the function to extract integer functions with two integer inputs from C library
proc extractFunctionsTwoIntInputs {libraryFile} {
    # Open the library file for reading
    set file [open $libraryFile]
    if {[catch {set data [read $file]}]} {
        puts "Error reading the library file: $libraryFile"
        close $file
        return
    }
    close $file

    # Use regular expression to find functions with two integer inputs
    set functionsTwoIntInputs {}
    set pattern {^\s*(?:unsigned\s+)?int\s+(\w+)\s*\(\s*(?:unsigned\s+)?int\s+\w+,\s*(?:unsigned\s+)?int\s+\w+\s*\)}
    set lineRegex {^.+$}

    foreach line [split $data "\n"] {
        if {[regexp $lineRegex $line]} {
            set match [regexp -inline $pattern $line]
            if {[llength $match] > 0} {
                lappend functionsTwoIntInputs [lindex $match 1]
            }
        }
    }

    return $functionsTwoIntInputs
}

# Define the function to extract function names from C library
proc extractFunctionNames {libraryFile} {
    # Open the library file for reading
    set file [open $libraryFile]
    if {[catch {set data [read $file]}]} {
        puts "Error reading the library file: $libraryFile"
        close $file
        return
    }
    close $file
    
    # Use regular expression to find function names
    set functionNames {}
    set pattern {^\s*(?:unsigned\s+)?int\s+(\w+)\s*\([^\)]*\)\s*(?:const)?\s*(?:\{)?\s*$}
    set lineRegex {^.+$}
    
    foreach line [split $data "\n"] {
        if {[regexp $lineRegex $line]} {
            set match [regexp -inline $pattern $line]
            if {[llength $match] > 0} {
                lappend functionNames [lindex $match 1]
            }
        }
    }
    
    return $functionNames
}




# Input is interpreted as a directory name in the script's directory
set scriptDir [file dirname [info script]]
set directory [file join $scriptDir $input]
if {![file isdirectory $directory]} {
    puts "Error: directory not found"
    exit 1
}

# Now let's find the files in the directory
set files [glob -nocomplain -directory $directory *.c *.h]
set mainFile ""
set functionFile ""
set headerFile ""

foreach file $files {
    set baseName [file tail $file]
    if {$baseName eq "main.c"} {
        set mainFile $baseName
    } elseif {[file extension $baseName] eq ".c"} {
        set functionFile $baseName
    } elseif {[file extension $baseName] eq ".h"} {
        set headerFile $baseName
    }
}

# Now setting pjFile with full path
if {[info exists mainFile] && [info exists functionFile] && [info exists headerFile]} {
    set pjFile [file join $directory $functionFile]
    puts "project file = ${pjFile}"
    puts "project directory= ${directory}"
} else {
    puts "One or more required files (main.c, functionname.c, functionname.h) are missing in the directory."
    exit 1
}

# The second script begins from here
# The libraryFile is the project file (pjFile)

set libraryFile $pjFile

if {$libraryFile eq ""} {
    puts "Please provide the library file as input."
    exit 1


} else {
    # Invoke the function to extract function names
    set functionNames [extractFunctionNames $libraryFile]

    # Invoke the function to extract integer functions with two integer inputs
    set functionsTwoIntInputs [extractFunctionsTwoIntInputs $libraryFile]

    # Get the C library file name
    set file_path [file split $libraryFile]
    set file_name [file rootname [lindex $file_path end]]
    set file_ext [file extension [lindex $file_path end]]

    # Project and solution settings
    set prj_name "${file_name}_project"
    set part_name "xc7a100tcsg324-1"  ;# Set this to your target FPGA part

    # Create a new project
    open_project $prj_name

    # Add the C file to the project
    add_files $libraryFile

    # Iterate over the functions with two integer inputs
    foreach functionName $functionsTwoIntInputs {
        # Create a new solution for each function
        open_solution -reset $functionName

        # Set the target part to an appropriate FPGA (change as needed)
        set_part $part_name

        # Set current function as top function
        set_top $functionName

        # Set the RTL configuration
        config_rtl -reset none

        # Set synthesis directives for combinational logic
        set_directive_pipeline -II 1 $functionName

        # Set interface to none
        set_directive_interface -mode ap_ctrl_none $functionName
        set_directive_interface -mode ap_none $functionName

        # Apply set_directive_unroll for the function
        set_directive_unroll $functionName

        # Set the latency max value to 0
        set_directive_latency -max=0 $functionName

        # Merge the loops if needed
        set_directive_loop_merge $functionName

        # Flatten the loops
        set_directive_loop_flatten $functionName

        # Synthesize design for the current function
        csynth_design

        # Export RTL design for the current function
        export_design -rtl verilog -format ip_catalog
    }

    # Close the project
    close_project

    # Get the script's path
    set script_path [file dirname [info script]]

    # Create the RTL directory
    set rtl_dir "${file_name}_CPU"
    file mkdir [file join $script_path $rtl_dir]

# Copy VHDL files to the RTL directory
foreach functionName $functionsTwoIntInputs {
    set function_dir [file join $prj_name $functionName]
    set vhdl_dir [file join $function_dir impl vhdl]
    set vhdl_files [glob -directory $vhdl_dir *.vhd]

    foreach vhdl_file $vhdl_files {
        set target_file [file join $rtl_dir [file tail $vhdl_file]]
        file copy -force $vhdl_file $target_file
    }
}



# Print completion message
puts "VHDL files copied to ${rtl_dir}"

# Create new directory for C and H files
set c_dir [file join $rtl_dir "cfiles"]
file mkdir $c_dir

# Find C and H files in original directory
set ch_files [glob -nocomplain -directory $directory *]

# Copy C and H files to the new directory
foreach ch_file $ch_files {
    set target_file [file join $c_dir [file tail $ch_file]]
    file copy -force $ch_file $target_file
}

# Print completion message
puts "C and H files copied to ${c_dir}"
}


puts "Files are ready for core generation. calling docker now !"


# Call Docker container
set libraryName $libraryFile
set dockerContainer "meyanik/deltav:release0"
set scriptInDocker "/root/deneme/other/deltav.sh"
set full_path_rtl_dir [file normalize $rtl_dir]
set volume "${full_path_rtl_dir}:/root/deneme/vhdfiles"
set dockerOutput [exec docker run  --rm -v $volume -w /root/deneme/vhdfiles $dockerContainer --skip bash /root/deneme/other/deltav.sh $file_name $mode 2>&1 || true
]
puts $dockerOutput


puts "Core is ready ! creating a vivado project for it now !"


#exec vivado -mode tcl -source deltavivado.tcl -tclargs $rtl_dir $file_name $part_name &

set deltavivado_script {
#!/usr/bin/env tclsh

# Get the command-line arguments
set rtl_dir [lindex $::argv 0]
set file_name [lindex $::argv 1]
set part_name [lindex $::argv 2]

# Create the Vivado project
set vivado_proj "${rtl_dir}_project"
create_project -force $vivado_proj [file join ${rtl_dir} ${file_name}]
# Add other files to the project
add_files -norecurse [glob [file join ${rtl_dir} ${file_name} gcu_ic *]]
add_files -norecurse [glob [file join ${rtl_dir} ${file_name} vhdl *]]

# Add simulation sources
set sim_fileset sim_2
create_fileset -sim $sim_fileset
add_files -fileset $sim_fileset -norecurse [glob -directory [file join ${rtl_dir} ${file_name} tb] *]


# Set sim_2 as active simulation source
current_fileset -sim $sim_fileset

exit

}

set script_dir [file dirname [info script]]
set temp_script [file join $script_dir "deltavivadotemp.tcl"]

set file_handle [open $temp_script w]
puts -nonewline $file_handle $deltavivado_script
close $file_handle

# Check if the file exists before running it
if {[file exists $temp_script]} {
    exec vivado -mode tcl -source [file normalize $temp_script] -tclargs $rtl_dir $file_name $part_name 
} else {
    puts "Error: $temp_script does not exist."
}

#file deletion
file delete $temp_script 

puts "everything is ready ! you can find your vivado project in ${rtl_dir} !"



