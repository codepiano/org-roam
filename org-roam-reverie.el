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

(defun org-roam-reverie-brother-headline ()
  "insert same level headline node"
  (interactive)
  (progn (org-insert-heading)
         (org-id-get-create)
         (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (current-time)))))

(defun org-roam-reverie-child-headline ()
  "insert next level headline node"
  (interactive)
  (progn (org-insert-heading)
         (org-do-demote)
         (org-id-get-create)
         (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (current-time)))))

(defun org-roam-reverie-child-headline-simple ()
  "insert next level headline node"
  (interactive)
  (progn (org-insert-heading)
         (org-do-demote)))

(provide 'org-roam-reverie)
