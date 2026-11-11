# The `math-check` build hook (tola-module.toml): under `tola dev`, runs
# math-check.mjs when Node.js is installed and passes its warnings to Tola.
# Production builds and machines without Node skip it, so neither a
# deployment nor a site without Node depends on it.

use tola [diagnostic get-hook get-site]

const HERE = path self .

def main [] {
  let hook = get-hook
  let node = which node | get -o 0.path
  if $hook.mode != "dev" or $node == null {
    [] | diagnostic submit
    return
  }

  let site = get-site
  let report = $hook.temp-dir | path join "report.json"
  let run = with-env {
    TOLA_HOOK_INPUT_DIR: $hook.input-dir
    TOLA_BUILD_MODE: $hook.mode
    TOLA_PROJECT_ROOT: $site.root
    TOLA_CONTENT_ROOT: $site.content-root
    TOLA_REPORT_PATH: $report
  } {
    run-external $node ($HERE | path join "math-check.mjs") | complete
  }

  if not ($report | path exists) {
    let issues = if $run.exit_code == 0 { [] } else {
      [(diagnostic issue "math-check.mjs stopped without a report." --code math-check
        --notes [($run.stdout + $run.stderr | str trim)])]
    }
    $issues | diagnostic submit
    return
  }
  open $report
  | get diagnostics
  | each {|d|
      (diagnostic issue $d.message --severity $d.severity --code ($d.code? | default "math-check")
        --notes ($d.notes? | default []) --hints ($d.hints? | default []))
    }
  | diagnostic submit
}
