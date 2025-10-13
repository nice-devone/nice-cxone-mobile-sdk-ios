#!/usr/bin/env bash
set -euo pipefail

# Build an XCFramework from a Swift Package by ARCHIVING the package product.
# No -packagePath usage; run from anywhere.
#
# Usage (from package root that contains Package.swift):
#   ./scripts/build_spm_xcframework_min.sh . CXoneChatSDK
#
# Or with explicit paths:
#   ./scripts/build_spm_xcframework_min.sh "/abs/path/to/package" CXoneChatSDK Release "./XCOut" "./XCBuild"

PKG_DIR_RAW="${1:-.}"
PRODUCT="${2:-}"
CONFIG="${3:-Release}"
OUT_DIR="${4:-./XCOut}"
BUILD_DIR="${5:-./XCBuild}"

if [[ -z "$PRODUCT" ]]; then
  echo "Usage: $0 [/path/to/package] <ProductName> [Release|Debug] [OUT_DIR] [BUILD_DIR]"
  echo "Example: $0 . CXoneChatSDK"
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

# ---- Helpers ----
find_fw() {
  local arch_path="$1"
  local pf="$arch_path.xcarchive/Products/Library/Frameworks/PackageFrameworks/${PRODUCT}.framework"
  local f="$arch_path.xcarchive/Products/Library/Frameworks/${PRODUCT}.framework"
  if [[ -d "$pf" ]]; then echo "$pf"; return 0; fi
  if [[ -d "$f" ]]; then echo "$f"; return 0; fi
  /usr/bin/find "$arch_path.xcarchive/Products" -type d -name "${PRODUCT}.framework" -print -quit 2>/dev/null || true
}

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

# ---- Pre-clean (requested) ----
echo "▶ Pre-clean: removing .swiftpm, XCBuild, XCOut…"
rm -rf "$PKG_DIR/.swiftpm" "$ABS_BUILD" "$ABS_OUT" || true
mkdir -p "$ABS_OUT" "$ABS_BUILD" "$LOG_DIR"

echo "==== Environment ===="
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
echo "▶ Archive (iOS device)…"
xcodebuild archive \
  -scheme "$PRODUCT" \
  -configuration "$CONFIG" \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCH_IOS" \
  -derivedDataPath "$DERIVED" \
  -resultBundlePath "$LOG_DIR/Archive-iOS.xcresult" \
  -showBuildTimingSummary \
  "${COMMON_XCB_FLAGS[@]}"

FW_IOS="$(find_fw "$ARCH_IOS")"
if [[ -n "${FW_IOS:-}" ]]; then
  copy_swiftmodules "$BP_ROOT/Release-iphoneos" "$FW_IOS"
fi

# ---- Archive (simulator) ----
ARCH_SIM="$ABS_BUILD/${PRODUCT}-iOS-sim"
echo "▶ Archive (iOS Simulator)…"
xcodebuild archive \
  -scheme "$PRODUCT" \
  -configuration "$CONFIG" \
  -destination 'generic/platform=iOS Simulator' \
  -archivePath "$ARCH_SIM" \
  -derivedDataPath "$DERIVED" \
  -resultBundlePath "$LOG_DIR/Archive-Sim.xcresult" \
  -showBuildTimingSummary \
  "${COMMON_XCB_FLAGS[@]}"

FW_SIM="$(find_fw "$ARCH_SIM")"
if [[ -n "${FW_SIM:-}" ]]; then
  copy_swiftmodules "$BP_ROOT/Release-iphonesimulator" "$FW_SIM"
fi

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

# ---- Re-sync Swift modules into created slices (xcodebuild may drop .swiftmodule binaries)
echo "▶ Syncing Swift modules into XCFramework slices…"
for slice in "$OUT_XC"/*; do
  [[ -d "$slice" ]] || continue
  slice_fw="$slice/$(basename "$FW_IOS")"
  [[ -d "$slice_fw" ]] || slice_fw="$slice/$(basename "$FW_SIM")"
  source_fw="$FW_IOS"
  if [[ "$slice" == *simulator* ]]; then
    source_fw="$FW_SIM"
    slice_fw="$slice/$(basename "$FW_SIM")"
  fi
  if [[ ! -d "$slice_fw" ]]; then
    echo "⚠️  Unable to locate framework in slice: $slice"
    continue
  fi
  src_mod="$source_fw/Modules/${PRODUCT}.swiftmodule"
  dst_mod="$slice_fw/Modules/${PRODUCT}.swiftmodule"
  if [[ -d "$src_mod" ]]; then
    mkdir -p "$dst_mod"
    shopt -s nullglob
    /bin/cp -f "$src_mod"/* "$dst_mod/" 2>/dev/null || true
    shopt -u nullglob
  fi
done

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
