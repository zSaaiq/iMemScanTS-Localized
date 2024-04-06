TARGET_CODESIGN = $(shell which ldid)
TARGET_DPKG = 	  $(shell which dpkg)

APP_TMP         	= $(TMPDIR)/iMemScan-build
APP_BUNDLE_PATH 	= $(APP_TMP)/Build/Products/Release-iphoneos/iMemScan.app

all:
	xcodebuild -quiet -jobs $(shell sysctl -n hw.ncpu) -project 'iMemScan.xcodeproj' -scheme iMemScan -configuration Release -arch arm64 -sdk iphoneos -derivedDataPath $(APP_TMP) \
		CODE_SIGNING_ALLOWED=NO DSTROOT=$(APP_TMP)/install
		
	ldid -Sentitlements.plist $(APP_BUNDLE_PATH)/iMemScan
	rm -rf build
	mkdir -p build/Payload

	mv $(APP_BUNDLE_PATH) 	build/Payload

	# make TrollStore tipa
	@ln -sf build/Payload Payload
	zip -r9 iMemScanTS.tipa Payload
	@rm -rf Payload

	# lol
	find . -name ".DS_Store" -delete

	@rm -rf build

	@echo TrollStore .tipa written to build/iMemScanTS.tipa
