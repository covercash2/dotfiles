# basically just copying gifs to the clipboard for quick memeing

const IASIP_WHATUP_DOWNLOAD_LINK = "https://c.tenor.com/VHxRsj9wf8AAAAAd/tenor.gif"
const IASIP_WHATUP_LOCATION = "~/media/gifs/iasip-whatup.gif"

def download [
  source: string
  destination: path
] {
  http get $source | save ($destination | path expand)
}

def "clipboard copy" [
  content: string
] {
  if (uname | get kernel-name == "Darwin") {
    $content | pbcopy
  } else {
    $content | xclip -i -selection clipboard
  }
}

export def "gif whatup" [
  --source: string = $IASIP_WHATUP_DOWNLOAD_LINK,
  --destination: path = $IASIP_WHATUP_LOCATION,
] {
  download $source $destination
}
