#!/usr/bin/env nu
let ags_commit = (http get https://api.github.com/repos/Aylur/ags/commits/main | get sha)
let gnim_commit = (http get $"https://api.github.com/repos/Aylur/ags/contents/lib/gnim?ref=($ags_commit)" | get sha)
let gnim_command = $"git clone https://github.com/Aylur/gnim gnim && cd gnim && git checkout ($gnim_commit)"
let ags_url = $"https://gitpkg.vercel.app/Aylur/ags/lib?($ags_commit)&scripts.postinstall=($gnim_command | url encode --all)"
open ./package.json | update dependencies.ags $ags_url | to json | save -f package.json
npm install
