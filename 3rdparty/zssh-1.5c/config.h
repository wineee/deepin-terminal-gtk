/* config.h.  Generated automatically by configure.  */
/* config.h.in.  Generated automatically from configure.in by autoheader 2.13.  */
/*
 ** acconfig.h
 ** 
 ** Made by (Matthieu Lucotte)
 ** Login   <gounter@users.sourceforge.net>
 ** 
 ** Started on  Sat Oct  6 02:21:45 2001 Matthieu Lucotte
 ** Last update Thu Oct 11 16:51:21 2001 Matthieu Lucotte
 */

/*
 * acconfig.h  - template used by autoheader to create config.h.in
 * config.h.in - used by autoconf to create config.h
 * config.h    - created by autoconf; contains defines generated by autoconf
 */


/* Define if the `getpgrp' function takes no argument.  */
#define GETPGRP_VOID 1

/* Define if you have <sys/wait.h> that is POSIX.1 compatible.  */
#define HAVE_SYS_WAIT_H 1

/* Define as the return type of signal handlers (int or void).  */
#define RETSIGTYPE void

/* Define if you have the ANSI C header files.  */
#define STDC_HEADERS 1

/* Define if you have SYSV-style /dev/ptmx and /dev/pts/. */
#define HAVE_DEV_PTMX 1

/* Define this if you have getpseudotty() (DYNIX/ptx 2.1) */
/* #undef HAVE_GETPSEUDOTTY */

/* Define if you have /dev/pts and /dev/ptc devices (as in AIX). */
/* #undef HAVE_DEV_PTS_AND_PTC */

/* Define this if you have sco-style pty:s (ptyp0, ..., ptyp9, ptyp10...) */
/* #undef HAVE_DEV_PTYP10 */

/* Define this if you have libreadline v4.2 or greater */
/* #undef HAVE_READLINE_4_2_OR_GREATER */

/* Define if you have the _getpty function.  */
/* #undef HAVE__GETPTY */

/* Define if you have the getpseudotty function.  */
/* #undef HAVE_GETPSEUDOTTY */

/* Define if you have the getpt function.  */
#define HAVE_GETPT 1

/* Define if you have the grantpt function.  */
#define HAVE_GRANTPT 1

/* Define if you have the isastream function.  */
#define HAVE_ISASTREAM 1

/* Define if you have the openpty function.  */
/* #undef HAVE_OPENPTY */

/* Define if you have the strdup function.  */
#define HAVE_STRDUP 1

/* Define if you have the tcsetpgrp function.  */
#define HAVE_TCSETPGRP 1

/* Define if you have the unlockpt function.  */
#define HAVE_UNLOCKPT 1

/* Define if you have the <err.h> header file.  */
#define HAVE_ERR_H 1

/* Define if you have the <fcntl.h> header file.  */
#define HAVE_FCNTL_H 1

/* Define if you have the <paths.h> header file.  */
#define HAVE_PATHS_H 1

/* Define if you have the <readline/history.h> header file.  */
/* #undef HAVE_READLINE_HISTORY_H */

/* Define if you have the <readline/readline.h> header file.  */
/* #undef HAVE_READLINE_READLINE_H */

/* Define if you have the <stropts.h> header file.  */
#define HAVE_STROPTS_H 1

/* Define if you have the <sys/cdefs.h> header file.  */
#define HAVE_SYS_CDEFS_H 1

/* Define if you have the <sys/ioctl.h> header file.  */
#define HAVE_SYS_IOCTL_H 1

/* Define if you have the <sys/param.h> header file.  */
#define HAVE_SYS_PARAM_H 1

/* Define if you have the <sys/time.h> header file.  */
#define HAVE_SYS_TIME_H 1

/* Define if you have the <termios.h> header file.  */
#define HAVE_TERMIOS_H 1

/* Define if you have the <unistd.h> header file.  */
#define HAVE_UNISTD_H 1

/* Define if you have the <util.h> header file.  */
/* #undef HAVE_UTIL_H */

/* Define if you have the readline library (-lreadline).  */
/* #undef HAVE_LIBREADLINE */