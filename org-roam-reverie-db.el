(require 'org-roam-db)

(defun org-roam-reverie-node-exists-p (id)
  (if id
    (org-roam-db-query [:select [id] :from nodes :where (= id $s1)] id)
    nil))
