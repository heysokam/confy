//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________

export type Short     = Set<string>
export type LongValue = string | boolean
export type Long      = Record<string, LongValue[]>
export type Args      = string[]
export type Opts      = {
  short  :Short
  long   :Long
}

export class CLI {
  readonly runner :string
  readonly arg0   :string
  opts  :Opts
  args  :Args

  #isLongSeparator (ch :string) :boolean { return ch === ':' || ch === '=' }
  #isName (ch :string) :boolean { return ch.length === 1 && /^[^\s-]$/.test(ch) }

  #addArg (arg :string) :void { this.args.push(arg) }
  #addShort (ch :string) :void { this.opts.short.add(ch) }
  #addLong (name :string, value :LongValue) :void {
    if (this.opts.long[name] == undefined) this.opts.long[name] = []
    this.opts.long[name].push(value)
  }

  #parseLong (arg :string, fromShort = false) {
    const invalid = !this.#isName(arg[(fromShort) ? 1 : 2] ?? "")
    if (invalid) return this.#addArg(arg)

    let name :string= ""
    const start = fromShort ? 1 : 2
    for (let id = start; id < arg.length; ++id) {
      const last = id === arg.length-1
      if (this.#isLongSeparator(arg[id] ?? "") || last) {
        if (!name) return
        this.#addLong(name, last ? true : arg.slice(id+1))
        break
      }
      name = name.concat(arg[id] ?? "")
    }
  }

  #parseShort (arg :string) {
    if (arg.length >= 3 && this.#isLongSeparator(arg[2] ?? "")) return this.#parseLong(arg, true)
    if (this.#isLongSeparator(arg[1] ?? "")) return this.#addArg(arg) // Invalids are considered args: -:ANY -=ANY
    for (const ch of arg.slice(1)) this.#addShort(ch)
  }

  constructor(argv ?:string[]) {
    if (!argv) argv = Bun.argv
    this.runner = argv[0]!
    this.arg0   = argv[1]!
    this.opts   = { short: new Set(), long: {}}
    this.args   = []
    for (const arg of argv.slice(2)) {
           if (!arg.startsWith("-")) this.#addArg(arg);
      else if (arg.startsWith("--")) this.#parseLong(arg)   // Might catch invalids
      else                           this.#parseShort(arg)  // Might catch invalids
    }
  }
}

