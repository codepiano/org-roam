(defun iso8601-format (time)
    "format time to iso8601 string with current timezone"
    (format-time-string "%FT%T%z" time nil))

(defun iso8601-to-timestamp (time)
    "format time to iso8601 string with current timezone"
    (time-to-timestamp (time-convert (encode-time (iso8601-parse time)))))

(defun org-roam-reverie-get-time-from-path (path)
  "extract date-time part from file path: 20210728101112, convert to time"
  (let ((ts (car (split-string (car (last (split-string path "/"))) "-"))))
    (encode-time (iso8601-parse (format "%sT%s" (substring ts 0 8) (substring ts 8))))))

(defun org-roam-reverie-get-created-time-from-path (path)
  "extract date-time part from file path: 20210728101112, convert to timestamp"
  (time-to-timestamp (org-roam-reverie-get-time-from-path path)))

(defun time-to-timestamp (time-list)
  (car (time-convert time-list 1000)))

(defun timestamp-to-time (milli-number)
  (time-convert (cons milli-number 1000) 'list))

(provide 'org-roam-reverie-utils)
