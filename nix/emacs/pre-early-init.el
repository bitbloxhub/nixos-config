;;; pre-early-init.el --- DESCRIPTION -*- no-byte-compile: t; lexical-binding: t; -*-

;; Reducing clutter in ~/.emacs.d by redirecting files to ~/.emacs.d/var/
;; IMPORTANT: This part should be in the pre-early-init.el file
(setq minimal-emacs-var-dir "~/.var/emacs/")
(setq package-user-dir
      (expand-file-name "elpa" minimal-emacs-var-dir))
(setq user-emacs-directory minimal-emacs-var-dir)

;; Native compilation may create the writable ~/.local/state/nix/profile from NIX_PROFILES.
;; Nix's shell init prefers that existing path over ~/.nix-profile, so shells lose
;; the real profile's bin from PATH.
(when (boundp 'native-comp-eln-load-path)
  (let ((eln-cache (expand-file-name "eln-cache" minimal-emacs-var-dir)))
    (setq native-comp-eln-load-path
          (cons eln-cache (delete eln-cache native-comp-eln-load-path)))))

(defun display-startup-time ()
  "Display the startup time and number of garbage collections."
  (message
   "Emacs init loaded in %.2f seconds (Full emacs-startup: %.2fs) with %d garbage collections."
   (float-time (time-subtract after-init-time before-init-time))
   (time-to-seconds (time-since before-init-time))
   gcs-done))

(add-hook 'emacs-startup-hook #'display-startup-time 100)
