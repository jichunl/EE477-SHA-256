##########################################################################
# Physical Library Preparation Reference Methodology <lib_db> for LEF_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# lib_db.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

echo "\n${flow_info_prefix} Running step \"lib_db\" with the following settings:\n"
echo "Parameter                           Value"
echo "-----------------------             -------------------"
echo "Configuration file:                 [getenv FLOW_CONFIG]"
echo "Library:                            $ref_lib$library_name"
echo "Use .db files as source:            $db_models"
echo "Update bias pg pins from .db file:  $update_bias_pg" 
echo "Update diode type form .db file:    $update_dio_type"

if {$db_models} {

# 2) Sanity Checks:

if { $db_models == 1 && $max_db_models == "" } {
   echo "\n${flow_info_prefix} >> Skipping the \"lib_db\" step."
   echo "                         The \$db_models set to 1 but no \$max_db_models db file specified."
   exec touch touchfiles/${library_name}.lib_db
   exit
}

##############
# 3) Annotate logic information to FRAM view from .db files:

   echo "Min timing .db files:       $min_db_models"
   echo "Nom timing .db files:       $nom_db_models"
   echo "Max timing .db files:       $max_db_models"
   echo "Other .db files:            $other_db_models"
   echo ""

   # check if the provided file lists are directories. If so, use all the .db files
   # in that directory
   if {[file isdirectory $min_db_models]} {
      set _min_db_files [string map {\n " "} [sh ls $min_db_models/*.db]]
      echo "${flow_info_prefix} Using all .db files in $min_db_models as min models."
   } else {
      set _min_db_files $min_db_models
   }

   if {[file isdirectory $max_db_models]} {
      set _max_db_files [string map {\n " "} [sh ls $max_db_models/*.db]]
      echo "${flow_info_prefix} Using all .db files in $max_db_models as max models."
   } else {
      set _max_db_files $max_db_models
   }

   if {[file isdirectory $nom_db_models]} {
      set _nom_db_files [string map {\n " "} [sh ls $nom_db_models/*.db]]
      echo "${flow_info_prefix} Using all .db files in $nom_db_models as nom models."
   } else {
      set _nom_db_files $nom_db_models
   }

   if {[file isdirectory $other_db_models]} {
      set _other_db_files [string map {\n " "} [sh ls $other_db_models/*.db]]
      echo "${flow_info_prefix} Using all .db files in $other_db_models as other models." 
   } else {
      set _other_db_files $other_db_models
   }

   set update_mw_db_options ""
   if {$update_bias_pg} {
      set option " -bias_pg"
      append update_mw_db_options $option
   }
   if {$update_dio_type} {
      set option " -update_antenna_diode_type"
      append update_mw_db_options $option
   }

     eval update_mw_port_by_db -db_file "$_max_db_files $_other_db_files" -mw_lib $ref_lib$library_name $update_mw_db_options

} else {
   echo "\n${flow_info_prefix} >> Skipping the \"lib_db\" step, No .db file usage specified."
   echo "                         No pin information is being annotated on the FRAM view."
}

exec touch touchfiles/${library_name}.lib_db
exit

################
##
### 3) Create LM views from .db files:
### The script does not create LM view by default (mark LM view creation)
##if {0} {
##  if { $db_models == 1 } {
##
##     echo "Min timing .db files:       $min_db_models"
##     echo "Nom timing .db files:       $nom_db_models"
##     echo "Max timing .db files:       $max_db_models"
##     echo "Other .db files:            $other_db_models"
##     echo ""
##
##     # check if the provided file lists are directories. If so, use all the .db files
##     # in that directory
##     if {[file isdirectory $min_db_models]} {
##        set _min_db_files [string map {\n " "} [sh ls $min_db_models/*.db]]
##        echo "${flow_info_prefix} Using all .db files in $min_db_models as min models."
##     } else {
##        set _min_db_files $min_db_models
##     }
##
##     if {[file isdirectory $max_db_models]} {
##        set _max_db_files [string map {\n " "} [sh ls $max_db_models/*.db]]
##        echo "${flow_info_prefix} Using all .db files in $max_db_models as max models."
##     } else {
##        set _max_db_files $max_db_models
##     }
##
##     if {[file isdirectory $nom_db_models]} {
##        set _nom_db_files [string map {\n " "} [sh ls $nom_db_models/*.db]]
##        echo "${flow_info_prefix} Using all .db files in $nom_db_models as nom models."
##     } else {
##        set _nom_db_files $nom_db_models
##     }
##
##     if {[file isdirectory $other_db_models]} {
##        set _other_db_files [string map {\n " "} [sh ls $other_db_models/*.db]]
##        echo "${flow_info_prefix} Using all .db files in $other_db_models as other models."
##     } else {
##        set _other_db_files $other_db_models
##     }
##
##     gePrepLibs
##     formDefault library_preparation
##     setFormField library_preparation library_name $ref_lib$library_name
##     formButton library_preparation importLMDB
##     formButton library_preparation selectDB
##     setFormField library_preparation min_db_to_import $_min_db_files
##     setFormField library_preparation max_db_to_import $_max_db_files
##     setFormField library_preparation typical_db_to_import $_nom_db_files
##     setFormField library_preparation other_db_to_import $_other_db_files
##     formOK library_preparation
##
##  } else {
##
##     echo "Min timing .lib files:      $min_lib_models"
##     echo "Nom timing .lib files:      $nom_lib_models"
##     echo "Max timing .lib files:      $max_lib_models"
##     echo "Other .lib files:           $other_lib_models"
##     echo ""
##
##     # check if the provided file lists are directories. If so, use all the .lib files
##     # in that directory
##     if {[file isdirectory $min_lib_models]} {
##        set _min_lib_files [string map {\n " "} [sh ls $min_lib_models/*.lib]]
##        echo "${flow_info_prefix} Using all .lib files in $min_lib_models as min models."
##     } else {
##        set _min_lib_files $min_lib_models
##     }
##
##     if {[file isdirectory $max_lib_models]} {
##        set _max_lib_files [string map {\n " "} [sh ls $max_lib_models/*.lib]]
##        echo "${flow_info_prefix} Using all .lib files in $max_lib_models as max models."
##     } else {
##        set _max_lib_files $max_lib_models
##     }
##
##     if {[file isdirectory $nom_lib_models]} {
##        set _nom_lib_files [string map {\n " "} [sh ls $nom_lib_models/*.lib]]
##        echo "${flow_info_prefix} Using all .lib files in $nom_lib_models as nom models."
##     } else {
##        set _nom_lib_files $nom_lib_models
##     }
##
##     if {[file isdirectory $other_lib_models]} {
##        set _other_lib_files [string map {\n " "} [sh ls $other_lib_models/*.lib]]
##        echo "${flow_info_prefix} Using all .lib files in $other_lib_models as other models."
##     } else {
##        set _other_lib_files $other_lib_models
##     }
##
##     gePrepLibs
##     formDefault library_preparation
##     setFormField library_preparation library_name $ref_lib$library_name
##     formButton library_preparation importLMDB
##
##     formButton library_preparation libToDB
##     setFormField library_preparation min_.lib_to_import $_min_lib_files
##     setFormField library_preparation max_.lib_to_import $_max_lib_files
##     setFormField library_preparation typical_.lib_to_import $_nom_lib_files
##     setFormField library_preparation other_.lib_to_import $_other_lib_files
##     formOK library_preparation
##  }
##}
###echo ""
##
###exec touch touchfiles/lib_db
###exit
