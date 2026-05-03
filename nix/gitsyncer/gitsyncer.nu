#!/usr/bin/env nu

def main [config_path: path] {
	let config = (open $config_path)

	if not ($config.path | path exists) { git clone $config.repo $config.path }
	if not ($config.path | path join ".git" "branchless" | path exists) {
		do {
			cd $config.path
			git branchless init
			git config --local branchless.core.create-jujutsu-change-ids true
		}
	}

	do {
		cd $config.path

		let pull = (do -i { git pull } | complete)

		if $pull.exit_code != 0 {
			let conflicts = (git diff --name-only --diff-filter=U | lines)

			if ($conflicts | is-not-empty) {
				notify-send $"Merge conflicts in ($config.humanName)" ($conflicts | str join ", ")
			}

			error make {
				msg: $"git pull failed: ($pull.stderr | str trim)"
			}
		}

		git add .
		git record -m $config.message
		git push
	}
}
