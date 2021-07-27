(require 'org-roam-db)

(defconst org-roam-reverie-property-created-time "CREATED_TIME")

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
  (progn (org-roam-reverie-alter-files-schema)
         (org-roam-reverie-update-file-modifiedTime)
         ))

(defun org-roam-reverie-init-node ()
  "init headline node"
  (progn (org-id-get-create)
         (org-entry-put nil org-roam-reverie-property-created-time (iso8601-format (current-time)))))

(defun org-roam-reverie-alter-nodes-schema ()
  "alter nodes talbe"
  (org-roam-db-query "alter table nodes add column createdTime integer"))

(defun org-roam-reverie-get-created-time-from-path (path)
  "extract date-time part from file path: 20210728101112, convert to timestamp"
  (let ((ts (car (split-string (car (last (split-string path "/"))) "-"))))
    (car (time-convert (encode-time (iso8601-parse (format "%sT%s" (substring ts 0 8) (substring ts 8)))) 1000))))

(defun org-roam-reverie-update-nodes-createdTime ()
  "fill column createdTime in files table"
  (let ((rows (org-roam-db-query  "select file from nodes ")))
   (cl-loop for row in rows
             collect (pcase-let* ((`(,file)
                                  row))
                              (org-roam-db-query [:update nodes :set (= createdTime $s1) :where (= file $s2)] (org-roam-reverie-get-created-time-from-path file) file)))))

(defun org-roam-reverie-migrate-nodes-table ()
  (progn (org-roam-reverie-alter-nodes-schema)
         (org-roam-reverie-update-nodes-createdTime)
         ))

(provide 'org-roam-reverie)
