(defconst org-roam-reverie-property-created-time "CREATED_TIME")

(defun org-roam-reverie-init-node ()
  "init headline node"
  (interactive)
  (progn (org-id-get-create)
         (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (current-time)))))

(provide 'org-roam-reverie)
