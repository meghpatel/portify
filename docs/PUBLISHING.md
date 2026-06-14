# Publishing portify — step by step

This is written for a first-time CLI publisher. Do the steps in order.
Replace `meghpatel` everywhere with your real GitHub username.

There's a one-shot find/replace at the bottom to fill in your details.

---

## 0. The mental model

You will end up with **two GitHub repos**:

1. **`portify`** — the main repo (this code). Holds the script, the installer,
   the `.deb` builder, and your GitHub Releases.
2. **`homebrew-tap`** — a tiny second repo that holds just the Homebrew
   *formula*. Homebrew requires the repo to be named `homebrew-<something>`;
   when users type `brew tap you/tap` it looks for `you/homebrew-tap`.

Distribution channels, easiest → hardest:

| Channel | Effort | What users type |
|---|---|---|
| `curl \| bash` | trivial | one curl command |
| `.deb` on Releases | easy | `sudo apt install ./portify_*.deb` |
| Homebrew tap | easy | `brew tap you/tap && brew install portify` |
| Full apt repo | medium | `apt update && apt install portify` |

Ship the first three today; add the full apt repo when you want it.

---

## 1. Fill in your details

From the repo root:

```bash
# replace placeholders in every file
GH=your_github_username
NAME="Your Name"
EMAIL="patel.megh09@gmail.com"

grep -rl 'meghpatel' . | xargs sed -i.bak "s/meghpatel/$GH/g"
grep -rl 'Megh Patel'        . | xargs sed -i.bak "s/Megh Patel/$NAME/g"
grep -rl 'patel.megh09@gmail.com'  . | xargs sed -i.bak "s/patel.megh09@gmail.com/$EMAIL/g"
find . -name '*.bak' -delete
```

---

## 2. Create the main repo and push

```bash
git init
git add .
git commit -m "portify 1.0.0"
git branch -M main
# create the empty repo on github.com first, then:
git remote add origin https://github.com/$GH/portify.git
git push -u origin main
```

---

## 3. Cut your first release

```bash
bash release.sh 1.0.0
```

This tags `v1.0.0`, pushes, builds `dist/portify_1.0.0_all.deb`, and prints
(and writes into the formula) the **sha256** Homebrew needs.

Then on github.com → your repo → **Releases → Draft a new release**:
- choose tag `v1.0.0`
- **attach** `dist/portify_1.0.0_all.deb`
- publish.

`curl | bash` works the moment `main` is pushed — nothing else to do.

---

## 4. Homebrew tap

1. Create a second repo on GitHub named **`homebrew-tap`**.
2. Put the formula in it:
   ```bash
   git clone https://github.com/$GH/homebrew-tap.git
   mkdir -p homebrew-tap/Formula
   cp packaging/homebrew/portify.rb homebrew-tap/Formula/portify.rb
   cd homebrew-tap
   git add . && git commit -m "portify 1.0.0" && git push
   ```
   (The `sha256` and `url` were already filled in by `release.sh`.)
3. Test it:
   ```bash
   brew tap $GH/tap
   brew install portify
   portify --version
   ```

To verify before pushing: `brew install --build-from-source ./Formula/portify.rb`.

---

## 5. Real `apt install portify` (optional, do later)

`apt install` from a name (not a file) needs a **hosted apt repository** with a
**GPG signature**. The script `packaging/apt-repo/build-apt-repo.sh` builds one
you can host for free on GitHub Pages.

1. Make a signing key once:
   ```bash
   gpg --full-generate-key            # pick RSA 4096, no expiry is fine
   gpg --list-secret-keys --keyid-format=long   # copy the key id
   export GPG_KEY_ID=THATKEYID
   ```
2. Build the repo:
   ```bash
   make deb
   bash packaging/apt-repo/build-apt-repo.sh
   ```
   This creates an `apt-repo/` directory.
3. Host it: easiest is to enable **GitHub Pages** on your `portify` repo and
   serve the `apt-repo/` contents (e.g. push it to a `gh-pages` branch, or move
   it to a `/docs` folder and point Pages at `/docs`).
4. Users then run the apt block from the README.

> Alternative to self-hosting: **Cloudsmith** or **packagecloud.io** have free
> tiers for open-source and host a signed apt repo for you — less fiddly than
> GPG-by-hand if you'd rather not run the script above.

---

## 6. Releasing future versions

```bash
bash release.sh 1.0.1     # bumps, tags, builds, prints sha256
```

Then:
- attach the new `.deb` to the new GitHub Release,
- copy the updated `packaging/homebrew/portify.rb` into `homebrew-tap`, push,
- (if using the apt repo) re-run the apt-repo build and re-publish.

---

## Quick reference

```bash
make install     # install locally to /usr/local/bin for dev testing
make lint        # syntax check (install shellcheck for deeper linting)
make deb         # build the .deb only
bash release.sh 1.0.1
```
