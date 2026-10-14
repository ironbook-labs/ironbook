#!/usr/bin/env bash

# Signs every *.zip under $OUTPUT_DIR with the configured release key.
# RELEASE_GPG_KEY must be the fingerprint of the organization/project
# signing key (see .github/workflows/release.yml which verifies the
# imported key against the RELEASE_GPG_FINGERPRINT repo variable).
sign_release_files() {
    if [[ -z "${RELEASE_GPG_KEY:-}" ]]; then
        echo "❌ RELEASE_GPG_KEY is not set."
        echo ""
        echo "Set it in your environment or .env:"
        echo "  RELEASE_GPG_KEY=<fingerprint>"
        return 1
    fi

    echo "🔐 Signing release files..."

    local found=0

    while IFS= read -r -d '' file; do
        found=1

        echo "  Signing $(basename "$file")"

        gpg \
            --batch \
            --yes \
            --local-user "$RELEASE_GPG_KEY" \
            --detach-sign \
            --armor \
            "$file"

    done < <(
        find "$OUTPUT_DIR" \
            -type f \
            -name '*.zip' \
            -print0
    )

    if [[ "$found" -eq 0 ]]; then
        echo "❌ No release archives found to sign."
        return 1
    fi

    echo "✔ Release files signed."
}
