#!/usr/bin/env bash
# Prepare one project directory for a CI build.
#
# Every project gitignores its real secrets (Google Sign-In config, YouTube API
# key, email allowlist) and ships a placeholder next to each one. This script
# copies each placeholder into place when the real file is absent, so builds
# and unit tests run without credentials. It never overwrites an existing file.
#
# Usage: prepare-project.sh <project-dir>
set -euo pipefail
project="${1:?usage: prepare-project.sh <project-dir>}"
cd "$project"

created=()

# 1) Placeholders: foo.template, foo.example.js, foo.sample.dart, .env.example, config.properties.ci ...
while IFS= read -r -d '' src; do
  base=$(basename "$src"); dir=$(dirname "$src")
  target=$(printf '%s' "$base" | sed -E 's/\.(template|example|sample|ci)(\.|$)/\2/')
  [ "$target" = "$base" ] && continue
  if [ ! -e "$dir/$target" ]; then
    cp "$src" "$dir/$target"; created+=("$dir/$target")
  fi
done < <(find . \( -path ./node_modules -o -path ./build -o -path ./.dart_tool -o -path ./coverage \) -prune -o \
              -type f \( -iname '*.template' -o -iname '*.template.*' -o -iname '*.example' -o -iname '*.example.*' \
                         -o -iname '*.sample' -o -iname '*.sample.*' -o -iname '*.ci' \) -print0)

# 2) Android projects without any google-services placeholder: synthesize a dummy one.
for gradle in app/build.gradle.kts app/build.gradle; do
  [ -f "$gradle" ] || continue
  if [ ! -e app/google-services.json ]; then
    pkg=$(grep -oE 'applicationId\s*=?\s*"[^"]+"' "$gradle" | head -1 | sed -E 's/.*"([^"]+)"/\1/')
    [ -n "$pkg" ] || { echo "prepare-project: cannot find applicationId in $gradle" >&2; exit 1; }
    cat > app/google-services.json <<JSON
{
  "project_info": {
    "project_number": "123456789",
    "project_id": "dummy-project-ci",
    "storage_bucket": "dummy-project-ci.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789:android:abcdef123456789",
        "android_client_info": { "package_name": "$pkg" }
      },
      "oauth_client": [
        {
          "client_id": "123456789-dummy.apps.googleusercontent.com",
          "client_type": 1,
          "android_info": { "package_name": "$pkg", "certificate_hash": "03cd1bcd2c31b27cbbcb3c0b20b5bf2d77f1f0f7" }
        }
      ],
      "api_key": [ { "current_key": "AIzaSyDummyKeyForCIBuilds" } ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": [
            { "client_id": "123456789-dummy.apps.googleusercontent.com", "client_type": 3 }
          ]
        }
      }
    }
  ],
  "configuration_version": "1"
}
JSON
    created+=("app/google-services.json (dummy, package $pkg)")
  fi
done

if [ ${#created[@]} -gt 0 ]; then
  printf 'prepare-project: created %s\n' "${created[@]}"
else
  echo "prepare-project: nothing to do"
fi
