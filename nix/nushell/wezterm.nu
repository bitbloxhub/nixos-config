def wezterm_set_user_var [name: string, value: string] {
	if (which base64 | is-empty) == false {
		print -n $"\e]1337;SetUserVar=( $name )=( $value | encode base64 )( char bel )"
	}
}

if not ($env.TERM == "dumb") {
	$env.config.hooks.pre_prompt = [{
		wezterm_set_user_var WEZTERM_PROG "nu"
		wezterm_set_user_var WEZTERM_USER (whoami)

		if not ("WEZTERM_HOSTNAME" in $env) {
			if ( '/proc/sys/kernel/hostname' | path exists ) {
				wezterm_set_user_var WEZTERM_HOST (open "/proc/sys/kernel/hostname" | str trim)
			} else if (which hostname | is-empty) == false {
				wezterm_set_user_var WEZTERM_HOST (hostname)
			} else if (which hostnamectl | is-empty) == false {
				wezterm_set_user_var WEZTERM_HOST (hostnamectl hostname)
			} else {
				wezterm_set_user_var WEZTERM_HOST "unknown"
			}
		} else {
			wezterm_set_user_var WEZTERM_HOST ($env | get WEZTERM_HOSTNAME)
		}
	}]

	$env.config.hooks.pre_execution = [{
		wezterm_set_user_var WEZTERM_PROG (commandline)
	}]
}
