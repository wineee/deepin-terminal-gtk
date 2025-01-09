{ stdenv
, nix-filter
, lib
, fetchFromGitHub
, cmake
, pkg-config
, gobject-introspection
, wrapGAppsHook
, wrapGAppsHook4
, vala
, libgee
, libwnck
, libsecret
, gtk3
, gtk4
, vte
, vte-gtk4
, glib
, json-glib
, gnutls
, pcre2
, gtkVersion ? "3"
}:

stdenv.mkDerivation rec {
  pname = "deepin-terminal-gtk";
  version = "5.1.0";

  src = nix-filter.lib.filter {
    root = ./..;

    exclude = [
      ".git"
      "LICENSE"
      "README.md"
      "project_path.c"
      (nix-filter.lib.matchExt "nix")
    ];
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    gobject-introspection
    vala
    (if gtkVersion == "3" then wrapGAppsHook else wrapGAppsHook4)
  ];

  buildInputs = [
    libgee
    libsecret
    glib
    json-glib
    gnutls
    pcre2
  ] 
  ++ lib.optionals (gtkVersion == "3") [ gtk3 vte libwnck ]
  ++ lib.optionals (gtkVersion == "4") [ gtk4 vte-gtk4 ];

  cmakeFlags = [
    "-DUSE_GTK4=${if gtkVersion=="4" then "ON" else "OFF" }"
  ];

  meta = {
    description = "DDE terminal emulator application";
    homepage = "https://github.com/dwapp/deepin-terminal-gtk";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ rewine ];
  };
}

