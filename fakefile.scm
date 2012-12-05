(module fakefile ((write-makefile concat))

(import chicken scheme data-structures)

(define (concat args #!optional (sep " "))
  (string-intersperse (map ->string args) sep))

(define-syntax shell
  (syntax-rules ()
    ((_ expr)
     (concat `expr))))

(define (shell* cmds)
  (map (lambda (cmd)
         (shell ,cmd))
       cmds))

(define (write-makefile file rules)
  (with-output-to-file file
    (lambda ()
      (for-each
       (lambda (rule)
         (if (string? rule)
             (printf "~a\n\n" rule)
             (let ((target (car rule))
                   (deps (cadr rule))
                   (cmds (cddr rule)))
               (printf "~a: ~a\n" target (concat deps))
               (if (null? cmds)
                   (newline)
                   (printf "\t~a\n\n" (concat (shell* cmds) "\n\t"))))))
       rules))))

) ;; end module
