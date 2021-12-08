# This is a configuration file not covered by GPL terms

# CONFIGURATION EXAMPLE FOR A NULL ACTION
# my_null_action () {
#   return $JOBS_NEXT
# }
#
# user_jobs_lowest () {
#   local r
#
#   my_null_action
#   r=$?
#   if [ $r -ne $JOBS_NEXT ]; then return $r; fi
# }


# OVERWRITING GLOBAL BATSERVICE VARS CAN LEAD TO UNEXPECTED SERVICE ERRORS
# YOU HAVE BEEN WARNED!

# All global variable names set by you should start with "u_"

# This is mostly a configuration task
user_jobs_pre () {
  return 0
}


user_jobs_highest () {
  return $JOBS_NEXT
}

user_jobs_lowest () {
  return $JOBS_NEXT
}
