(defconst org-roam-reverie-property-created-time "CREATED_TIME")
(defconst org-roam-reverie-roam-exclude "ROAM_EXCLUDE")

(defun reverie-init-node ()
  "init org-roam headline node"
  (interactive)
  (progn (org-id-get-create)
         (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (current-time)))))

(defun reverie-init-id-headline ()
  "init simple headline node"
  (interactive)
  (progn (org-id-get-create)
         (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (current-time)))
         (org-entry-put nil org-roam-reverie-roam-exclude "t")))

(defun reverie-init-headline-id ()
  "process every headline, add id if not exist"
  (interactive)
  (org-with-point-at 1
    (org-map-entries
     (lambda ()
       (let ((id (org-id-get)))
         (when (not id)
           (org-id-get-create)))))))

(defun reverie-brother-headline ()
  "insert same level headline node"
  (interactive)
  (progn (org-insert-heading-respect-content)
         (org-id-get-create)
         (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (current-time)))))

(defun reverie-child-headline ()
  "insert next level headline node"
  (interactive)
  (progn (org-insert-heading-respect-content)
         (org-do-demote)
         (org-id-get-create)
         (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (current-time)))))

(defun reverie-child-headline-simple ()
  "insert next level headline node"
  (interactive)
  (progn (org-insert-heading-respect-content)
         (org-do-demote)))

(defun reverie-exclude-headline ()
  "exclude headline node"
  (interactive)
  (when (and (org-at-heading-p (org-back-to-heading t)) (org-id-get))
    (when (not (cdr (assoc org-roam-reverie-roam-exclude (org-entry-properties))))
      (org-entry-put nil org-roam-reverie-roam-exclude "t"))))

(defun reverie-toggle-exclude-headline ()
  "toggle exclude headline node"
  (interactive)
  (when (and (org-at-heading-p (org-back-to-heading t)) (org-id-get))
    (if (cdr (assoc org-roam-reverie-roam-exclude (org-entry-properties)))
      (org-entry-delete nil org-roam-reverie-roam-exclude)
      (org-entry-put nil org-roam-reverie-roam-exclude "t"))))

(defun reverie-collect-data ()
  (let ((id (cdr (assoc "ID" (org-entry-properties))))
        (title (nth 4 (org-heading-components))))
    (if id
      (cons id title)
      nil)))

(defun org-dblock-write:reverie-insert-children-nodes (param)
  "dynamic block function, insert subheading nodes"
  (interactive)
  (let* ((before-first (org-before-first-heading-p))
         (level (if before-first
                  0
                  (nth 1 (org-heading-components))))
         (scope (if before-first
                  'file
                  'tree))
         (match (format "+ID={.+}+LEVEL=%d+%s<>{.+}" (+ level 1) org-roam-reverie-roam-exclude)))
    (save-excursion
      (let ((heading-nodes (org-map-entries #'reverie-collect-data match scope)))
        (when (> (length heading-nodes) 0)
          (insert (mapconcat (lambda (node) (org-link-make-string
                                      (concat "id:" (car node))
                                      (cdr node)))
                     heading-nodes "\n")))))))

(defun reverie-insert-children-nodes ()
  "insert subheading nodes"
  (interactive)
  (let* ((before-first (org-before-first-heading-p))
         (level (if before-first
                  0
                  (nth 1 (org-heading-components))))
         (scope (if before-first
                  'file
                  'tree))
         (match (format "+ID={.+}+LEVEL=%d+%s<>{.+}" (+ level 1) org-roam-reverie-roam-exclude)))
    (save-excursion
      (when (not before-first)
        (org-back-to-heading t))
      (let ((heading-nodes (org-map-entries #'reverie-collect-data match scope)))
        (when (> (length heading-nodes) 0)
          (mapcar (lambda (node) (progn (org-end-of-meta-data t)
                                        (newline)
                                        (previous-line)
                                        (insert (org-link-make-string
                                                  (concat "id:" (car node))
                                                  (cdr node)))
                                        (newline)))
                  heading-nodes))))))

(provide 'org-roam-reverie)
