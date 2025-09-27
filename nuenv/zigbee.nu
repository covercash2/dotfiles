use std assert

let TEST_FILE = ("./zigbee_test.txt" | path expand)

let LOG_COMMAND = [podman container logs zigbee2mqtt]

let _HOST_REGEX = '(?P<host>[0-9a-zA-Z]+)'
let _LEVEL_REGEX = '(?P<level>[0-9a-zA-Z]+)'
let _TIMESTAMP_REGEX = '(?P<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})'
let _PROTOCOL_REGEX = '(?P<protocol>[a-zA-z]+)'
let _EVENT_REGEX = '(?P<event>[a-zA-z]+)'
let _TOPIC_REGEX = "(?P<topic>[^']+)"
let _PAYLOAD_REGEX = "(?P<payload>[^']+)"

let ZIGBEE_LOG_REGEX: string = $"^($_HOST_REGEX):($_LEVEL_REGEX)  ($_TIMESTAMP_REGEX): ($_PROTOCOL_REGEX) ($_EVENT_REGEX): topic '($_TOPIC_REGEX)', payload '($_PAYLOAD_REGEX)'$"

def zigbee [] {

}

# takes a line of input and parses the output
export def "zigbee parse log" [] {
	(
		parse --regex $ZIGBEE_LOG_REGEX
		| update timestamp {|row| $row.timestamp | into datetime }
	)
}

#[test]
def test_zigbee_parse_log [] {
	open $TEST_FILE | lines | take 2 | zigbee parse log
}
