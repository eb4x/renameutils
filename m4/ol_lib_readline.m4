dnl @synopsis OL_LIB_READLINE
dnl
dnl A modified version of VL_LIB_READLINE found in the GNU ac-archive
dnl (http://www.gnu.org/software/ac-archive) and the SF ac-archive
dnl (http://ac-archive.sourceforge.net/). Don't set LIBS, set
dnl READLINE_LIBS instead.
dnl
dnl Searches for a readline compatible library.  If found, defines
dnl `HAVE_LIBREADLINE'.  If the found library has the `add_history'
dnl function, sets also `HAVE_READLINE_HISTORY'.  Also checks for the
dnl locations of the necessary include files and sets `HAVE_READLINE_H'
dnl or `HAVE_READLINE_READLINE_H' and `HAVE_READLINE_HISTORY_H' or
dnl 'HAVE_HISTORY_H' if the corresponding include files exists.
dnl
dnl The libraries that may be readline compatible are `libedit',
dnl `libeditline' and `libreadline'.  Sometimes we need to link a termcap
dnl library for readline to work, this macro tests these cases too by
dnl trying to link with `libtermcap', `libcurses' or `libncurses' before
dnl giving up.
dnl
dnl Here is an example of how to use the information provided by this
dnl macro to perform the necessary includes or declarations in a C file:
dnl
dnl   #ifdef HAVE_LIBREADLINE
dnl   #  if defined(HAVE_READLINE_READLINE_H)
dnl   #    include <readline/readline.h>
dnl   #  elif defined(HAVE_READLINE_H)
dnl   #    include <readline.h>
dnl   #  else /* !defined(HAVE_READLINE_H) */
dnl   extern char *readline ();
dnl   #  endif /* !defined(HAVE_READLINE_H) */
dnl   char *cmdline = NULL;
dnl   #else /* !defined(HAVE_READLINE_READLINE_H) */
dnl     /* no readline */
dnl   #endif /* HAVE_LIBREADLINE */
dnl
dnl   #ifdef HAVE_READLINE_HISTORY
dnl   #  if defined(HAVE_READLINE_HISTORY_H)
dnl   #    include <readline/history.h>
dnl   #  elif defined(HAVE_HISTORY_H)
dnl   #    include <history.h>
dnl   #  else /* !defined(HAVE_HISTORY_H) */
dnl   extern void add_history ();
dnl   extern int write_history ();
dnl   extern int read_history ();
dnl   #  endif /* defined(HAVE_READLINE_HISTORY_H) */
dnl     /* no history */
dnl   #endif /* HAVE_READLINE_HISTORY */
dnl
dnl
dnl @originalversion 1.1
dnl @originalauthor Ville Laurikari <vl@iki.fi>
dnl @version 1.3
dnl @author Oskar Liljeblad <oskar@osk.mine.nu>
dnl
AC_DEFUN([OL_LIB_READLINE], [
  AC_CACHE_CHECK([for a readline compatible library],
                 [ol_cv_lib_readline], [
    ORIG_LIBS="$LIBS"
    for readline_lib in readline edit editline; do
      for termcap_lib in "" termcap curses ncurses; do
        if test -z "$termcap_lib"; then
          TRY_LIB="-l$readline_lib"
        else
          TRY_LIB="-l$readline_lib -l$termcap_lib"
        fi
        LIBS="$ORIG_LIBS $TRY_LIB"
        readline_libs="$ol_cv_lib_readline"
        AC_TRY_LINK_FUNC(readline, readline_libs="$TRY_LIB")
        if test -n "$readline_libs"; then
          break
        fi
      done
      if test -n "$readline_libs"; then
        break
      fi
    done

    if test -z "$readline_libs"; then
      ol_cv_lib_readline="no"
    else
      history_libs=""
      LIBS="$ORIG_LIBS -lhistory"
      AC_TRY_LINK_FUNC(add_history, history_libs="-lhistory")
      ol_cv_lib_readline="$readline_libs $history_libs"
    fi
    LIBS="$ORIG_LIBS"
  ])
  
  if test "$ol_cv_lib_readline" = "no"; then
    AC_SUBST(READLINE_LIBS, "")
  else
    AC_SUBST(READLINE_LIBS, "$ol_cv_lib_readline")
    AC_DEFINE(HAVE_LIBREADLINE, 1,
              [Define if you have a readline compatible library])
    AC_CHECK_HEADERS(readline.h readline/readline.h)
    AC_CACHE_CHECK([whether readline supports history],
                   ol_cv_lib_readline_history, [
      ol_cv_lib_readline_history="no"
      LIBS="$READLINE_LIBS"
      AC_TRY_LINK_FUNC(add_history, ol_cv_lib_readline_history="yes")
      LIBS="$ORIG_LIBS"
    ])
    if test "$ol_cv_lib_readline_history" = "yes"; then
      AC_DEFINE(HAVE_READLINE_HISTORY, 1,
                [Define if your readline library has \`add_history'])
      AC_CHECK_HEADERS(history.h readline/history.h)
    fi
  fi
])dnl
