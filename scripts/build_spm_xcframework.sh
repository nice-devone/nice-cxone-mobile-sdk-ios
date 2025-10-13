#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
#  build_spm_xcframework.sh
#
#  Archives a Swift Package product for both device and simulator, stitches
#  the resulting frameworks together into an XCFramework, and verifies that
#  Swift modules/interfaces are embedded for every slice.  This script is
#  intentionally self-contained so it can be launched from any working
#  directory, CI pipeline, or release automation.
# ---------------------------------------------------------------------------

usage() {
  cat <<USAGE
Usage: $0 [/path/to/package] <ProductName> [Release|Debug] [OUT_DIR] [BUILD_DIR]

Examples:
  $0 . CXoneChatSDK
  $0 /abs/path/to/package CXoneChatSDK Release ./XCOut ./XCBuild
USAGE
}

section() {
  local title="$1"
  echo
  echo "==== $title ===="
}

PKG_DIR_RAW="${1:-.}"
PRODUCT="${2:-}"
CONFIG="${3:-Release}"
OUT_DIR="${4:-./XCOut}"
BUILD_DIR="${5:-./XCBuild}"

if [[ -z "$PRODUCT" ]]; then
  usage
  exit 1
fi

PKG_DIR="$(cd "$PKG_DIR_RAW" && pwd)"
if [[ ! -f "$PKG_DIR/Package.swift" ]]; then
  echo "✗ No Package.swift at: $PKG_DIR"
  exit 1
fi

ABS_OUT="$(cd "$(dirname "$OUT_DIR")" && pwd)/$(basename "$OUT_DIR")"
ABS_BUILD="$(cd "$(dirname "$BUILD_DIR")" && pwd)/$(basename "$BUILD_DIR")"
DERIVED="$ABS_BUILD/DerivedData"
LOG_DIR="$ABS_BUILD/logs"

# ---- Helpers ---------------------------------------------------------------

# Find the framework produced by an archive. xcodebuild may place package
# products either directly under Products/Library/Frameworks or under the
# PackageFrameworks directory, so we probe both locations.
find_fw() {
  local arch_path="$1"
  local pf="$arch_path.xcarchive/Products/Library/Frameworks/PackageFrameworks/${PRODUCT}.framework"
  local f="$arch_path.xcarchive/Products/Library/Frameworks/${PRODUCT}.framework"
  if [[ -d "$pf" ]]; then echo "$pf"; return 0; fi
  if [[ -d "$f" ]]; then echo "$f"; return 0; fi
  /usr/bin/find "$arch_path.xcarchive/Products" -type d -name "${PRODUCT}.framework" -print -quit 2>/dev/null || true
}

# Copy Swift module artifacts from the build products directory into the
# archived framework. This keeps the modules available even after the compiler
# prunes intermediates later in the pipeline.
copy_swiftmodules() {
  local variant_dir="$1"
  local framework_path="$2"
  local candidates=(
    "$variant_dir/${PRODUCT}.swiftmodule"
    "$variant_dir/${PRODUCT}.framework/Modules/${PRODUCT}.swiftmodule"
    "$variant_dir/PackageFrameworks/${PRODUCT}.framework/Modules/${PRODUCT}.swiftmodule"
  )
  local src=""
  for cand in "${candidates[@]}"; do
    if [[ -d "$cand" ]]; then
      src="$cand"
      break
    fi
  done

  local dst="$framework_path/Modules/${PRODUCT}.swiftmodule"
  mkdir -p "$dst"

  if [[ -z "$src" ]]; then
    echo "⚠️  No Swift module artifacts found under: $variant_dir"
    return 0
  fi

  shopt -s nullglob
  local files=("$src"/*)
  shopt -u nullglob
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "⚠️  Swift module directory empty at: $src"
    return 0
  fi

  /bin/cp -f "${files[@]}" "$dst/"
  echo "▶ Embedded Swift modules → $dst"
}

# Archive the scheme for a single destination (device or simulator). Returns
# the resolved framework path via stdout so callers can capture it:
#   FW_IOS="$(archive_variant "iOS device" ...)"
archive_variant() {
  local label="$1"
  local destination="$2"
  local archive_path="$3"
  local result_bundle="$4"
  local module_root="$5"

  section "Archive (${label})"
  xcodebuild archive \
    -scheme "$PRODUCT" \
    -configuration "$CONFIG" \
    -destination "$destination" \
    -archivePath "$archive_path" \
    -derivedDataPath "$DERIVED" \
    -resultBundlePath "$result_bundle" \
    -showBuildTimingSummary \
    "${COMMON_XCB_FLAGS[@]}"

  local framework_path
  framework_path="$(find_fw "$archive_path")"
  if [[ -n "${framework_path:-}" ]]; then
    copy_swiftmodules "$module_root" "$framework_path"
  fi

  printf '%s\n' "${framework_path:-}"
}

# Copy Swift interface/module artifacts from the source archives into each
# XCFramework slice. xcodebuild -create-xcframework sometimes drops the binary
# `.swiftmodule` files, so we synchronise them manually.
sync_slice_modules() {
  local source_device="$1"
  local source_sim="$2"
  local xcframework="$3"

  section "Sync Swift modules into XCFramework slices"
  for slice in "$xcframework"/*; do
    [[ -d "$slice" ]] || continue

    local source_fw="$source_device"
    local slice_fw="$slice/$(basename "$source_device")"
    if [[ "$slice" == *simulator* ]]; then
      source_fw="$source_sim"
      slice_fw="$slice/$(basename "$source_sim")"
    fi

    if [[ ! -d "$slice_fw" ]]; then
      echo "⚠️  Unable to locate framework in slice: $slice"
      continue
    fi

    local src_mod="$source_fw/Modules/${PRODUCT}.swiftmodule"
    local dst_mod="$slice_fw/Modules/${PRODUCT}.swiftmodule"
    if [[ -d "$src_mod" ]]; then
      mkdir -p "$dst_mod"
      shopt -s nullglob
      /bin/cp -f "$src_mod"/* "$dst_mod/" 2>/dev/null || true
      shopt -u nullglob
    fi
  done
}

# ---- Pre-clean -------------------------------------------------------------
section "Pre-clean"
echo "Removing .swiftpm, XCBuild, XCOut…"
rm -rf "$PKG_DIR/.swiftpm" "$ABS_BUILD" "$ABS_OUT" || true
mkdir -p "$ABS_OUT" "$ABS_BUILD" "$LOG_DIR"

section "Environment"
echo "xcodebuild: $(xcrun --find xcodebuild)"
xcodebuild -version
echo "Package dir: $PKG_DIR"
echo "DerivedData: $DERIVED"
echo "Out dir:     $ABS_OUT"
echo "Product:     $PRODUCT"
echo "Config:      $CONFIG"
echo "====================="

pushd "$PKG_DIR" >/dev/null

# Sanity: valid package
swift package describe >/dev/null

COMMON_XCB_FLAGS=(
  -skipPackagePluginValidation
  -skipMacroValidation
  CODE_SIGNING_ALLOWED=NO
  SKIP_INSTALL=NO
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES   # <- ensure .swiftmodule/.swiftinterface are emitted
  SWIFT_VERIFY_EMITTED_MODULE_INTERFACE=NO
  OTHER_SWIFT_FLAGS='$(inherited) -DRESILIENT_LIBRARIES -no-verify-emitted-module-interface' # -DRESILIENT_LIBRARIES keeps swift-syntax happy under library evolution
  VALIDATE_WORKSPACE=NO
  ENABLE_BITCODE=NO
  # EXCLUDED_PACKAGE_PRODUCT_DEPENDENCIES='SwiftSyntax SwiftParser SwiftSyntaxParser SwiftCompilerPluginSupport XCTestDynamicOverlay Mockable'
)

BP_ROOT="$DERIVED/Build/Intermediates.noindex/ArchiveIntermediates/$PRODUCT/BuildProductsPath"

# ---- Archive (device) ----
ARCH_IOS="$ABS_BUILD/${PRODUCT}-iOS"
FW_IOS="$(archive_variant \
  "iOS device" \
  "generic/platform=iOS" \
  "$ARCH_IOS" \
  "$LOG_DIR/Archive-iOS.xcresult" \
  "$BP_ROOT/Release-iphoneos"
)"

# ---- Archive (simulator) ----
ARCH_SIM="$ABS_BUILD/${PRODUCT}-iOS-sim"
FW_SIM="$(archive_variant \
  "iOS Simulator" \
  "generic/platform=iOS Simulator" \
  "$ARCH_SIM" \
  "$LOG_DIR/Archive-Sim.xcresult" \
  "$BP_ROOT/Release-iphonesimulator"
)"

popd >/dev/null

# Reconfirm framework locations once archives are fully written.
if [[ -z "${FW_IOS:-}" ]]; then
  FW_IOS="$(find_fw "$ARCH_IOS")"
fi
if [[ -z "${FW_SIM:-}" ]]; then
  FW_SIM="$(find_fw "$ARCH_SIM")"
fi

echo "▶ Located frameworks:"
echo "  device:    ${FW_IOS:-MISSING}"
echo "  simulator: ${FW_SIM:-MISSING}"

if [[ -z "${FW_IOS:-}" || -z "${FW_SIM:-}" ]]; then
  echo "✗ Could not find ${PRODUCT}.framework in one or both archives."
  echo "  Inspect result bundles:"
  echo "    open \"$LOG_DIR/Archive-iOS.xcresult\""
  echo "    open \"$LOG_DIR/Archive-Sim.xcresult\""
  /usr/bin/find "$ARCH_IOS.xcarchive" -maxdepth 6 -print | egrep 'Products/Library/Frameworks|PackageFrameworks' || true
  /usr/bin/find "$ARCH_SIM.xcarchive" -maxdepth 6 -print | egrep 'Products/Library/Frameworks|PackageFrameworks' || true
  exit 1
fi

# ---- Create XCFramework ----
OUT_XC="$ABS_OUT/$PRODUCT.xcframework"
echo "▶ Creating XCFramework → $OUT_XC"
rm -rf "$OUT_XC"
xcodebuild -create-xcframework \
  -framework "$FW_IOS" \
  -framework "$FW_SIM" \
  -output "$OUT_XC"

sync_slice_modules "$FW_IOS" "$FW_SIM" "$OUT_XC"

# ---- Verify Swift modules exist in each slice ----
echo "▶ Verifying Swift modules exist in slices…"
missing=0
while IFS= read -r -d '' slice; do
  # Expect: <slice>/<PRODUCT>.framework/Modules/<PRODUCT>.swiftmodule/*.swiftmodule
  moddir="$slice/${PRODUCT}.framework/Modules/${PRODUCT}.swiftmodule"
  if [[ ! -d "$moddir" ]]; then
    echo "✗ Missing Swift modules directory in: $slice/${PRODUCT}.framework"
    missing=1
    continue
  fi
  if ! /usr/bin/find "$moddir" -type f \( -name '*.swiftmodule' -o -name '*.swiftinterface' \) -print -quit >/dev/null; then
    echo "✗ Missing Swift module/interface files in: $moddir"
    missing=1
  fi
done < <(/usr/bin/find "$OUT_XC" -type d -maxdepth 1 -mindepth 1 -print0)

if [[ $missing -ne 0 ]]; then
  echo "✗ XCFramework slices are missing Swift modules."
  echo "  Ensure the product is '.dynamic' in Package.swift and keep BUILD_LIBRARY_FOR_DISTRIBUTION=YES."
  exit 1
fi

# ---- Embed PrivacyInfo.xcprivacy if present ----
PRIVACY="$PKG_DIR/PrivacyInfo.xcprivacy"
if [[ -f "$PRIVACY" ]]; then
  echo "▶ Embedding PrivacyInfo.xcprivacy"
  for slice in "$OUT_XC"/*; do
    [[ -d "$slice" ]] || continue
    cp -f "$PRIVACY" "$slice/PrivacyInfo.xcprivacy"
  done
fi

echo "✓ Done → $OUT_XC"
echo "ℹ️ Logs:"
echo "   open \"$LOG_DIR/Archive-iOS.xcresult\""
echo "   open \"$LOG_DIR/Archive-Sim.xcresult\""
