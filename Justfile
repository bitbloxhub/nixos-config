set shell := ["nu", "-c"]

hostname := `hostname`

[group("system-manager")]
system-manager-rebuild action="switch" host=hostname:
	#!/usr/bin/env nu
	let user_for_host = {
		"extreme-creeper": "jonahgam"
	}
	if {{ host }}a == {{ hostname }} {
		sudo system-manager {{ action }} --flake ~/nixos-config/
		rm result
	} else {
		sudo system-manager --use-remote-sudo --target-host $"($user_for_host | get {{ host }})@{{ host }}" {{ action }} --flake ~/nixos-config/
	}

