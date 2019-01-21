{ stdenv, fetchurl, fetchpatch, meson, ninja
, pkgconfig, gettext, gobject-introspection
, bison, flex, python3, glib, makeWrapper
, libcap,libunwind, darwin
, elfutils # for libdw
, bash-completion
, docbook_xsl, docbook_xml_dtd_412
, gtk-doc
, lib
}:

stdenv.mkDerivation rec {
  name = "gstreamer-${version}";
  version = "1.15.1";

  meta = with lib ;{
    description = "Open source multimedia framework";
    homepage = https://gstreamer.freedesktop.org;
    license = licenses.lgpl2Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ ttuegel matthewbauer ];
  };

  src = fetchurl {
    url = "${meta.homepage}/src/gstreamer/${name}.tar.xz";
    sha256 = "05ri9y37qkgvkb2xjywf32c3k9479b0af0m6cjigx04pgwsf42kq";
  };

  patches = [
    ./fix_pkgconfig_includedir.patch
  ];

  outputs = [ "out" "dev" ];
  outputBin = "dev";

  nativeBuildInputs = [
    meson ninja pkgconfig gettext bison flex python3 makeWrapper gobject-introspection
    bash-completion
    gtk-doc
    # Without these, enabling the 'gtk_doc' gives us `FAILED: meson-install`
    docbook_xsl docbook_xml_dtd_412
  ];

  buildInputs =
       lib.optionals stdenv.isLinux [ libcap libunwind elfutils ]
    ++ lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.CoreServices;

  propagatedBuildInputs = [ glib ];

  mesonFlags = [
    # Enables all features, so that we know when new dependencies are necessary.
    "-Dauto_features=enabled"
    "-Dexamples=disabled" # requires many dependencies and probably not useful for our users
  ];

  postInstall = ''
    for prog in "$dev/bin/"*; do
        wrapProgram "$prog" --suffix GST_PLUGIN_SYSTEM_PATH : "\$(unset _tmp; for profile in \$NIX_PROFILES; do _tmp="\$profile/lib/gstreamer-1.0''$\{_tmp:+:\}\$_tmp"; done; printf "\$_tmp")"
    done
  '';

  preConfigure= ''
    patchShebangs .
  '';

  preFixup = ''
    moveToOutput "share/bash-completion" "$dev"
  '';

  setupHook = ./setup-hook.sh;
}
