;;;###autoload
(autoload 'R "ess-site" "Call 'R', the 'GNU S' system from the R Foundation.
Optional prefix (C-u) allows to set command line arguments, such as
--vsize.  This should be OS agnostic.
If you have certain command line arguments that should always be passed
to R, put them in the variable `inferior-R-args'." t)

;;;###autoload
(require 'ess-site)
;;;###autoload
(autoload 'R-mode "ess-site.el" "Major mode for editing R source." t)
;;;###autoload
(autoload 'r-mode "ess-site.el" "Major mode for editing R source." t)
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.R$" . R-mode))
;;;###autoload
(autoload 'S "ess-site" "Call 'S'." t)
