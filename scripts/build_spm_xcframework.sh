#!/usr/bin/env bash
set -euo pipefail

# Build an XCFramework from a Swift Package by ARCHIVING the package product.
# No -packagePath usage; runs inside the package root.
#
# Usage (from package root with Package.swift):
#   ./scripts/build_spm_xcframework_min.sh . CXoneChatSDK
#
# Or:
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
  BUILD_LIBRARY_FOR_DISTRIBUTION=NO
  SWIFT_VERIFY_EMITTED_MODULE_INTERFACE=NO
  VALIDATE_WORKSPACE=NO
  ENABLE_BITCODE=NO
)

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

popd >/dev/null

# ---- Find frameworks inside archives ----
find_fw() {
  local arch_path="$1"
  # Prefer PackageFrameworks then plain Frameworks
  local pf="$arch_path.xcarchive/Products/Library/Frameworks/PackageFrameworks/${PRODUCT}.framework"
  local f="$arch_path.xcarchive/Products/Library/Frameworks/${PRODUCT}.framework"
  if [[ -d "$pf" ]]; then echo "$pf"; return 0; fi
  if [[ -d "$f" ]]; then echo "$f"; return 0; fi
  # Fallback: scan just in case
  /usr/bin/find "$arch_path.xcarchive/Products" -type d -name "${PRODUCT}.framework" -print -quit 2>/dev/null || true
}

FW_IOS="$(find_fw "$ARCH_IOS")"
FW_SIM="$(find_fw "$ARCH_SIM")"

echo "▶ Located frameworks:"
echo "  device:    ${FW_IOS:-MISSING}"
echo "  simulator: ${FW_SIM:-MISSING}"

if [[ -z "${FW_IOS:-}" || -z "${FW_SIM:-}" ]]; then
  echo "✗ Could not find ${PRODUCT}.framework in one or both archives."
  echo "  Inspect:"
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
