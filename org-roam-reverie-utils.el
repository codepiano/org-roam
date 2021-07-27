(defun iso8601-format (time)
    "format time to iso8601 string with current timezone"
    (format-time-string "%FT%T%z" time nil))

(defun parse-iso8601-to-time (time)
    "format time to iso8601 string with current timezone"
    (car (time-convert (encode-time (iso8601-parse time)) 1000)))

(provide 'org-roam-reverie-utils)
