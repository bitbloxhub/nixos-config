import { readFile, writeFile } from "node:fs/promises"
import { argv } from "node:process"
import { parse as kdl_parse, format as kdl_format } from "kdljs"

const parsed = kdl_parse(await readFile(argv[2], "utf8"))
await writeFile(argv[3], kdl_format())
