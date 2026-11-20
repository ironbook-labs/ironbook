#!/usr/bin/env bash

build_api() {
  echo "🔨 Building API..."

  export SQLX_OFFLINE=true

  (
    cd "$API_DIR"

    mise exec -- cargo build --release
    mise exec -- cargo build \
      --target x86_64-pc-windows-gnu \
      --release
  )

  echo "✔ API build complete."
}

build_home() {
  echo "🔨 Building Home..."

  (
    cd "$HOME_DIR"
    mise exec -- pnpm build
  )

  echo "✔ Home build complete."
}

build_desktop() {
  echo "🔨 Building Desktop..."

  (
    cd "$DESKTOP_DIR"

    mise exec -- dotnet publish \
      -c Release \
      -r linux-x64 \
      --self-contained true \
      -o output/linux

    mise exec -- dotnet publish \
      -c Release \
      -r win-x64 \
      --self-contained true \
      -o output/windows
  )

  echo "✔ Desktop build complete."
}

build_android() {
  echo "🔨 Building Android..."

  (
    cd "$ANDROID_DIR"
    mise exec -- ./gradlew assembleRelease --stacktrace
  )

  echo "✔ Android build complete."
}

build_windows_installer() {
  echo "🔨 Building Windows Installer..."

  local installer_dir
  installer_dir="$(mktemp -d)"

  mkdir -p "$WINDOWS_INSTALLER_OUTPUT"

  cp "$SCRIPTS_DIR/install/windows/installer.iss" \
    "$installer_dir/installer.iss"

  cp "$SCRIPTS_DIR/install/windows/fetch_and_install.ps1" \
    "$installer_dir/fetch_and_install.ps1"

  mkdir -p "$installer_dir/Output"

  chmod -R a+rwx "$installer_dir"

  docker run --rm \
    -v "$installer_dir:/work" \
    docker.io/amake/innosetup \
    /work/installer.iss

  cp "$installer_dir/Output/IronBook-Setup.exe" \
    "$WINDOWS_INSTALLER_OUTPUT/IronBook-Setup.exe"

  echo "✔ Windows Installer build complete."
}

cmd_build() {
  local version="${1:-}"

  require_version "$version" || return 1

  echo ""
  echo "========================================"
  echo " Building IronBook $version"
  echo "========================================"
  echo ""

  echo "🧹 Cleaning output directory..."
  rm -rf "$OUTPUT_DIR"

  echo "📝 Generating latest changelog..."
  generate_changelog "$version"

  build_api
  package_api "$version"

  build_home
  package_home "$version"

  build_desktop
  package_desktop "$version"

  build_android
  package_android "$version"

  build_windows_installer
  package_windows_installer "$version"

  echo ""
  echo "========================================"
  echo " ✔ Build $version complete"
  echo "========================================"
}
