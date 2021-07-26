(defun org-roam-db-alter-files-schema ()
  "alter files talbe"
  (org-roam-db-query  "alter table files add column modifiedTime integer"))

(defun org-roam-db-update-file-modifiedTime ()
  "fill column modifiedTime in files table"
  (let ((rows (org-roam-db-query  "select file,mtime from files where mtime is not NULL and modifiedTime is NULL")))
   (cl-loop for row in rows
             collect (pcase-let* ((`(,file ,mtime)
                                  row))
                              (org-roam-db-query [:update files :set (= modifiedTime $s1) :where (= file $s2)] (car (time-convert mtime 1000)) file)))))

(defun org-roam-reverie-migrate ()
  (progn (org-roam-db-alter-files-schema)
         (org-roam-db-update-file-modifiedTime)
         ))
