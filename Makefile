.PHONY: build install clean aur-package

PKG_NAME := scratch-notes
PKG_DIR  := src-tauri
VERSION  := $(shell grep '^pkgver' $(PKG_DIR)/PKGBUILD | cut -d= -f2)

# Build the application (frontend + backend, no bundler)
build:
	@echo "Building $(PKG_NAME) $(VERSION)..."
	cd $(PKG_DIR) && npm install --ignore-scripts
	npm run build
	cd $(PKG_DIR) && cargo build --release --locked
	@echo "Build complete! Binary at src-tauri/target/release/Scratch"

# Run in development mode
dev:
	npm run tauri dev

# Build AUR package (PKGBUILD) - simplified approach
aur-package: build
	@echo "Creating package for $(PKG_NAME) $(VERSION)..."
	@rm -rf .aur-package
	@mkdir -p .aur-package/usr/bin
	@mkdir -p .aur-package/usr/share/applications
	@mkdir -p .aur-package/usr/share/icons/hicolor/128x128/apps
	@mkdir -p .aur-package/usr/share/metainfo
	@install -Dm755 $(PKG_DIR)/target/release/Scratch .aur-package/usr/bin/scratch
	@echo "[Desktop Entry]" > .aur-package/usr/share/applications/com.scratch.app.desktop
	@echo "Name=Scratch" >> .aur-package/usr/share/applications/com.scratch.app.desktop
	@echo "Comment=A minimalist, offline-first markdown note-taking app" >> .aur-package/usr/share/applications/com.scratch.app.desktop
	@echo "Exec=scratch %F" >> .aur-package/usr/share/applications/com.scratch.app.desktop
	@echo "Icon=com.scratch.app" >> .aur-package/usr/share/applications/com.scratch.app.desktop
	@echo "Type=Application" >> .aur-package/usr/share/applications/com.scratch.app.desktop
	@echo "Categories=Office;TextTools;Development;" >> .aur-package/usr/share/applications/com.scratch.app.desktop
	@echo "MimeType=text/markdown;text/x-markdown;" >> .aur-package/usr/share/applications/com.scratch.app.desktop
	@echo "Keywords=markdown;notes;writing;" >> .aur-package/usr/share/applications/com.scratch.app.desktop
	@echo "StartupWMClass=Scratch" >> .aur-package/usr/share/applications/com.scratch.app.desktop
	@install -Dm644 app-icon.png .aur-package/usr/share/icons/hicolor/128x128/apps/com.scratch.app.png
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '<component type="desktop-application">' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '  <id>com.scratch.app</id>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '  <name>Scratch</name>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '  <summary>A minimalist, offline-first markdown note-taking app</summary>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '  <description>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '    <p>A minimalist, offline-first markdown note-taking app for macOS, Windows, and Linux.</p>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '  </description>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '  <url type="homepage">https://github.com/erictli/scratch</url>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '  <project_license>MIT</project_license>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '  <content_rating type="oars-1.0"/>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '  <releases>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '    <release version="$(VERSION)" date="2026-06-04"/>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '  </releases>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@echo '</component>' >> .aur-package/usr/share/metainfo/com.scratch.app.metainfo.xml
	@cd .aur-package && tar czf ../$(PKG_DIR)/$(PKG_NAME)-$(VERSION)-x86_64.pkg.tar.gz *
	@rm -rf .aur-package
	@echo "Package created: $(PKG_DIR)/$(PKG_NAME)-$(VERSION)-x86_64.pkg.tar.gz"
	@echo "Install with: sudo tar xzf $(PKG_DIR)/$(PKG_NAME)-$(VERSION)-x86_64.pkg.tar.gz -C /"

# Build all distribution targets (deb, rpm)
bundle:
	@echo "Building bundles..."
	npm run tauri build

# Clean build artifacts
clean:
	cargo clean
	rm -rf node_modules dist
	rm -rf src-tauri/target src-tauri/AppDir

# Install the built binary system-wide
install:
	@echo "Installing Scratch to /usr/local/bin..."
	sudo install -Dm755 src-tauri/target/release/Scratch /usr/local/bin/scratch
	@echo "Installation complete. Run 'scratch' to start."
