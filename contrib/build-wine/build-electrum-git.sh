#!/bin/bash

NAME_ROOT=electrum

export PYTHONDONTWRITEBYTECODE=1  # don't create __pycache__/ folders with .pyc files


# Let's begin!
set -e

. "$CONTRIB"/build_tools_util.sh

pushd $WINEPREFIX/drive_c/electrum

VERSION=$(git describe --tags --dirty --always)
info "Last commit: $VERSION"

# Load electrum-locale for this release
git submodule update --init

LOCALE="$WINEPREFIX/drive_c/electrum/electrum/locale/"
# we want the binary to have only compiled (.mo) locale files; not source (.po) files
rm -rf "$LOCALE"
"$CONTRIB/build_locale.sh" "$CONTRIB/deterministic-build/electrum-locale/locale/" "$LOCALE"

find -exec touch -h -d '2000-11-11T11:11:11+00:00' {} +
popd


# opt out of compiling C extensions
export AIOHTTP_NO_EXTENSIONS=1
export YARL_NO_EXTENSIONS=1
export MULTIDICT_NO_EXTENSIONS=1
export FROZENLIST_NO_EXTENSIONS=1

info "Installing requirements..."
$WINE_PYTHON -m pip install --no-build-isolation --no-dependencies --no-binary :all: --no-warn-script-location \
    --cache-dir "$WINE_PIP_CACHE_DIR" -r "$CONTRIB"/deterministic-build/requirements.txt
info "Installing dependencies specific to binaries..."
# TODO tighten "--no-binary :all:" (but we don't have a C compiler...)
$WINE_PYTHON -m pip install --no-build-isolation --no-dependencies --no-warn-script-location \
    --no-binary :all: --only-binary cffi,cryptography,PyQt5,PyQt5-Qt5,PyQt5-sip \
    --cache-dir "$WINE_PIP_CACHE_DIR" -r "$CONTRIB"/deterministic-build/requirements-binaries.txt
info "Installing hardware wallet requirements..."
$WINE_PYTHON -m pip install --no-build-isolation --no-dependencies --no-warn-script-location \
    --no-binary :all: --only-binary cffi,cryptography,hidapi \
    --cache-dir "$WINE_PIP_CACHE_DIR" -r "$CONTRIB"/deterministic-build/requirements-hw.txt

info "Installing pre-built Dimecoin requirements..."
pivx_quark_hash="pivx_quark_hash-1.2-cp311-cp311-win32.whl"
quark_hash="quark_hash-1.0-cp311-cp311-win32.whl"

PIVX_QUARK_HASH_PATH="/opt/wine64/drive_c/electrum/contrib/build-wine/.cache/win32/build/$pivx_quark_hash"
QUARK_HASH_PATH="/opt/wine64/drive_c/electrum/contrib/build-wine/.cache/win32/build/$quark_hash"

download_if_not_exist "$PIVX_QUARK_HASH_PATH" "https://github.com/dime-coin/dime-pyd-wheels/raw/main/$pivx_quark_hash"
verify_hash "$PIVX_QUARK_HASH_PATH" "00ba4e675d9a4e1e6c336d9d06125067ee037731d55ede4782b837a0ededa73d"
download_if_not_exist "$QUARK_HASH_PATH" "https://github.com/dime-coin/dime-pyd-wheels/raw/main/$quark_hash"
verify_hash "$QUARK_HASH_PATH" "17c9f70ceb8a53208056f029baf1100a5d21b65450fe376f18c56e69b8800041"

# Convert Unix-style paths to Windows-style for Wine
PIVX_QUARK_HASH_WIN_PATH=$(echo "$PIVX_QUARK_HASH_PATH" | sed 's#/opt/wine64/drive_c#C:\\#')
QUARK_HASH_WIN_PATH=$(echo "$QUARK_HASH_PATH" | sed 's#/opt/wine64/drive_c#C:\\#')

# Debug: Check if the files exist at the converted paths
if [ ! -f "$PIVX_QUARK_HASH_WIN_PATH" ]; then
    echo "File not found: $PIVX_QUARK_HASH_WIN_PATH"
else
    echo "File found: $PIVX_QUARK_HASH_WIN_PATH"
fi

if [ ! -f "$QUARK_HASH_WIN_PATH" ]; then
    echo "File not found: $QUARK_HASH_WIN_PATH"
else
    echo "File found: $QUARK_HASH_WIN_PATH"
fi

# Proceed with installation
$WINE_PYTHON -m pip install --no-warn-script-location --cache-dir "$WINE_PIP_CACHE_DIR" "$PIVX_QUARK_HASH_WIN_PATH"
$WINE_PYTHON -m pip install --no-warn-script-location --cache-dir "$WINE_PIP_CACHE_DIR" "$QUARK_HASH_WIN_PATH"   

pushd $WINEPREFIX/drive_c/electrum
# see https://github.com/pypa/pip/issues/2195 -- pip makes a copy of the entire directory
info "Pip installing Electrum-Dime. This might take a long time if the project folder is large."
$WINE_PYTHON -m pip install --no-build-isolation --no-dependencies --no-warn-script-location .
# pyinstaller needs to be able to "import electrum", for which we need libsecp256k1:
# (or could try "pip install -e" instead)
cp electrum/libsecp256k1-*.dll "$WINEPREFIX/drive_c/python3/Lib/site-packages/electrum/"
popd


rm -rf dist/

# build standalone and portable versions
info "Running pyinstaller..."
ELECTRUM_CMDLINE_NAME="$NAME_ROOT-$VERSION" wine "$WINE_PYHOME/scripts/pyinstaller.exe" --noconfirm --ascii --clean deterministic.spec

# set timestamps in dist, in order to make the installer reproducible
pushd dist
find -exec touch -h -d '2000-11-11T11:11:11+00:00' {} +
popd

info "building NSIS installer"
# $VERSION could be passed to the electrum.nsi script, but this would require some rewriting in the script itself.
makensis -DPRODUCT_VERSION=$VERSION electrum.nsi

cd dist
mv electrum-setup.exe $NAME_ROOT-$VERSION-setup.exe
cd ..

info "Padding binaries to 8-byte boundaries, and fixing COFF image checksum in PE header"
# note: 8-byte boundary padding is what osslsigncode uses:
#       https://github.com/mtrojnar/osslsigncode/blob/6c8ec4427a0f27c145973450def818e35d4436f6/osslsigncode.c#L3047
(
    cd dist
    for binary_file in ./*.exe; do
        info ">> fixing $binary_file..."
        # code based on https://github.com/erocarrera/pefile/blob/bbf28920a71248ed5c656c81e119779c131d9bd4/pefile.py#L5877
        python3 <<EOF
pe_file = "$binary_file"
with open(pe_file, "rb") as f:
    binary = bytearray(f.read())
pe_offset = int.from_bytes(binary[0x3c:0x3c+4], byteorder="little")
checksum_offset = pe_offset + 88
checksum = 0

# Pad data to 8-byte boundary.
remainder = len(binary) % 8
binary += bytes(8 - remainder)

for i in range(len(binary) // 4):
    if i == checksum_offset // 4:  # Skip the checksum field
        continue
    dword = int.from_bytes(binary[i*4:i*4+4], byteorder="little")
    checksum = (checksum & 0xffffffff) + dword + (checksum >> 32)
    if checksum > 2 ** 32:
        checksum = (checksum & 0xffffffff) + (checksum >> 32)

checksum = (checksum & 0xffff) + (checksum >> 16)
checksum = (checksum) + (checksum >> 16)
checksum = checksum & 0xffff
checksum += len(binary)

# Set the checksum
binary[checksum_offset : checksum_offset + 4] = int.to_bytes(checksum, byteorder="little", length=4)

with open(pe_file, "wb") as f:
    f.write(binary)
EOF
    done
)

sha256sum dist/electrum*.exe
