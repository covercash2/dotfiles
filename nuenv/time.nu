# utilities for working with time stuff on the command line

# given some epoch time (in UTC) get the current date time in local time
export def date_of [
  epoch_offset: int # epoch time in `units`
  --units: string@units = seconds
] {

}

def units [] {
  [seconds, millis, nanos]
}
