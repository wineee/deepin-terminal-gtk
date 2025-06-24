cmake_minimum_required(VERSION 3.25)

project(deepin-terminal-gtk
    VERSION 5.1.1
    DESCRIPTION "DDE terminal emulator application"
    HOMEPAGE_URL "https://github.com/dwapp/deepin-terminal-gtk"
    LANGUAGES C
)

set(target deepin-terminal-gtk)

option(TEST_BUILD "Build local for test without install" OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
# C standard can be overridden when this is used as a sub-project.
if(NOT CMAKE_C_STANDARD)
  # This project can use C11, but will gracefully decay down to C99.
  set(CMAKE_C_STANDARD 11)
  set(CMAKE_C_STANDARD_REQUIRED OFF)
  set(CMAKE_C_EXTENSIONS OFF)
endif(NOT CMAKE_C_STANDARD)

# Enabled PIE binaries by default if supported.
include(CheckPIESupported OPTIONAL RESULT_VARIABLE CHECK_PIE_SUPPORTED)
if (CHECK_PIE_SUPPORTED)
  check_pie_supported(LANGUAGES C)
  if (CMAKE_C_LINK_PIE_SUPPORTED)
    set (CMAKE_POSITION_INDEPENDENT_CODE TRUE)
  endif ()
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(ExternalProject)
include(ValaPrecompile)
include(ValaVersion)
include(GNUInstallDirs)

find_package(Vala REQUIRED)
ensure_vala_version("0.40.0" MINIMUM)
find_package(PkgConfig REQUIRED)
find_package(X11 REQUIRED)
find_package(Gettext REQUIRED)
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

pkg_check_modules(GEE REQUIRED IMPORTED_TARGET gee-0.8)
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-unix-2.0)
pkg_check_modules(RSVG REQUIRED IMPORTED_TARGET librsvg-2.0>=2.52)
pkg_check_modules(FONTCONFIG REQUIRED IMPORTED_TARGET fontconfig)
pkg_check_modules(GLIB REQUIRED glib-2.0>=2.48)
pkg_check_modules(LIBSECRET REQUIRED IMPORTED_TARGET libsecret-1)
pkg_check_modules(PCRE REQUIRED IMPORTED_TARGET libpcre2-8)
pkg_check_modules(GNUTLS REQUIRED IMPORTED_TARGET gnutls)
pkg_check_modules(JsonGlib REQUIRED IMPORTED_TARGET json-glib-1.0)

# GTK4 and VTE4
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk4>=4.10.0)
pkg_check_modules(VTE REQUIRED IMPORTED_TARGET vte-2.91-gtk4>=0.69.0)

# There're 3 releases for 0.59.x, only 0.59.0 keeps old behaviour
if("${VTE_VERSION}" VERSION_GREATER "0.59.0")
    list(APPEND ARGS_DEFINITIONS "VTE_0_60")
endif()

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/constant.vala.in
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/constant.vala
)

if(TEST_BUILD)
    message("set project_path to native test")
    list(APPEND ARGS_DEFINITIONS "TEST_BUILD")
	set(PROJECT_PATH ${CMAKE_SOURCE_DIR})
else()
    message("set project_path to ${CMAKE_INSTALL_PREFIX}")
	set(PROJECT_PATH ${CMAKE_INSTALL_PREFIX})
endif()

set(SCRIPT_INSTALL_DIR ${CMAKE_INSTALL_FULL_LIBEXECDIR}/${target})
set(LOCALE_INSTALL_DIR ${CMAKE_INSTALL_FULL_DATADIR}/locale)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/project_path.c.in ${CMAKE_CURRENT_SOURCE_DIR}/project_path.c @ONLY)

SET(APP_SOURCES, "")
FILE(GLOB valalist LIST_FILES true */*.vala)
FOREACH(child ${valalist})
	file(RELATIVE_PATH
		file_path
		${CMAKE_SOURCE_DIR}
		${child}
	)
	set (APP_SOURCES ${APP_SOURCES} ${file_path})
ENDFOREACH()

set(VALA_PRECOMPILE_PACKAGES
	gee-0.8
	json-glib-1.0
	gio-2.0
	posix
	libsecret-1
	glib-2.0
	librsvg-2.0
	gtk4
	vte-2.91-gtk4
)

vala_precompile(VALA_C ./main.vala ${APP_SOURCES}
	        PACKAGES ${VALA_PRECOMPILE_PACKAGES})

add_executable(${target}
	${VALA_C}
	${CMAKE_SOURCE_DIR}/project_path.c
	${CMAKE_SOURCE_DIR}/lib/font.c)

target_compile_definitions(${target}
    PRIVATE
    GETTEXT_PACKAGE="${target}"
    LOCALEDIR="${LOCALE_INSTALL_DIR}"
    _XOPEN_SOURCE=700 # https://gitlab.gnome.org/GNOME/gnome-user-share/-/merge_requests/27
)

target_compile_options(${target}
    PRIVATE
    -s -w
)

target_link_libraries(${target}
	X11::X11
	PkgConfig::VTE
	PkgConfig::GEE
	PkgConfig::GIO
	PkgConfig::GNUTLS
	PkgConfig::GTK
	PkgConfig::RSVG
	PkgConfig::LIBSECRET
	PkgConfig::PCRE
	PkgConfig::FONTCONFIG
	PkgConfig::JsonGlib
	Threads::Threads
	m
	z
)

FILE(GLOB children LIST_DIRECTORIES true po/*)
SET(dirlist "")

FOREACH(child ${children})
	IF(IS_DIRECTORY ${child})
		get_filename_component(childdir ${child} NAME)
		LIST(APPEND dirlist ${childdir})
	ENDIF()
ENDFOREACH()

FOREACH(lang ${dirlist})
	SET(gmoFiles)
	FOREACH(current_PO_FILE po/${lang}/LC_MESSAGES/deepin-terminal-gtk.po)
    	  SET(gmoFile ${CMAKE_CURRENT_BINARY_DIR}/${lang}-${target}.gmo)
    	  ADD_CUSTOM_COMMAND(OUTPUT ${gmoFile}
    	        COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} -o ${gmoFile} ${current_PO_FILE}
    	        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    	        DEPENDS ${current_PO_FILE}
    	     )
    	  INSTALL(FILES ${gmoFile} DESTINATION ${LOCALE_INSTALL_DIR}/${lang}/LC_MESSAGES/  RENAME ${target}.mo)

    	  LIST(APPEND gmoFiles ${gmoFile})
    ENDFOREACH(current_PO_FILE)

    ADD_CUSTOM_TARGET(${lang} ALL DEPENDS ${gmoFiles})

ENDFOREACH(lang)

INSTALL (TARGETS ${target} DESTINATION ${CMAKE_INSTALL_BINDIR})
INSTALL (PROGRAMS ssh_login.sh DESTINATION ${SCRIPT_INSTALL_DIR})
INSTALL (DIRECTORY hicolor DESTINATION ${CMAKE_INSTALL_DATADIR}/icons)
INSTALL (DIRECTORY image DESTINATION ${CMAKE_INSTALL_DATADIR}/${target} FILES_MATCHING PATTERN "*.png")
INSTALL (DIRECTORY image DESTINATION ${CMAKE_INSTALL_DATADIR}/${target} FILES_MATCHING PATTERN "*.svg")
INSTALL (DIRECTORY theme DESTINATION ${CMAKE_INSTALL_DATADIR}/${target} FILES_MATCHING PATTERN "*")
INSTALL (FILES style.css DESTINATION ${CMAKE_INSTALL_DATADIR}/${target})
INSTALL (FILES ${target}.desktop DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
