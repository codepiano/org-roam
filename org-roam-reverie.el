(defconst org-roam-reverie-property-created-time "CREATED_TIME")
(defconst org-roam-reverie-roam-exclude "ROAM_EXCLUDE")

(defun org-roam-reverie-init-node ()
  "init org-roam headline node"
  (interactive)
  (progn (org-id-get-create)
         (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (current-time)))))

(defun org-roam-reverie-init-id-headline ()
  "init simple headline node"
  (interactive)
  (progn (org-id-get-create)
         (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (current-time)))
         (org-entry-put nil org-roam-reverie-roam-exclude "t")))

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

(defun org-roam-reverie-exclude-headline ()
  "exclude headline node"
  (interactive)
  (when (and (org-at-heading-p (org-back-to-heading t)) (org-id-get))
    (when (not (cdr (assoc org-roam-reverie-roam-exclude (org-entry-properties))))
      (org-entry-put nil org-roam-reverie-roam-exclude "t"))))

(defun org-roam-reverie-toggle-exclude-headline ()
  "toggle exclude headline node"
  (interactive)
  (when (and (org-at-heading-p (org-back-to-heading t)) (org-id-get))
    (if (cdr (assoc org-roam-reverie-roam-exclude (org-entry-properties)))
      (org-entry-delete nil org-roam-reverie-roam-exclude)
      (org-entry-put nil org-roam-reverie-roam-exclude "t"))))

(provide 'org-roam-reverie)
