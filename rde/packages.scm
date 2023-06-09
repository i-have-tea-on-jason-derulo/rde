(define-module (rde packages)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages man)
  #:use-module (srfi srfi-1)

  #:use-module (guix diagnostics)
  #:use-module (guix i18n)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:))

(define (search-patch file-name)
  "Search the patch FILE-NAME.  Raise an error if not found."
  (or (search-path (%rde-patch-path) file-name)
      (raise (formatted-message (G_ "~a: patch not found")
                                file-name))))

(define-syntax-rule (search-patches file-name ...)
  "Return the list of absolute file names corresponding to each
FILE-NAME found in %PATCH-PATH."
  (list (search-patch file-name) ...))

(define %channel-root
  (find (lambda (path)
          (file-exists? (string-append path "/rde/packages.scm")))
        %load-path))

(define %rde-patch-path
  (make-parameter
   (append
    (list (string-append %channel-root "rde/packages/patches"))
    (%patch-path))))

;; https://git.savannah.gnu.org/cgit/emacs.git/log/?h=feature/pgtk
;; ((cd $HOME/git/sys/emacs) || git clone https://git.savannah.gnu.org/cgit/emacs.git $HOME/git/sys/emacs) && cd $HOME/git/sys/emacs
;; git checkout feature/pgtk
;; git rev-parse HEAD
;; => b4204bdae83695089a27141602a955339df78b7a
;; guix hash -rx .
;; => 0drpms07231zc4w9g7gikwm5zlgrzdw8vbq853rlb7wqk3xg6gyq
;;
;; NOTE in the logs when building, we are missing `git' (rev-parse on something)

(use-modules (gnu packages emacs))
(use-modules (guix utils))

(define-public emacs-next-pgtk-latest
  (let ((commit "172c055745b1eb32def7be8ddcaae975996a789f")
        (revision "1"))
    (package
      (inherit emacs-next-pgtk)
      (name "emacs-next-pgtk-latest")
      (version (git-version "29.0.50" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://git.savannah.gnu.org/git/emacs.git/")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "00qikl80lly6nz15b7pp7gpy28iw7fci05q6k1il20fkdx27fp4x"))))
      (arguments
       (substitute-keyword-arguments (package-arguments emacs-next)
         ((#:configure-flags flags ''())
          `(cons* "--with-pgtk" ,flags))))
      ;; (propagated-inputs
      ;;  (list gsettings-desktop-schemas glib-networking))
      (inputs
       (package-inputs emacs-next))
      )))

(use-modules (gnu packages emacs-xyz)
             (guix build-system emacs))

(define-public emacs-cyrillic-dvorak-im
  (package
    (name "emacs-cyrillic-dvorak-im")
    (version "0.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/xFA25E/cyrillic-dvorak-im")
             (commit version)))
       (sha256
        (base32 "12adszd4p9i9glx2chasgq68i6cnxcrwbf5c268jjb5dw4q7ci0n"))
       (file-name (git-file-name name version))))
    (build-system emacs-build-system)
    (home-page "https://github.com/xFA25E/cyrillic-dvorak-im")
    (synopsis "Cyrillic input method for dvorak layout")
    (description "Cyrillic input method for dvorak layout.")
    (license license:gpl3+)))

(define-public emacs-mini-frame
  (package
   (inherit emacs-unfill)
   (name "emacs-mini-frame")
   (version "1.0.0")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/muffinmad/emacs-mini-frame.git")
                  (commit "41afb3d79cd269726e955ef0896dc077562de0f5")))
            (file-name (git-file-name name version))
            (sha256
             (base32
              "0yghz9pdjsm9v6lbjckm6c5h9ak7iylx8sqgyjwl6nihkpvv4jyp"))))))

(define-public emacs-perfect-margin
  (package
    (name "emacs-perfect-margin")
    (version "0.1")
    (home-page "https://github.com/mpwang/perfect-margin")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url home-page)
              (commit "94b055c743b1859098870c8aca3e915bd6e67d9d")))
       (sha256
        (base32 "02k379nig43j85wfm327pw6sh61kxrs1gwz0vgcbx9san4dp83bk"))))
    (build-system emacs-build-system)
    (synopsis "A global margin-making-mode, great for ultrawides")
    (description
     "[emacs] auto center emacs windows, work with minimap and/or linum-mode")
    (license license:gpl3+)))

(define-public emacs-es-mode
  (package
    (name "emacs-es-mode")
    (version "4.3.0.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/dakrone/es-mode")
             (commit "cde5cafcbbbd57db6d38ae7452de626305bba68d")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "02zzwf9ykfi2dggjbspg7mk77b5x1fnkpp3bcp6rd4h95apnsjq5"))))
    (build-system emacs-build-system)
    (propagated-inputs
     ;; The version of org in Emacs 24.5 is not sufficient, and causes tables
     ;; to be rendered incorrectly
     `(("emacs-dash" ,emacs-dash)
       ("emacs-org" ,emacs-org)
       ("emacs-spark" ,emacs-spark)
       ("emacs-s" ,emacs-s)
       ("emacs-request" ,emacs-request)))
    (home-page "https://github.com/dakrone/es-mode")
    (synopsis "Major mode for editing Elasticsearch queries")
    (description "@code{es-mode} includes highlighting, completion and
indentation support for Elasticsearch queries.  Also supported are
@code{es-mode} blocks in @code{org-mode}, for which the results of queries can
be processed through @code{jq}, or in the case of aggregations, can be
rendered in to a table.  In addition, there is an @code{es-command-center}
mode, which displays information about Elasticsearch clusters.")
    (license license:gpl3+)))

(define-public emacs-hide-header-line
  (package
   (inherit emacs-hide-mode-line)
   (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'make-it-update-header-line
           (lambda* (#:key outputs #:allow-other-keys)
             (substitute* "hide-mode-line.el"
               ((" mode-line-format")
                " header-line-format"))
             #t)))))))

(use-modules (gnu packages shellutils)
             (guix utils))
(define-public zsh-autosuggestions-latest
  (package
   (inherit zsh-autosuggestions)
   (name "zsh-autosuggestions")
   (version "0.7.0")
   (arguments
    (substitute-keyword-arguments (package-arguments zsh-autosuggestions)
      ((#:phases phases)
       `(modify-phases ,phases
        (delete 'check)))))
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/zsh-users/zsh-autosuggestions")
                  (commit (string-append "v" version))))
            (file-name (git-file-name name version))
            (sha256
             (base32
              "1g3pij5qn2j7v7jjac2a63lxd97mcsgw6xq6k5p7835q9fjiid98"))))))

(use-modules (guix build-system emacs)
             (gnu packages mail)
             (gnu packages texinfo))
(define-public emacs-git-email-latest
  (let* ((commit "b5ebade3a48dc0ce0c85699f25800808233c73be")
         (revision "0"))
    (package
      (name "emacs-git-email")
      (version (git-version "0.2.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://git.sr.ht/~yoctocell/git-email")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "1lk1yds7idgawnair8l3s72rgjmh80qmy4kl5wrnqvpmjrmdgvnx"))))
      (build-system emacs-build-system)
      (arguments
       `(#:phases
         (modify-phases %standard-phases
           ;; piem is not yet packaged in Guix.
           (add-after 'unpack 'remove-piem
             (lambda _
               (delete-file "git-email-piem.el")
               (delete-file "git-email-gnus.el")
               (delete-file "git-email-mu4e.el")))
           (add-before 'install 'makeinfo
             (lambda _
               (invoke "makeinfo" "doc/git-email.texi"))))))
      (native-inputs
       `(("texinfo" ,texinfo)))
      (inputs
       `(("emacs-magit" ,emacs-magit)
         ("notmuch" ,notmuch)))
      (license license:gpl3+)
      (home-page "https://sr.ht/~yoctocell/git-email")
      (synopsis "Format and send Git patches in Emacs")
      (description "This package provides utilities for formatting and
sending Git patches via Email, without leaving Emacs."))))

(define-public emacs-git-gutter-transient
  (package
   (name "emacs-git-gutter-transient")
   (version "0.1.0")
   (source
    (local-file "./features/emacs/git-gutter-transient" #:recursive? #t))
   (build-system emacs-build-system)
   (inputs
    `(("emacs-magit" ,emacs-magit)))
   (propagated-inputs
    `(("emacs-git-gutter" ,emacs-git-gutter)
      ("emacs-transient" ,emacs-transient)))
   (license license:gpl3+)
   (home-page "https://sr.ht/~abcdw/git-gutter-transient")
   (synopsis "Navigate, stage and revert hunks with ease")
   (description "This package provides transient interface for git-gutter function
to manipulate and navigate hunks.")))

(use-modules (guix download)
             (guix build-system gnu)
             (gnu packages gnome)
             (gnu packages tls)
             (gnu packages gsasl)
             (gnu packages compression))

(define-public msmtp-latest
  (package
    (name "msmtp-latest")
    (version "1.8.15")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://marlam.de/msmtp/releases/"
                           "/msmtp-" version ".tar.xz"))
       (sha256
        (base32 "1klrj2a77671xb6xa0a0iyszhjb7swxhmzpzd4qdybmzkrixqr92"))
       (patches
        (search-patches "msmtpq-add-enqueue-option.patch"
                        "msmtpq-add-env-variables.patch"))))
    (build-system gnu-build-system)
    (inputs
     `(("libsecret" ,libsecret)
       ("gnutls" ,gnutls)
       ("zlib" ,zlib)
       ("gsasl" ,gsasl)))
    (native-inputs
     `(("pkg-config" ,pkg-config)))
    (home-page "https://marlam.de/msmtp/")
    (arguments
     `(#:configure-flags (list "--with-libgsasl"
                               "--with-libidn"
                               "--with-tls=gnutls")
       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'install-additional-files
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (doc (string-append out "/share/doc/msmtp"))
                    (msmtpq "scripts/msmtpq")
                    (vimfiles (string-append out "/share/vim/vimfiles/plugin")))
               (install-file (string-append msmtpq "/msmtpq") bin)
               (install-file (string-append msmtpq "/msmtp-queue") bin)
               (install-file (string-append msmtpq "/README.msmtpq") doc)
               (install-file "scripts/vim/msmtp.vim" vimfiles)
               (substitute* (string-append bin "/msmtp-queue")
                 (("^exec msmtpq") (format #f "exec ~a/msmtpq" bin)))
               (substitute* (string-append bin "/msmtpq")
                 (("^MSMTP=msmtp") (format #f "MSMTP=~a/msmtp" bin))
                 ;; Make msmtpq quite by default, because Emacs treat output
                 ;; as an indicator of error.  Logging still works as it was.
                 (("^EMAIL_QUEUE_QUIET=\\$\\{MSMTPQ_QUIET:-\\}")
                  "EMAIL_QUEUE_QUIET=${MSMTPQ_QUIET:-t}")
                 ;; Use ping test instead of netcat by default, because netcat
                 ;; is optional and can be missing.
                 (("^EMAIL_CONN_TEST=\\$\\{MSMTPQ_CONN_TEST:-n\\}")
                  "EMAIL_CONN_TEST=${MSMTPQ_CONN_TEST:-p}"))
               #t))))))
    (synopsis
     "Simple and easy to use SMTP client with decent sendmail compatibility")
    (description
     "msmtp is an SMTP client.  In the default mode, it transmits a mail to
an SMTP server (for example at a free mail provider) which takes care of further
delivery.")
    (license license:gpl3+)))

(define-public emacs-consumer
  (package
   (name "emacs-consumer")
   (version "0.1.0")
   (source (local-file "./packages.scm"))
   (build-system trivial-build-system)
   (arguments
    `(#:builder
      (let ((out (assoc-ref %outputs "out")))
        (mkdir out)
        #t)))
   (native-search-paths
    (list (search-path-specification
           (variable "EMACSLOADPATH")
           (files '("share/emacs/site-lisp")))
          (search-path-specification
           (variable "INFOPATH")
           (files '("share/info")))))
   (license license:gpl3+)
   (home-page "https://sr.ht/~abcdw/rde")
   (synopsis "Apropriate values for @env{EMACSLOADPATH} and @env{INFOPATH}.")
   (description "This package helps to set environment variables, which make
emacs packages of current profile explorable by external Emacs.")))

(define-public emacs-mct
  (package
   (name "emacs-mct")
   (version "0.4.2")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://gitlab.com/protesilaos/mct.git")
                  (commit version)))
            (sha256
             (base32 "0sj9hyxpighspwrm2yimqkdxlhw2yiznaj69ysn2sjd6jn2aqpc6"))
            (file-name (git-file-name name version))))
   (build-system emacs-build-system)
   (license license:gpl3+)
   (home-page "https://protesilaos.com/emacs/mct")
   (synopsis "Enhancement of the default Emacs minibuffer completion UI.")
   (description "Minibuffer and Completions in Tandem, also known as
mct, or mct.el, is a package that enhances the default minibuffer and
*Completions* buffer of Emacs 27 (or higher) so that they work
together as part of a unified framework. The idea is to make the
presentation and overall functionality be consistent with other
popular, vertically aligned completion UIs while leveraging built-in
functionality.")))

(use-modules (gnu packages glib))
(define-public pipewire-media-session
  (package
    (name "pipewire-media-session")
    (version "0.4.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gitlab.freedesktop.org/pipewire/media-session")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1gjspcgl5z19j4m3jr0771a1cxiizzvkjsw2v4rq6d92760zp7bv"))))
    (build-system meson-build-system)
    (native-inputs
     (list pkg-config))
    (inputs
     (list pipewire-0.3
           alsa-lib
           dbus))
    (home-page "https://pipewire.org/")
    (synopsis "PipeWire Media Session")
    (description #f)
    (license license:expat)))

(define-public emacs-vertico-latest
  (let* ((commit "a8fe9a0b2e156e022136169a3159b4dad78b2439")
         (revision "0"))
    (package
     (inherit emacs-vertico)
     (name "emacs-vertico")
     (version (git-version "0.18" revision commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/minad/vertico")
             (commit commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "17jdxjcfs5dn39wbp1rf1nar08zs1slxpgxnnj9vf2il49n5n922")))))))

(define-public emacs-vterm-latest
  (let ((version "0.0.1")
        (revision "1")
        (commit "a940dd2ee8a82684860e320c0f6d5e15d31d916f"))
    (package
     (inherit emacs-vterm)
     (name "emacs-vterm")
     (version (git-version version revision commit))
     (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/akermu/emacs-libvterm")
                    (commit commit)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0r1iz92sn2ddi11arr9s8z7cdpjli7pn55yhaswvp4sdch7chb5r")))))))

(define-public emacs-consult-dir
  (package
   (name "emacs-consult-dir")
   (version "0.1")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/karthink/consult-dir")
                  (commit (string-append "v" version))))
            (sha256
             (base32 "1cff4ssrn1mw2s5n090pdmwdirnfih8idg5f0ll2bi2djc4hq5kn"))
            (file-name (git-file-name name version))))
   (build-system emacs-build-system)
   (license license:gpl3+)
   (propagated-inputs (list emacs-consult))
   (home-page "https://github.com/karthink/consult-dir")
   (synopsis "Insert paths into minibuffer prompts in Emacs")
   (description "Consult-dir allows you to easily insert directory
paths into the minibuffer prompt in Emacs.

When using the minibuffer, you can switch - with completion and
filtering provided by your completion setup - to any directory you’ve
visited recently, or to a project or bookmarked directory. The
minibuffer prompt will be replaced with the directory you choose.")))

(use-modules (gnu packages gtk)
             (gnu packages image))

(define-public rofi-wayland
  (package
   (inherit rofi)
   (name "rofi-wayland")
   (version "1.7.2+wayland1")
   (source (origin
            (method url-fetch)
            (uri (string-append "https://github.com/lbonn/rofi"
                                "/releases/download/"
                                version "/rofi-" version ".tar.xz"))
            (sha256
             (base32
              "1smrxjq693z48c7n5pcfrvb0m0vsn6pxn7qpn8bm68j942n8rg3x"))))
   (build-system meson-build-system)
   (arguments
    (substitute-keyword-arguments (package-arguments rofi)
      ((#:configure-flags flags '())
       #~(list "-Dxcb=disabled"))))
    (inputs
     (list cairo
           glib
           libjpeg-turbo
           librsvg
           libxkbcommon
           wayland
           wayland-protocols
           pango
           startup-notification))
    (description "Rofi is a minimalist application launcher.  It memorizes which
applications you regularly use and also allows you to search for an application
by name.

This is a fork with added support for Wayland via layer shell protocol.")))

(use-modules (guix build-system go)
             (gnu packages golang)
             (gnu packages syncthing))

(define-public go-gopkg-in-alecthomas-kingpin-v2
  (package
    (name "go-gopkg-in-alecthomas-kingpin-v2")
    (version "2.2.6")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://gopkg.in/alecthomas/kingpin.v2")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0mndnv3hdngr3bxp7yxfd47cas4prv98sqw534mx7vp38gd88n5r"))))
    (build-system go-build-system)
    (native-inputs
     (list go-github-com-alecthomas-template go-github-com-alecthomas-units
           go-github-com-stretchr-testify))
    (arguments
      '(#:import-path
        "gopkg.in/alecthomas/kingpin.v2"
        #:unpack-path
        "gopkg.in/alecthomas/kingpin.v2"
        #:phases %standard-phases))
    (home-page "https://gopkg.in/alecthomas/kingpin.v2")
    (synopsis "Kingpin - A Go (golang) command line and flag parser")
    (description "Package kingpin provides command line interfaces like this:")
    (license license:expat)))

(define-public go-github-com-yory8-clipman
  (package
    (name "go-github-com-yory8-clipman")
    (version "1.6.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/yory8/clipman")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0b9kvj0dif4221dy6c1npknhhjxvbc4kygzhwxjirpwjws0yv6v9"))))
    (build-system go-build-system)
    (arguments '(#:import-path "github.com/yory8/clipman"))
    (propagated-inputs
     (list
      go-gopkg-in-alecthomas-kingpin-v2
      go-github-com-kballard-go-shellquote
      go-github-com-alecthomas-units
      go-github-com-alecthomas-template))
    (home-page "https://github.com/yory8/clipman")
    (synopsis "Clipman")
    (description "GPL v3.0 2019- (C) yory8 <yory8@users.noreply.github.com>")
    (license license:gpl3)))

(use-modules
  (guix packages)
  (guix download)
  (guix git-download)
  (guix build-system emacs)
  (gnu packages emacs-xyz)
  ((guix licenses) #:prefix license:))

(define-public emacs-consult-recoll
  (package
   (name "emacs-consult-recoll")
   (version "0.1")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://codeberg.org/jao/consult-recoll")
           (commit "42dea1d40fedf7894e2515b4566a783b7b85486a")))
     (sha256
      (base32 "0nzch4x58vgvmcjr6p622lkzms2gvjfdgpvi6bbj5qdzkln5q23a"))))
   (build-system emacs-build-system)
   (propagated-inputs
    `(("emacs-consult" ,emacs-consult)))
   (home-page "https://codeberg.org/jao/consult-recoll")
   (synopsis "A consulting-read interface for recoll")
   (description
    "A consulting-read interface for recoll")
   (license license:gpl3+)))

(use-modules
 (guix packages)
 (guix download)
 (guix git-download)
 (guix build-system emacs)
 (gnu packages emacs-xyz)
 ((guix licenses) #:prefix license:))

(define-public emacs-consult-eglot
  (package
   (name "emacs-consult-eglot")
   (version "20210905.1830")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/mohkale/consult-eglot.git")
           (commit "f93c571dc392a8b11d35541bffde30bd9f411d30")))
     (sha256
      (base32 "1jqg6sg6iaqxpfn7symiy221mg9sn4y1rn0l1rw9rj9xmcnng7s0"))))
   (build-system emacs-build-system)
   (propagated-inputs
    `(("emacs-eglot" ,emacs-eglot) ("emacs-consult" ,emacs-consult)))
   (home-page "https://github.com/mohkale/consult-eglot")
   (synopsis "A consulting-read interface for eglot")
   (description
    "Query workspace symbol from eglot using consult.

This package provides a single command `consult-eglot-symbols' that uses the
lsp workspace/symbol procedure to get a list of symbols exposed in the current
workspace. This differs from the default document/symbols call, that eglot
exposes through imenu, in that it can present symbols from multiple open files
or even files not indirectly loaded by an open file but still used by your
project.

This code was partially adapted from the excellent consult-lsp package.")
   (license license:expat)))

(define-public emacs-iscroll
  (package
    (name "emacs-iscroll")
    (version "20210128.1938")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/casouri/iscroll.git")
             (commit "d6e11066169d232fe23c2867d44c012722ddfc5a")))
       (sha256
        (base32 "0pbcr5bwmw2ikwg266q2fpxaf0z5h5cl1rp3rhhn9i9yn7hlfc78"))))
    (build-system emacs-build-system)
    (home-page "https://github.com/casouri/iscroll")
    (synopsis "Smooth scrolling over images")
    (description
     "
Gone are the days when images jumps in and out of the window when
scrolling! This package makes scrolling over images as if the image
is made of many lines, instead of a single line. (Indeed, sliced
image with default scrolling has the similar behavior as what this
package provides.)

To use this package:

    M-x iscroll-mode RET

This mode remaps mouse scrolling functions and `next/previous-line'.
If you use other commands, you need to adapt them accordingly. See
`iscroll-mode-map' and `iscroll-mode' for some inspiration.

You probably don't want to enable this in programming modes because
it is slower than normal scrolling commands.

If a line is taller than double the default line height, smooth
scrolling is triggered and Emacs will reveal one line’s height each
time.

Commands provided:

- iscroll-up
- iscroll-down
- iscroll-next-line
- iscroll-previous-line
")
    (license license:gpl3+)))

(define-public emacs-ob-restclient-latest
  (let ((commit "f81f2f4f3fe6882947b8547ccd570f540106ed4d"))
    (package
      (name "emacs-ob-restclient")
      (version (git-version "0.02" "2" commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/alf/ob-restclient.el")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "16byn85gsl99k818686jp3r4ipjcwdyq3nilmb32g4hgg0dlgaij"))))
      (propagated-inputs
       (list emacs-restclient))
      (build-system emacs-build-system)
      (home-page "https://github.com/alf/ob-restclient.el")
      (synopsis "Org-babel functionality for @code{restclient-mode}")
      (description
       "This package integrates @code{restclient-mode} with Org.")
      (license license:gpl3+))))

(define-public emacs-modus-themes-latest
  (package
   (inherit emacs-modus-themes)
   (name "emacs-modus-themes")
   (version "2.0.0-patch")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://gitlab.com/protesilaos/modus-themes")
           (commit "4f177f036b30dd6c1f2e6c5342f2b87e034dc97e")))
     (file-name (git-file-name name version))
     (sha256
      (base32 "15zxab2wg97ldy85wv2sx7j31z0cg0h28vm9yjnp3b7vl7sbzf33"))
     (patches (search-patches
               "0001-DRAFT-Add-tentative-support-for-ement.el.patch"))))))

(define-public emacs-justify-kp
 (let ((commit "385e6b8b909ae0f570f30101cec3677e21c9e0a0"))
  (package
   (name "emacs-justify-kp")
   (version "20171119")
   (home-page "https://github.com/qzdl/justify-kp")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url home-page)
           (commit commit)))
     (file-name (git-file-name name version))
     (sha256
      (base32 "13fylx4mvw7cgzd2mq060x43b1x7g5vdf16jm49c31f6b3jj1qi0"))))
   (build-system emacs-build-system)
   (inputs (list emacs-dash emacs-s))
   (synopsis "Paragraph justification for emacs using Knuth/Plass algorithm ")
   (description
    "Paragraph justification for emacs using Knuth/Plass algorithm ")
   (license license:gpl3+))))

(define-public tessen
  (package
    (name "tessen")
    (version "1.3.1")
    (home-page "https://github.com/ayushnix/tessen")
    (source
     (origin
       (method url-fetch)
       (uri (string-append home-page "/archives/refs/tags/v" version ".tar.gz"))
       (sha256
        (base32 "07ddb5himj4c9ijdibjy25dshil3k5nqd7869z9rkldzh97zh29f"))))
    (build-system gnu-build-system)
    (arguments
     '(#:make-flags (list (string-append "PREFIX=" %output))
       #:phases (modify-phases %standard-phases
                  (delete 'configure)
                  (delete 'check))))
    (inputs (list password-store
                  wl-clipboard
                  libnotify
                  pass-otp
                  xdg-utils
                  scdoc))
    (synopsis
     "An interactive menu to autotype and copy password-store data ")
    (description
     "tessen is a bash script that can use any wayland native
dmenu-like backend as an interface for auto-typing and copying
password-store data, known to work with bemenu, fuzzel, rofi, wofi")
    (license license:gpl3+)))

(define-public xdg-desktop-portal-wlr-latest
  (let ((commit "c34d09877cb55eb353311b5e85bf50443be9439d"))
  (package
    (inherit xdg-desktop-portal-wlr)
    (name "xdg-desktop-portal-wlr")
    (version "0.5.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/emersion/xdg-desktop-portal-wlr")
                     (commit commit)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0xw5hmx816w4hsy1pwz3qikxc7m6pcx1ly03hhbb6vp94gfcwpr3"))
              (patches (search-patches "xdg-desktop-portal-wlr-harcoded-length.patch"))))
        (license license:expat))))

(use-modules (gnu packages wm)
             (gnu packages gl)
             (gnu packages xorg))
(define-public wlroots-latest
  (package
    (inherit wlroots)
    (name "wlroots-latest")
    (version "0.15.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gitlab.freedesktop.org/wlroots/wlroots")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "00s73nhi3sc48l426jdlqwpclg41kx1hv0yk4yxhbzw19gqpfm1h"))))
    (build-system meson-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-before 'configure 'hardcode-paths
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "xwayland/server.c"
               (("Xwayland") (string-append (assoc-ref inputs
                                                       "xorg-server-xwayland")
                                            "/bin/Xwayland")))
             #t)))))
    (propagated-inputs
     (list ;; As required by wlroots.pc.
           eudev
           libinput
           libxkbcommon
           mesa
           pixman
           seatd
           wayland-latest
           wayland-protocols
           xcb-util-errors
           xcb-util-wm
           xorg-server-xwayland))
    (native-inputs
     (list pkg-config wayland))
    (home-page "https://github.com/swaywm/wlroots")
    (synopsis "Pluggable, composable, unopinionated modules for building a
Wayland compositor")
    (description "wlroots is a set of pluggable, composable, unopinionated
modules for building a Wayland compositor.")
    (license license:expat)))

(use-modules (gnu packages libffi)
             (gnu packages xml)
             (gnu packages docbook))
(define-public wayland-latest
  (package
    (inherit wayland)
    (name "wayland-latest")
    (version "1.20.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://wayland.freedesktop.org/releases/"
                                  name "-" version ".tar.xz"))
              (sha256
               (base32
                "09c7rpbwavjg4y16mrfa57gk5ix6rnzpvlnv1wp7fnbh9hak985q"))))
    (build-system meson-build-system)
    (outputs '("out" "doc"))
    (arguments
     `(#:parallel-tests? #f
        #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-docbook-xml
           (lambda* (#:key native-inputs inputs #:allow-other-keys)
             (with-directory-excursion "doc"
               (substitute* (find-files "." "\\.xml$")
                 (("http://www.oasis-open.org/docbook/xml/4\\.5/")
                  (string-append (assoc-ref (or native-inputs inputs)
                                            "docbook-xml")
                                 "/xml/dtd/docbook/"))
                 (("http://www.oasis-open.org/docbook/xml/4\\.2/")
                  (string-append (assoc-ref (or native-inputs inputs)
                                            "docbook-xml-4.2")
                                 "/xml/dtd/docbook/"))))))
         (add-after 'install 'move-doc
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (doc (assoc-ref outputs "doc")))
               (mkdir-p (string-append doc "/share"))
               (rename-file
                (string-append out "/share/doc")
                (string-append doc "/share/doc"))))))))
    (native-inputs
     `(("docbook-xml-4.2" ,docbook-xml-4.2)
       ("docbook-xml" ,docbook-xml)
       ("docbook-xsl" ,docbook-xsl)
       ("dot" ,graphviz)
       ("doxygen" ,doxygen)
       ("pkg-config" ,pkg-config)
       ("python" ,python)
       ("xmlto" ,xmlto)
       ("xsltproc" ,libxslt)
       ,@(if (%current-target-system)
             `(("pkg-config-for-build" ,pkg-config-for-build)
               ("wayland" ,this-package)) ; for wayland-scanner
             '())))
    (inputs
     (list expat libxml2))           ; for XML_CATALOG_FILES
    (propagated-inputs
     (list libffi))
    (home-page "https://wayland.freedesktop.org/")
    (synopsis "Core Wayland window system code and protocol")
    (description "Wayland is a project to define a protocol for a compositor to
talk to its clients as well as a library implementation of the protocol.  The
compositor can be a standalone display server running on Linux kernel
modesetting and evdev input devices, an X application, or a wayland client
itself.  The clients can be traditional applications, X servers (rootless or
fullscreen) or other display servers.")
    (license license:expat)))
