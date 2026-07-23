generate-host-api:
	#!/usr/bin/env nu
	let root = "{{ justfile_directory() }}"
	let yawsf = (nix flake archive --json $root | from json | get inputs.yawsf.path)
	let spec = ($yawsf | path join "docs/public/openapi.json")
	with-env { YAWSF_HOST_OPENAPI_SPEC: $spec } {
		pnpm generate:yawsf-host-api
	}

generate-web-api:
	pnpm generate:web-api
