# create a function to activate a virtual machine.
# call this script, then can use gve <venv>
function gve { param($ve); . "$($env:MYGIT_DIR)/venv.$ve/bin/Activate.ps1" }
