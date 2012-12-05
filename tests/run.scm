(use fakefile files simple-sha1 test)

(define csc-options '(-d0 -O3))

;; Extensions we want to build (extension.so and extension.import.so)
(define extensions '(foo bar baz quux))

;; Helper procedures
(define (extension.scm ext)
  (make-pathname #f (->string ext) "scm"))

(define (extension.so ext)
  (make-pathname #f (->string ext) "so"))

(define (extension.import.so ext)
  (make-pathname #f (->string ext) "import.so"))

(define (extension.import.scm ext)
  (make-pathname #f (->string ext) "import.scm"))

(define (make-extension-rules ext)
  (let* ((ext-so (extension.so ext))
         (ext-scm (extension.scm ext))
         (mod-scm (extension.import.scm ext)))
    `((,(extension.so ext) (,ext-scm)
       (csc -s -J ,ext-scm))
      (,(extension.import.so ext) (,mod-scm)
       (csc -s ,@csc-options ,mod-scm)))))

(define extensions-rules
  (let loop ((extensions extensions))
    (if (null? extensions)
        '()
        (append (make-extension-rules (car extensions))
                (loop (cdr extensions))))))

(define cleanup-command
  (let ((files-to-remove
         (let loop ((extensions extensions))
           (if (null? extensions)
               '()
               (let ((ext (car extensions)))
                 (append (list (extension.so ext)
                               (extension.import.so ext)
                               (extension.import.scm ext))
                         (loop (cdr extensions))))))))
    `(rm -f ,@files-to-remove *~)))


;;; Write the Makefile
(write-makefile
 "Makefile"
 (append
  `((all ,(map car extensions-rules)))
  extensions-rules
  `((clean () ,cleanup-command))
  `((.PHONY (all clean)))))


;;; Test
(test-begin "fakefile")
(test-assert (equal? (sha1sum "Makefile") (sha1sum "Makefile.orig")))
(test-end "fakefile")

(delete-file* "Makefile")
