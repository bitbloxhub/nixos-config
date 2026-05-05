#!/usr/bin/env nu

def sync-bars [] {
	let monitor_ids = (try {
 		let outputs = (niri msg --json outputs | from json)
		if (($outputs | length) == 0) {
			["0"]
		} else {
			$outputs | enumerate | each {|it| $it.index | into string}
		}
	} catch {
		["0"]
	})

	let desired_ids = ($monitor_ids | each {|m| $"bar-($m)"})

	let active_ids = (try {
		ewwii active-windows
		| lines
		| parse "{id}: {name}"
		| get id
	} catch {
		[]
	})

	for id in $active_ids {
		if (($id | str starts-with "bar-") and (not ($desired_ids | any {|d| $d == $id}))) {
			^ewwii close $id
		}
	}

	for m in $monitor_ids {
		let id = $"bar-($m)"
		if (not ($active_ids | any {|a| $a == $id})) {
			^ewwii open bar --id $id --screen $m
		}
	}

	print "ok"
}

sync-bars

niri msg event-stream | lines | each { |_|
	sync-bars
}
