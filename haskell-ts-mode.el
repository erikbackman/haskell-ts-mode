;;; haskell-ts-mode.el --- tree-sitter support for Haskell  -*- lexical-binding: t; -*-

;; Author: Erik Bäckman
;; Version: 0.0.1
;; Keywords: haskell languages tree-sitter
;; Package-Requires: ((emacs "29"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;; ---------------------------------------------------------------------

;;; Commentary:

;;; Code:

(require 'treesit)
(eval-when-compile (require 'rx))
(require 'haskell-mode)

(declare-function treesit-parser-create "treesit.c")

(defvar haskell-ts-mode--keywords
  '("module" "import" "if" "then" "else" "case" "of" "data" "let" (where))
  "Keywords for `haskell-ts-mode'.")

;;;###autoload
(defvar haskell-ts-mode--treesit-font-lock-settings
  (treesit-font-lock-rules

   :language 'haskell
   :feature 'keyword
   `([,@haskell-ts-mode--keywords] @font-lock-keyword-face)

   :language 'haskell
   :feature 'include
   `((import) (module) (module) @font-lock-type-face
     ["import" "qualified" "module" "as"] @font-lock-keyword-face)

   :language 'haskell
   :feature 'type
   `((type) @font-lock-type-face
     (constructor) @font-lock-type-face)

   :language 'haskell
   :feature 'function
   `((signature name: (variable) @font-lock-function-name-face))

   :language 'haskell
   :feature 'variable
   `((pat_name (variable) @font-lock-variable-face)
     (exp_name (variable) @font-lock-variable-face))

   :language 'haskell
   :feature 'comment
   `((comment) @font-lock-comment-face
     (comment) @contextual))
  "Tree-sitter font-lock settings for `haskell-ts-mode'.")


;;;###autoload
(define-derived-mode haskell-ts-mode haskell-mode "Haskell (TS)"
  "Major mode for Haskell files using tree-sitter"
  :group 'haskell

  (unless (treesit-ready-p 'haskell)
    (error "Tree-sitter for Haskell is not available"))

  (treesit-parser-create 'haskell)

  ;; Navigation
  (setq-local treesit-defun-type-regexp
              (rx (or "function_definition"
                      "struct_definition")))

  ;; Override functions set by `haskell-mode'.
  (setq-local syntax-propertize-function nil)
  (setq-local indent-line-function nil)

  ;; Font-lock.
  (setq-local treesit-font-lock-settings haskell-ts-mode--treesit-font-lock-settings)
  (setq-local treesit-font-lock-feature-list
	      '(( type keyword include definition function variable comment )))
    
  (treesit-major-mode-setup))

(provide 'haskell-ts-mode)

;;; haskell-ts-mode.el ends here

