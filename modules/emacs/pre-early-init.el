;;; pre-early-init.el --- DESCRIPTION -*- no-byte-compile: t; lexical-binding: t; -*-

;; Reducing clutter in ~/.emacs.d by redirecting files to ~/.emacs.d/var/
;; IMPORTANT: This part should be in the pre-early-init.el file
(setq minimal-emacs-var-dir "~/.var/emacs/")
(setq package-user-dir (expand-file-name "elpa" minimal-emacs-var-dir))
(setq user-emacs-directory minimal-emacs-var-dir)

(defun display-startup-time ()
  "Display the startup time and number of garbage collections."
  (message
   "Emacs init loaded in %.2f seconds (Full emacs-startup: %.2fs) with %d garbage collections."
   (float-time (time-subtract after-init-time before-init-time))
   (time-to-seconds (time-since before-init-time))
   gcs-done))

(add-hook 'emacs-startup-hook #'display-startup-time 100)
