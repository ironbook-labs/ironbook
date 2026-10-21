### Added
- [#81]: Added `/docs/CODEOWNDERS`.
- [#77]: Added structured versioned files for changelog.
- [#133]: Added `Windows` setup section in relative documentation.
- [#104]: Added `README` files in all relative directores.
- [#172]: Added CPU Architecture check.
- [#186]: Added production docker deployment for `/apps/api`, `/apps/home`, and `/apps/web`.
- [#53]: Added hashing to API Tokens.
- [#181]: Revamped the entire `/apps/api/http/*.http` files.
- [#175]: Linux installer now gives clear error messages about required dependencies missing.
- [#173]: Linux installe rnow gives clear error messages about GitHub API errors.
- [#185]: Added GRPC endpoint tester scripts in `/apps/api/requests/grpc`.
- [#205]: Added `doas` support in setup.
- [#199]: Added support for `--no-*` flags in `setup.sh`.

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
- [#193]: Removed compiling of `cargo-watch` in favor of using binary.
- [#207]: Updated workflows for CI/CD to use flags.
- [#209]: Update the design of, and removed redundancies from `/.github/PULL_REQUEST_TEMPLATE.md`.

### Fixed
- [#120]: Updated the path to the `/scripts/iron_book.sh` in `/.github/workflows/release.yml`.
- [#122]: Fixed `/apps/web` version not being updated automatically.
- [#108]: Fixed `ironbook_db` service in `/infra/docker/compose/compose.yaml` being mapped to host port in prod.
- [#135]: Fixed mise failing on systems which don't have symlinks. Now mise installs to default installation directory.
- [#151]: Fixed `pre-commit install` failing.
- [#134]: Fixed setup failing when already running as root or `sudo` wasn't available.
- [#171]: Fixed Linux Desktop uninstall script breaking if interrupted.
- [#174]: Fixed `/scripts/install/linux/installer.sh` not moving dotfiles while installing.
- [#169]: Fixed `/scripts/install/linux/installer.sh` not failing loudly with clear error, if the download was interrupted.
- [#105]: Fixed `/apps/home` not being user friendly on mobiles.
- [#80]: Now organization GPG key is used to sign releases.
- [#180]: A single owner can now have multiple clients.
- [#170]: `/scripts/install/linux/installer.sh` no longer leaves installation broken upon failure.
- [#197]: Fixed `/apps/web` warning of a static directory not existing.
- [#195]: Setup now adds the user to the `docker` group and requests to restart the system.
