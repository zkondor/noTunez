ARTIFACTS_DIR=${PWD}/_artifacts
AUTOGEN_DIR=_autogen
PROJECT_DIR="${AUTOGEN_DIR}/noTunez.xcodeproj"
SCHEME=noTunez

.PHONY: gen
gen:
	mkdir -p "${AUTOGEN_DIR}"
	cp Project.template.swift "${AUTOGEN_DIR}"/Project.swift && pushd "${AUTOGEN_DIR}" && tuist generate -n

.PHONY: build/release
build/release: ARG_CONFIGURATION=Release
build/release: _build

.PHONY: build/debug
build/debug: ARG_CONFIGURATION=Debug
build/debug: _build

.PHONY: clean
clean:
	rm -rf "${ARTIFACTS_DIR}" "${AUTOGEN_DIR}"

.PHONY: _build
_build:
	xcodebuild clean build -project "${PROJECT_DIR}" -scheme "${SCHEME}" -configuration "${ARG_CONFIGURATION}" -derivedDataPath "${ARTIFACTS_DIR}"

.PHONY: dist
dist: ARCHIVE_PATH="${ARTIFACTS_DIR}/${SCHEME}.xcarchive"
dist: PKG_PATH="${ARTIFACTS_DIR}/${SCHEME}.pkg"
dist: EXPORT_OPTS_PLIST="${AUTOGEN_DIR}"/export_options.plist
dist:
	xcodebuild archive -project "${PROJECT_DIR}" -scheme "${SCHEME}" -configuration Release -archivePath "${ARCHIVE_PATH}" -derivedDataPath "${ARTIFACTS_DIR}"
	./export_options.plist.sh "${EXPORT_OPTS_PLIST}"
	xcodebuild -exportArchive -archivePath "${ARCHIVE_PATH}" -exportPath "${PKG_PATH}" -exportOptionsPlist "${EXPORT_OPTS_PLIST}"
	pushd "${PKG_PATH}" && zip -r "${ARTIFACTS_DIR}/${SCHEME}.zip" "${SCHEME}.app" && popd

.PHONY: notarize-dist
notarize-dist: APPLE_ID ?= $(error APPLE_ID variable is not set, e.g.: foo@bar.com)
notarize-dist: KEYCHAIN_PROFILE ?= $(error KEYCHAIN_PROFILE is not set, e.g.: 'Notarytool')
notarize-dist: KEYCHAIN_PATH ?= $(error KEYCHAIN_PATH is not set, e.g.: '~/Library/Keychains/appledev.keychain-db')
notarize-dist:
	security unlock-keychain "${KEYCHAIN_PATH}"
	xcrun notarytool submit --apple-id ${APPLE_ID} --keychain-profile "${KEYCHAIN_PROFILE}" --keychain "${KEYCHAIN_PATH}" --wait "${ARTIFACTS_DIR}/${SCHEME}.zip"
