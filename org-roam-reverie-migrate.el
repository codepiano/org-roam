(require 'org-roam-db)

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

(provide 'org-roam-reverie-migrate)
