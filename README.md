# portify

A tiny CLI for keeping track of which local port belongs to which project.
Look up ports, allocate a stable port to a project by name (hash-based),
reverse-look-up, and auto-scan the machine for ports already in use.

```
$ portify --allocate MarsQ
Allocated: 20667 → MarsQ

$ portify --whois 20667
Port 20667 → MarsQ

$ portify 5432 --live
Port 5432: PostgreSQL
  ● Live: postgres (PID 9876) is listening
```

## Install

**Homebrew** (macOS / Linux)
```bash
brew tap meghpatel/tap
brew install portify
```

**apt** (Debian / Ubuntu)
```bash
curl -fsSL https://meghpatel.github.io/portify/portify.gpg.key \
  | sudo gpg --dearmor -o /usr/share/keyrings/portify.gpg
echo "deb [signed-by=/usr/share/keyrings/portify.gpg] https://meghpatel.github.io/portify stable main" \
  | sudo tee /etc/apt/sources.list.d/portify.list
sudo apt update && sudo apt install portify
```

**Or just grab the .deb** from the [Releases](https://github.com/meghpatel/portify/releases) page:
```bash
sudo apt install ./portify_1.0.0_all.deb
```

**Or curl | bash** (no package manager)
```bash
curl -fsSL https://raw.githubusercontent.com/meghpatel/portify/main/install.sh | bash
```

## First run

No setup needed — the registry is created automatically the first time you use it.
To pull in the ports your machine is already using:

```bash
portify --scan --apply
```

## Commands

| Command | What it does |
|---|---|
| `portify <port>` | Look up a port |
| `portify <port> --live` | Look up + check if something is listening |
| `portify --list` | Show all registered ports |
| `portify --add <port> "desc"` | Add a manual entry |
| `portify --allocate <project> [-q]` | Hash a project name to a stable port and save it |
| `portify --set-port <project> <path>` | Write a project's allocated port into its `package.json` / vite config |
| `portify --whois <port>` | Reverse lookup: port → project |
| `portify --scan [--apply]` | Discover (and optionally import) listening ports |
| `portify --init` | Create an empty registry |
| `portify --version` | Print version |

## How `--allocate` works

`portify` runs an FNV-1a 32-bit hash of the lowercased project name and maps it
into the range `1024–65534`. The same name always hashes to the same port, so a
project's port is derivable from its name. If that port is already taken in your
registry, it probes linearly to the next free slot. Re-running is idempotent.

Wire it into a project so the port is never hardcoded:

```json
"scripts": {
  "dev": "vite --port $(portify --allocate MarsQ --quiet)"
}
```

## Wiring the port into a project (`--set-port`)

The `--quiet` form above computes the port at runtime. If you'd rather **bake**
the allocated port straight into a project's config, allocate it once and then
point `--set-port` at the project:

```bash
portify --allocate MarsQ          # 20667 → MarsQ
portify --set-port MarsQ ./marsq  # writes 20667 into ./marsq's config
```

The path can be a **directory** (it prefers `vite.config.*`, otherwise
`package.json`) or a **file**:

- **`vite.config.{ts,js,mjs,…}`** — sets `server.port`, inserting a `server`
  block if one doesn't exist yet.
- **`package.json`** — appends (or updates) `--port <n>` on the `dev`,
  `preview`, `start`, and `serve` scripts that invoke `vite`, preserving your
  existing formatting. Non-vite scripts are left untouched.

It reads the port already assigned to the project in the registry, so the name
must be allocated first. Re-running is idempotent.

## Registry

Plain YAML, one entry per line, stored at `~/.ports/ports.yaml` by default:

```yaml
5432: PostgreSQL
20667: MarsQ
8080: nginx (auto-scanned)
```

Override the location:
```bash
export PORTS_FILE=~/path/to/ports.yaml
```

## License

MIT
