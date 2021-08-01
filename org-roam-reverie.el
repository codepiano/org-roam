(defconst org-roam-reverie-property-created-time "CREATED_TIME")

(defun org-roam-reverie-init-node ()
  "init headline node"
  (interactive)
  (progn (org-id-get-create)
         (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (current-time)))))

(defun org-roam-reverie-init-headline-id ()
  "process every headline, add id if not exist"
  (interactive)
  (org-with-point-at 1
    (org-map-entries
     (lambda ()
       (let ((id (org-id-get)))
         (when (not id)
           (org-id-get-create)))))))

(provide 'org-roam-reverie)
