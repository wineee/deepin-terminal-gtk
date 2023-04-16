{ stdenv
, nix-filter
, lib
, fetchFromGitHub
, cmake
, pkg-config
, gobject-introspection
, wrapGAppsHook
, vala
, libgee
, libwnck
, libsecret
, gtk3
, vte
, glib
, json-glib
, gnutls
, pcre2
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
    wrapGAppsHook
    vala
  ];

  buildInputs = [
    libgee
    libwnck
    libsecret
    gtk3
    vte
    glib
    json-glib
    gnutls
    pcre2
  ];

  meta = with lib; {
    description = "DDE terminal emulator application";
    homepage = "https://github.com/wineee/deepin-terminal-gtk";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
}

