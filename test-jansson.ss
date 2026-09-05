#!r6rs

;; scheme --libdirs . --compile-imported-libraries --script test-jansson.ss
(import (chezscheme) (jansson))

(define (check label actual expected)
  (if (equal? actual expected)
      (begin
        (display "PASS: ")
        (display label)
        (newline))
      (begin
        (display "FAIL: ")
        (display label)
        (display "\n  actual: ")
        (write actual)
        (display "\n  expected: ")
        (write expected)
        (newline))))

(define parsed
  (chez-json-parse
   "{\"project\":\"Chez JSON FFI\",\"meta\":[10.4,null,true,\"Scheme 프로젝트\"]}"))

(check "JSON 파싱"
       parsed
       '((project . "Chez JSON FFI")
         (meta . #(10.4 null #t "Scheme 프로젝트"))))

(check "문자열 키 옵션"
       (chez-json-parse "{\"project\":\"Chez JSON FFI\"}" 'string)
       '(("project" . "Chez JSON FFI")))

(let ([parsed-table
       (chez-json-parse "{\"project\":\"Chez JSON FFI\",\"count\":2}"
                        'hash-table)])
  (check "해시 테이블 옵션"
         (list (hashtable-ref parsed-table 'project #f)
               (hashtable-ref parsed-table 'count #f))
         '("Chez JSON FFI" 2)))

(let ([parsed-table
       (chez-json-parse "{\"project\":\"Chez JSON FFI\"}"
                        'hash-table
                        'string)])
  (check "문자열 키 해시 테이블 옵션"
         (hashtable-ref parsed-table "project" #f)
         "Chez JSON FFI"))

(let ([parsed-table
       (chez-json-parse "{\"meta\":{\"enabled\":true}}" 'hash-table)])
  (check "중첩 객체 해시 테이블 옵션"
         (hashtable-ref (hashtable-ref parsed-table 'meta #f)
                        'enabled
                        #f)
         #t))

(check "JSON 직렬화"
       (chez-json-serialize
        '((project . "Chez JSON FFI")
          (meta . #(10.4 null #t "Scheme 프로젝트"))))
       "{\"project\":\"Chez JSON FFI\",\"meta\":[10.4,null,true,\"Scheme 프로젝트\"]}")

(check "중첩 리스트와 심볼 키"
       (chez-json-serialize
        '(((name . "앨리스") (tags . (developer schemer))) (1 2 3)))
       "[{\"name\":\"앨리스\",\"tags\":[\"developer\",\"schemer\"]},[1,2,3]]")

(check "빈 배열"
       (chez-json-parse "[]")
       (vector))

(check "빈 객체"
       (chez-json-parse "{}")
       '())

(check "잘못된 JSON"
       (chez-json-parse "{invalid}")
       #f)
