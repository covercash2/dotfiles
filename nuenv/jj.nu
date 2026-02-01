
export def "jj branches" [] {
  jj log --revisions 'heads(all())'
}
