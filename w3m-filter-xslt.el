;;; w3m-filter-xslt.el --- short description

;; Copyright (C) 2011  Hironori OKAMOTO

;; Author: Hironori OKAMOTO <k.ten87@gmail.com>
;; Keywords: hypermedia

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 2 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(require 'xml)

(defun w3m-filter-xslt (url xsl)
  (let ((file (make-temp-file "w3m-filter-xslt-")))
    (with-temp-file file
      (xml-print
       `((xsl:stylesheet ((xmlns:xsl . "http://www.w3.org/1999/XSL/Transform")
			  (version . "1.0"))
			 (xsl:output ((method . "html")))
			 (xsl:template ((name . "xcopy"))
				       (xsl:copy nil
						 (xsl:apply-templates ((select . "*|text()|@*")))))
			 ,@xsl
			 (xsl:template ((match . "*|@*"))
				       (xsl:call-template ((name . "xcopy"))))))))
    (call-process-region (point-min) (point-max)
			 "xsltproc"
			 t t nil
			  "--encoding" "UTF-8" "--html" file "-")
    (delete-file file))
  (delete-region (point-min) (re-search-backward "<html")))

(defun w3m-filter-xslt-delete-class (url class)
  (w3m-filter-xslt url
		   `((xsl:template ((match . ,(format "*[@class='%s']" id)))))))

(defun w3m-filter-xslt-delete-id (url id)
  (w3m-filter-xslt url
		   `((xsl:template ((match . ,(format "*[@id='%s']" id)))))))

(defun w3m-filter-xslt-google (url)
  (w3m-filter-xslt-delete-id url "leftnav"))

(provide 'w3m-filter-xslt)
;;; w3m-filter-xml.el ends here
