### Added
- [#81]: Added `/docs/CODEOWNDERS`.
- [#77]: Added structured versioned files for changelog.
- [#133]: Added `Windows` setup section in relative documentation.
- [#104]: Added `README` files in all relative directores.
- [#172]: Added CPU Architecture check.

### Removed
- [#76]: Removed `/assets` directory.

### Changed
- [#107]: Moved notes directory.
- [#83]: Moved documents from `/.github` to `/docs`.
- [#86]: Moved variables from `/iron_book.sh` to `/scripts/lib/vars.sh`.
- [#85]: Moved `/iron_book.sh` to `/scripts/iron_book.sh`.
- [#84]: Moved `/docker-compose-dev.yaml` & `/docker-compose-prod.yaml` to `/infra/docker/compose/`.
- [#82]: Moved `/proto/` to `/contracts/proto/`.
- [#90]: Moved `cmd_get_codebase()` from `/scripts/utility.sh` to `/scripts/tools/get_codebase.sh`.
- [#89]: Moved `tree()` from `/scripts/utility.sh` to `scripts/tools/tree.sh`.
- [#79]: Renamed every reference from `iron_book` to `ironbook`.
- [#100]: Moved `/scripts/linux_installer.sh` to `/scripts/install/linux/installer.sh`.
- [#101]: Moved `/scripts/windows_installer.iss` to `/scripts/install/windows/installer.iss`.
- [#88]: Moved `usage()` from `/scripts/utility.sh` to `/scripts/lib/help.sh`.
- [#96]: Moved `/scripts/build.sh` to `/scripts/build/build.sh`.
- [#91]: Moved `cmd_get_latest_changelog()` from `/scripts/utility.sh` to `/scripts/release/get_latest_changelog.sh`.
- [#92]: Moved `/scripts/utility.sh` to `/scripts/lib/utility.sh`.
- [#94]: Moved `/setup.sh` to `/scripts/setup/setup.sh`.
- [#99]: Moved `sign_release_files()` from `/scripts/build/build.sh` to `/scripts/release/sign.sh`.
- [#98]: Moved `update_version_*()` from `/scripts/build/build.sh` to `/scripts/release/update_version.sh`.
- [#97]: Moved `package_*()` from `/scripts/build/build.sh` to `/scripts/build/package.sh`.
- [#144]: Distributed `/scripts/build/build.sh` into smaller scripts.
- [#95]: Distributed `/scripts/setup/setup.sh` into smaller scripts.
- [#102]: Separated pre commit and pre push tests.

### Fixed
- [#120]: Updated the path to the `/scripts/iron_book.sh` in `/.github/workflows/release.yml`.
- [#122]: Fixed `/apps/web` version not being updated automatically.
- [#108]: Fixed `ironbook_db` being mapped to host port in prod.
- [#135]: Fixed mise failing on systems which don't have symlinks. Now mise installs to default installation directory.
- [#151]: Fixed `pre-commit install` failing.
- [#134]: Fixed setup failing when already running as root or `sudo` wasn't available.
- [#171]: Fixed uninstall script breaking if interrupted.
- [#174]: Fixed Linux installer not moving dotfiles while installing.
- [#169]: Fixed Linux installer not failing if the download was interrupted.
- [#105]: Fixed Docs site not being user friendly on mobiles.
- [#80]: Now organization GPG key is used to sign releases.
- [#181]: Revamped the entire `.http` files
