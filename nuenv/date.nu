const DATE_FORMAT = "%Y-%m-%d %H%M:%S"

export def "format date simple" [] {
  into datetime | format date $DATE_FORMAT
}

