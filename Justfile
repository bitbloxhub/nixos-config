set shell := ["nu", "-c"]

hostname := `hostname`

deploy +$hosts=hostname:
	#!/usr/bin/env nu
	let hosts = (
		$env.hosts
		| split row " "
		| each {|host| $".#($host)"}
	)
	deploy -s --targets ...$hosts
