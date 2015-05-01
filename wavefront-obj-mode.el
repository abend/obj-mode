;;; wavefront-obj-mode.el --- Major mode for Wavefront obj files
;;
;; Version: 0.5
;; Author: Sasha Kovar <sasha-emacs@arcocene.org>
;; Url: http://github.com/abend/wavefront-obj-mode
;;
;;; Commentary:
;;
;; A hodepodge of quick random hacks for editing wavefront obj files.
;; Use as you wish.
;;

;;; Code:

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.obj\\'" . obj-mode))
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.mtl\\'" . obj-mode))

(defvar obj-mode-builtins-re (concat "^" (regexp-opt '("d" "f" "s"
                                                       "v" "vn" "vp" "vt"
                                                       "Ka" "Ke" "Kd" "Ks"
                                                       "Ni" "Ns"
                                                       "Tf" "Tr"
                                                       "illum" "bump" "disp" "decal" "refl"
                                                       "map_d"
                                                       "map_Ka" "map_Ke" "map_Kd" "map_Ks"
                                                       "map_Ni" "map_Ns"
                                                       "map_bump"))))

(defvar obj-mode-keywords
  `((,obj-mode-builtins-re . font-lock-builtin-face)
    ("^\\(usemtl\\|mtllib\\|newmtl\\).*" . font-lock-string-face)
    ("^\\(o\\|g\\) .*" . font-lock-function-name-face)
    ("^#.*" . font-lock-comment-face)))

(defvar obj-mode-defun-regex
  "^\\(g\\|o\\)\\s-+\\(.+\\)")

;; if we want separate submenus for objects and groups
;; (defvar obj-imenu-generic-expression
;;   '(("Objects"  "^o\\s-+\\(.*\\)" 1)
;;     ("Groups"  "^g\\s-+\\(.*\\)" 1)))

(defvar obj-imenu-generic-expression
  `((nil ,obj-mode-defun-regex 2)))

;;;###autoload
(define-derived-mode obj-mode fundamental-mode "Obj"
  "Major mode for editing Wavefront obj ascii files.

\\{obj-mode-map}"
  :group 'obj
  (setq font-lock-defaults '(obj-mode-keywords))
  (set (make-local-variable 'comment-start) "# ")
  (set (make-local-variable 'paragraph-start) obj-mode-defun-regex)
  (set (make-local-variable 'beginning-of-defun-function)
       'obj-beginning-of-defun)
  (set (make-local-variable 'end-of-defun-function)
       'obj-end-of-defun)
  (set (make-local-variable 'add-log-current-defun-function)
       'obj-current-defun)
  (set (make-local-variable 'imenu-generic-expression)
       obj-imenu-generic-expression))

(defun obj-try-to-add-imenu ()
  (condition-case nil (imenu-add-to-menubar "Imenu") (error nil)))
(add-hook 'obj-mode-hook 'obj-try-to-add-imenu)


(defun obj-beginning-of-defun (&optional arg)
  "Move backward to the beginning of a defun.
Every 'g' or 'o' block is considered to be a defun (see `obj-mode-defun-regex').
Return t unless search stops due to beginning or end of buffer."
  (interactive "p")
  (or arg (setq arg 1))
  (obj-end-of-defun (- arg)))

(defun obj-end-of-defun (&optional arg)
  "Move forward to the end of the current defun.
Every 'g' or 'o' block is considered to be a defun (see `obj-mode-defun-regex').
Return t unless search stops due to beginning or end of buffer."
  (interactive "p")
  (or arg (setq arg 1))

  (or (not (eq this-command 'obj-beginning-of-defun))
      (eq last-command 'obj-end-of-defun)
      (and transient-mark-mode mark-active)
      (push-mark))

  (if (< arg 0)
      (re-search-backward obj-mode-defun-regex nil t)
      (re-search-forward obj-mode-defun-regex nil t)))

(defun obj-current-defun ()
  "`add-log-current-defun-function' for Obj mode."
  (save-excursion
    (when (re-search-backward obj-mode-defun-regex nil t)
      (match-string 2))))


(provide 'obj-mode)

;;; obj-mode.el ends here
