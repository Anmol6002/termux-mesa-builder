
TERMUX_PKG_HOMEPAGE=https://github.com/SaschaWillems/Vulkan
TERMUX_PKG_DESCRIPTION="C++ Vulkan examples and demos"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="LICENSE.md"
TERMUX_PKG_MAINTAINER="@termux"

_COMMIT=b6ee8dc2dd275dcad4a1539b8b82eedef8487a85
_COMMIT_DATE=20260502
TERMUX_PKG_VERSION=0.0.${_COMMIT_DATE}

TERMUX_PKG_SRCURL=git+https://github.com/SaschaWillems/Vulkan.git
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_SHA256=SKIP_CHECKSUM

TERMUX_PKG_DEPENDS="libc++, libxcb, vulkan-loader"
TERMUX_PKG_BUILD_DEPENDS="glslang, spirv-tools, vulkan-headers, vulkan-loader-generic"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DRESOURCE_INSTALL_DIR=${TERMUX_PREFIX}/share/sascha-vulkan
-DFORCE_VALIDATION=OFF
"

termux_step_post_get_source() {
	# Fetch the full git history so we can check out historical commits
	git fetch --unshallow || true
	git checkout "${_COMMIT}"
	git submodule update --init --recursive
}

termux_step_make_install() {
	mkdir -p \
		"${TERMUX_PREFIX}/libexec/sascha-vulkan" \
		"${TERMUX_PREFIX}/share/sascha-vulkan"

	cp -a "${TERMUX_PKG_BUILDDIR}/bin/." \
		"${TERMUX_PREFIX}/libexec/sascha-vulkan/"

	cp -a "${TERMUX_PKG_SRCDIR}/assets/." \
		"${TERMUX_PREFIX}/share/sascha-vulkan/"

	cp -a "${TERMUX_PKG_SRCDIR}/shaders" \
		"${TERMUX_PREFIX}/share/sascha-vulkan/"
}

termux_step_post_make_install() {
	local f name

	for f in "${TERMUX_PREFIX}"/libexec/sascha-vulkan/*; do
		[ -f "${f}" ] || continue
		[ -x "${f}" ] || continue

		name="$(basename "${f}")"

		cat > "${TERMUX_PREFIX}/bin/sascha-${name}" <<-WRAPPER
		#!${TERMUX_PREFIX}/bin/sh
		exec "${TERMUX_PREFIX}/libexec/sascha-vulkan/${name}" "\$@"
		WRAPPER

		chmod 755 "${TERMUX_PREFIX}/bin/sascha-${name}"
	done
}
