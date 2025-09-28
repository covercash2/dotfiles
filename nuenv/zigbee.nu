use std assert
use ./mosquitto.nu *

const TEST_FILE = ("./zigbee_test.txt" | path expand)

const LOG_COMMAND = [podman container logs zigbee2mqtt]

const _HOST_REGEX = '(?P<host>[0-9a-zA-Z]+)'
const _LEVEL_REGEX = '(?P<level>[0-9a-zA-Z]+)'
const _TIMESTAMP_REGEX = '(?P<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})'
const _PROTOCOL_REGEX = '(?P<protocol>[a-zA-z]+)'
const _EVENT_REGEX = '(?P<event>[a-zA-z]+)'
const _TOPIC_REGEX = "(?P<topic>[^']+)"
const _PAYLOAD_REGEX = "(?P<payload>[^']+)"

const ZIGBEE_LOG_REGEX: string = $"^($_HOST_REGEX):($_LEVEL_REGEX)  ($_TIMESTAMP_REGEX): ($_PROTOCOL_REGEX) ($_EVENT_REGEX): topic '($_TOPIC_REGEX)', payload '($_PAYLOAD_REGEX)'$"

export def main [] {

}

# takes a line of input and parses the output
export def "zigbee parse log" [] {
	(
		parse --regex $ZIGBEE_LOG_REGEX
		| update timestamp {|row| $row.timestamp | into datetime }
	)
}

export def "zigbee device permit_join" [
  duration: int = 60
] {
  let topic = "zigbee2mqtt/bridge/request/permit_join"
  let message = {
    time: $duration
  }

  mosquitto publish --topic $topic --message $message
}

export def "zigbee healthcheck" [] {
  let topic = "zigbee2mqtt/bridge/request/health_check"
  let message = {}

  mosquitto publish --topic $topic --message $message
}

export def "zigbee request" [
  --message: record = {}
  topic: string
] {
  let topic = $"zigbee2mqtt/bridge/request/($topic)"

  mosquitto publish --topic $topic --message $message
}

export def "zigbee device" [
  topic: string # the command to send to the device
  --message: record = {} # the message to send to the device
] {
  let topic = $"device/($topic)"

  zigbee request --message $message $topic
}

export def "zigbee device interview" [
  name: string # the friendly name of the device
] {
  zigbee device "interview" --message { id: $name }
}

#[test]
def test_zigbee_parse_log [] {
	open $TEST_FILE | lines | take 2 | zigbee parse log
}
