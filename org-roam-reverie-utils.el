(defun iso8601-format (time)
    "format time to iso8601 string with current timezone"
    (format-time-string "%FT%T%z" time nil))

(defun parse-iso8601-to-time (time)
    "format time to iso8601 string with current timezone"
    (car (time-convert (encode-time (iso8601-parse time)) 1000)))

(defun org-roam-reverie-get-created-time-from-path (path)
  "extract date-time part from file path: 20210728101112, convert to timestamp"
  (let ((ts (car (split-string (car (last (split-string path "/"))) "-"))))
    (car (time-convert (encode-time (iso8601-parse (format "%sT%s" (substring ts 0 8) (substring ts 8)))) 1000))))

(provide 'org-roam-reverie-utils)
