# This is a configuration file not covered by GPL terms

# OVERWRITING GLOBAL BATSERVICE VARS CAN LEAD TO UNEXPECTED SERVICE ERRORS
# YOU HAVE BEEN WARNED!

# All global variable names set by you should start with "u_"

# This is mostly a configuration task
user_events_pre () {
  return 0
}


user_on_status_change () {
  return $EVENTS_OK
}


user_on_charge () {
  return $EVENTS_OK
}

user_on_discharge () {
  return $EVENTS_OK
}

user_on_idle () {
  return $EVENTS_OK
}


user_on_temp_increase () {
  return $EVENTS_OK
}

user_on_temp_decrease () {
  return $EVENTS_OK
}
