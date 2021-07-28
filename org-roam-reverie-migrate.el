(require 'org-roam-db)

;;; files table migrate
(defun org-roam-reverie-alter-files-schema ()
  "alter files talbe"
  (org-roam-db-query  "alter table files add column modifiedTime integer"))

(defun org-roam-reverie-update-file-modifiedTime ()
  "fill column modifiedTime in files table"
  (let ((rows (org-roam-db-query  "select file,mtime from files where mtime is not NULL and modifiedTime is NULL")))
   (cl-loop for row in rows
             collect (pcase-let* ((`(,file ,mtime)
                                  row))
                              (org-roam-db-query [:update files :set (= modifiedTime $s1) :where (= file $s2)] (car (time-convert mtime 1000)) file)))))

(defun org-roam-reverie-migrate-files-table ()
  "migrate files table"
  (progn (org-roam-reverie-alter-files-schema)
         (org-roam-reverie-update-file-modifiedTime)
         ))

;;; nodes table migrate
(defun org-roam-reverie-alter-nodes-schema ()
  "alter nodes talbe"
  (org-roam-db-query "alter table nodes add column createdTime integer"))

(defun org-roam-reverie-update-nodes-createdTime ()
  "fill column createdTime in files table"
  (let ((rows (org-roam-db-query  "select file from nodes ")))
   (cl-loop for row in rows
             collect (pcase-let* ((`(,file)
                                  row))
                              (org-roam-db-query [:update nodes :set (= createdTime $s1) :where (= file $s2)] (org-roam-reverie-get-created-time-from-path file) file)))))

(defun org-roam-reverie-migrate-nodes-table ()
  "migrate nodes table"
  (progn (org-roam-reverie-alter-nodes-schema)
         (org-roam-reverie-update-nodes-createdTime)))

;;; node property migrate
(defun org-roam-reverie-migrate-file-property ()
  "add CREATED_TIME property if not exists"
    (org-with-point-at 1
        (when (and (= (org-outline-level) 0)
                   (org-roam-db-node-p))
          (when-let ((id (org-id-get)))
            (let* ((file (buffer-file-name))
                   (createdTimeProperty (assoc org-roam-reverie-property-created-time (org-entry-properties))))
              (when (not createdTimeProperty)
                (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (org-roam-reverie-get-time-from-path file)))
                (save-buffer)))))))

(cl-defun org-roam-reverie-migrate-node-property ()
  "Insert node data for headline at point into the Org-roam cache."
  (when-let ((id (org-id-get)))
    (let* ((file (buffer-file-name (buffer-base-buffer)))
           (heading-components (org-heading-components))
           (title (or (nth 4 heading-components)
                      (progn (lwarn 'org-roam :warning "Node in %s:%s:%s has no title, skipping..."
                                    file
                                    (line-number-at-pos)
                                    (1+ (- (point) (line-beginning-position))))
                             (cl-return-from org-roam-db-insert-node-data))))
           (createdTimeProperty (assoc org-roam-reverie-property-created-time (org-entry-properties))))
      (when (not createdTimeProperty)
        (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (org-roam-reverie-get-time-from-path file)))
        (save-buffer)))))

(defun org-roam-reverie-migrate-property (&optional file-path)
  (setq file-path (or file-path (buffer-file-name (buffer-base-buffer))))
    (org-roam-with-file file-path nil
        (progn
          (org-set-regexps-and-options 'tags-only)
          (org-roam-reverie-migrate-file-property)
          (org-roam-db-map-nodes
           (list #'org-roam-reverie-migrate-node-property)))))

(defun org-roam-file-migrate ()
  "migrate file"
  (let* ((org-roam-files (org-roam--list-all-files))
         (current-files (org-roam-db--get-current-files))
         (modified-files nil))
    (dolist (file org-roam-files)
      (org-roam-reverie-migrate-property file)
      (let ((contents-hash (org-roam-db--file-hash file)))
        (unless (string= (gethash file current-files)
                         contents-hash)
          (org-roam-db-query [:update files :set (= hash $s1) :where (= file $s2)] contents-hash file))))))

(provide 'org-roam-reverie-migrate)
