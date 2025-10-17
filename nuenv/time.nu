# utilities for working with time stuff on the command line

# given some epoch time (in UTC) get the current date time in local time
export def "date of" [
  epoch_offset: int # epoch time in `units`
  --units: string@units = seconds
] {
    error make { msg: "unimplemented :(" }
}

# print the time in Central, Pacific, and India time
export def "date workzones" [
  --local-time: string@tz_labels = CT
]: [
  datetime -> datetime
  string -> datetime
] {
  let time = $in | date to-timezone (timezones | get $local_time)
  timezones
  | items {|label, iana_name|
      let local_time = $time | date to-timezone $iana_name
      { $label: $local_time }
    }
  | reduce {|tz| merge $tz }
}

def units [] {
  [seconds, millis, nanos]
}

# timezones i care about personally
def timezones []: nothing -> record {
  {
    IST: Asia/Kolkata
    CT: US/Central
    ET: US/Eastern
    PT: US/Pacific
  }
}

def tz_labels [] {
  timezones | columns
}
