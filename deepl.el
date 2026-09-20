;;; deepl.el --- Translating phrases -*- lexical-binding: t; -*-
;; Copyright (C) 2026 Lars Magne Ingebrigtsen

;; Author: Lars Magne Ingebrigtsen <larsi@gnus.org>

;; deepl.el is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 2, or (at your
;; option) any later version.

;;; Commentary:

;; Usage: Get an API key from deepl.ai and:

;; (setq deepl-api-key "API_KEY")
;; and so on.
;;
;; Then query away:
;;
;; (deepl "cheville")
;; => (:translations [(:text "dowel" :detected_source_language "FR")])

;;; Code:

(require 'url)

(defvar deepl-api-key nil
  "The key to the Deepl API.")

(defvar deepl-url "https://api-free.deepl.com"
  "URL to use.")

(cl-defun deepl (phrase &key (from "FR") (to "EN"))
  (let* ((url-request-method "POST")
         (url-request-data
	  (encode-coding-string (json-serialize
				 `( text [,phrase]
				    source_lang ,from
				    target_lang ,to))
				'utf-8))
         (url-request-extra-headers
          `(("Connection" . "close")
            ("Content-Type" ."application/json")
	    ("Accept" . "application/json")
	    ("Authorization" . ,(concat "DeepL-Auth-Key " deepl-api-key)))))
    (with-current-buffer (url-retrieve-synchronously
			  (concat deepl-url "/v2/translate")
			  t)
      (goto-char (point-min))
      (unwind-protect
	  (and (search-forward "\n\n" nil t)
	       (json-parse-buffer :object-type 'plist))
	(kill-buffer (current-buffer))))))

(provide 'deepl)

;;; deepl.el ends here.
