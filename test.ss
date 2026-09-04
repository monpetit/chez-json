;; test.ss
;; scheme --script test.ss

(load-shared-object "./libchezjson.so")

(define json-parse (foreign-procedure "chez_json_parse" (string) ptr))
(define json-serialize (foreign-procedure "chez_json_serialize" (ptr) ptr))

;; 정상 동작 테스트
(define data (json-parse "{\"project\": \"Chez JSON FFI\", \"meta\": [10.4, null, true, \"Scheme 프로젝트\"]}"))
(display "Parsed Data: ") (write data) (newline)
(display "Serialized Data: ") (display (json-serialize data)) (newline)
(newline)

(define data (json-parse "{\"프로젝트\": \"테스트: Chez JSON FFI\", \"meta\": [10.4, null, true]}"))
(display "Parsed Data: ") (write data) (newline)
(display "Serialized Data: ") (display (json-serialize data)) (newline)
(newline)

;; Alist 테스트 (키가 문자열)
(define alist '((("name" . "John") ("age" . 30) ("scores" . #(90 85 88)))))
(display "Alist: ") (write alist) (newline)
(display "Serialized Alist: ") (display (json-serialize alist)) (newline)
(newline)

;; Alist 테스트 (키가 심볼)
(define alist-symbol '(((name . "John") (age . 30) (scores . #(90 85 88)))))
(display "Alist (symbol keys): ") (write alist-symbol) (newline)
(display "Serialized: ") (display (json-serialize alist-symbol)) (newline)
(newline)

;; 일반 리스트 테스트
(define normal-list '(1 2 3 4 5 도그마))
(display "List: ") (write normal-list) (newline)
(display "Serialized List: ") (display (json-serialize normal-list)) (newline)
(newline)

;; 중첩 리스트 테스트
(define nested '((1 2) (3 4) (5 6)))
(display "Nested: ") (write nested) (newline)
(display "Serialized Nested: ") (display (json-serialize nested)) (newline)
(newline)

;; 복잡한 혼합 테스트
(define mixed '((("name" . "앨리스") ("tags" . ("developer" "schemer"))) (1 2 3 도그마)))
(display "Mixed: ") (write mixed) (newline)
(display "Serialized Mixed: ") (display (json-serialize mixed)) (newline)
