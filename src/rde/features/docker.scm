(define-module (rde features docker)
  #:use-module (rde features)
  #:use-module (rde features emacs)
  #:use-module (gnu packages docker)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (rde packages emacs-xyz)
  #:use-module (gnu services)
  #:use-module (gnu services docker)
  #:use-module (rde system services accounts)

  #:export (feature-docker))

(define* (feature-docker
          #:key
          (docker docker)
          (docker-cli docker-cli)
          (emacs-docker emacs-docker-latest)
          (emacs-dockerfile-mode emacs-dockerfile-mode)
          (containerd containerd)
          (docker-key "D"))
  "Configure docker and related packages."

  (define f-name 'docker)
  (define (get-home-services config)
    (list
     (rde-elisp-configuration-service
      f-name
      config
      `((with-eval-after-load
         'rde-keymaps
         (define-key rde-app-map (kbd ,docker-key) 'docker))
        (add-to-list 'auto-mode-alist '(".*Dockerfile\\'" . dockerfile-mode)))
      #:summary "\
Docker interface and Dockerfile syntax"
      #:commentary "\
Keybinding and Dockerfile major mode association."
      #:keywords '(convenience)
      ;; MAYBE: Add emacs-docker-tramp?
      #:elisp-packages (list emacs-docker emacs-dockerfile-mode))))

  (define (get-system-services config)
    (list
     (simple-service
      'docker-add-docker-group-to-user
      rde-account-service-type
      (list "docker"))
     (service
      docker-service-type
      (docker-configuration
       (docker docker)
       (docker-cli docker-cli)
       (containerd containerd)))))

  (feature
   (name f-name)
   (values `((,f-name . #t)))
   (home-services-getter get-home-services)
   (system-services-getter get-system-services)))
