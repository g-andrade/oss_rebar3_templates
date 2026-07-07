# oss_rebar3_templates

`rebar3 new` templates for g-andrade's open-source Erlang/OTP projects. Two
templates:

- `open_source_erlang_lib_template/` — a plain library
- `open_source_erlang_app_template/` — an OTP application (adds `_app` + `_sup`)

Each template dir holds a manifest (`oss_lib.template` / `oss_app.template`), a
`content/` tree of the files to emit, and a `test.sh`. Install by symlinking a
template dir into `~/.config/rebar3/templates/`.

## Testing

Run `make test` inside a template dir (or `./test.sh`). It instantiates the
template with `rebar3 new` into a temp dir and runs `make test check doc` on the
generated project. **This is the acceptance criterion — always run it after
changing a template.** `make doc` downloads the ex_doc escript, so it needs
network.

Local runs only exercise one OTP release. The OTP-gated plugin removal in
`rebar.config.script` (see below) is only truly exercised when a *generated*
project runs its own CI across the matrix.

## What the templates target (house style)

The output converges on the current house style shared by g-andrade's active
libs at `/home/g/code/oss/erlang/{locus,fake_lager,tls_certificate_check}`,
codified in `/home/g/code/oss/erlang/erlang-library-revival-playbook.md`. When
in doubt, read those reference libs — versions and idioms drift. Key elements:
EEP-48 native docs via the standalone **ex_doc escript** (not `rebar3_ex_doc`),
`rebar3 edoc` chunk pipeline, erlfmt, `check-fast`/`check-slow` Makefile split,
OTP 24–29 CI, and generated projects default to the `main` branch.

## Gotchas when editing the templates (non-obvious)

- **`{file}` vs `{template}` in the manifest.** `{template}` runs rebar3's
  mustache and substitutes `{{name}}`; `{file}` copies verbatim.
  - **`ci.yml` MUST stay `{file}`.** GitHub Actions `${{ … }}` expressions
    collide with mustache `{{ … }}` and would be mangled/emptied. It therefore
    cannot contain `{{name}}` — keep it name-agnostic.
  - `{template}` (contain `{{name}}`): `Makefile`, `rebar.config`,
    `ex_doc.config`, `README.md`, `AGENTS.md`, and the `src/`/`test/` sources.
  - `{file}` (name-agnostic): `rebar.config.script`, `shell.config`,
    `.gitattributes`, `.git-blame-ignore-revs`, `.gitignore`, `elvis.config`,
    `CHANGELOG.md`, `CLAUDE.md`, `dependabot.yml`,
    `otp_version_to_rebar3_version.json`.

- **Sources must ship erlfmt-clean.** Generated code is checked by
  `make check-formatted`. You can't run erlfmt on a template source directly —
  `{{name}}` isn't valid Erlang. To reformat: instantiate the template, run
  `rebar3 fmt` on the generated project, diff, and back-port the changes into
  the template re-inserting `{{name}}`.

- **No live constant-returning sample function.** `rebar.config` enables the
  strict dialyzer `underspecs` flag, which rejects a spec that is broader than a
  zero-arg function's constant success typing. The API module's example is kept
  as a *comment* for that reason.

- **`-moduledoc false` / `-doc false`, never `%% @private`.** ex_doc ignores
  `@private`; a documented module leaks all its exported functions otherwise.
  Doc attributes are `-ifdef(E48)`-guarded so sources still compile on OTP < 27.

- **Keep the two templates in sync.** Almost all `content/` files are identical
  between lib and app; the app adds `src/app.erl` + `src/sup.erl` and a `mod`
  entry in `.app.src`. Change both.

- **Bump the CI `_build` cache prefix** (`_build-cache1-…` → `-cache2-…`)
  whenever the OTP-gated plugin set in `rebar.config.script` changes, or a
  removed plugin's cached beams can resurface.

## Version pins to keep current

Bump against the reference libs when refreshing: erlfmt `~> 1.7`, `rebar3_hank`
`~> 1.6`, `rebar3_hex` `~> 7.1`, `rebar3_lint` `~> 5.0`, ex_doc escript `0.40.2`,
OTP CI matrix `24.3 25.3 26.2 27.3 28.5 29.0` (+ the `otp_version_to_rebar3_version.json`
map). Note these live in this repo's own docs too — grep before trusting them.
