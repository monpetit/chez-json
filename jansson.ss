#!r6rs

(library (jansson)
  (export
    json-t json-error-t json-type json-error-code
    json-object json-array json-string json-stringn json-string-nocheck
    json-stringn-nocheck json-integer json-real json-true json-false json-boolean
    json-null json-delete json-incref json-decref json-decrefp
    json-typeof json-is-object json-is-array json-is-string json-is-integer
    json-is-real json-is-number json-is-true json-is-false json-is-boolean
    json-is-null json-boolean-value
    json-object-seed json-object-size json-object-get json-object-getn
    json-object-set-new json-object-setn-new json-object-set-new-nocheck
    json-object-setn-new-nocheck json-object-set json-object-setn
    json-object-set-nocheck json-object-setn-nocheck json-object-del
    json-object-deln json-object-clear json-object-update
    json-object-update-existing json-object-update-missing
    json-object-update-recursive json-object-update-new
    json-object-update-existing-new json-object-update-missing-new
    json-object-iter json-object-iter-at json-object-key-to-iter
    json-object-iter-next json-object-iter-key json-object-iter-key-len
    json-object-iter-value json-object-iter-set-new json-object-iter-set
    json-array-size json-array-get json-array-set-new json-array-append-new
    json-array-insert-new json-array-remove json-array-clear json-array-extend
    json-array-set json-array-append json-array-insert
    json-string-value json-string-length json-integer-value json-real-value
    json-number-value json-string-set json-string-setn json-string-set-nocheck
    json-string-setn-nocheck json-integer-set json-real-set
    json-equal json-copy json-deep-copy
    json-loads json-loadb json-loadf json-loadfd json-load-file
    json-dumps json-dumpb json-dumpf json-dumpfd json-dump-file
    json-set-alloc-funcs json-set-alloc-funcs2
    jansson-version-str jansson-version-cmp
    json-object-type json-array-type json-string-type json-integer-type
    json-real-type json-true-type json-false-type json-null-type
    json-error-unknown json-error-out-of-memory json-error-stack-overflow
    json-error-cannot-open-file json-error-invalid-argument json-error-invalid-utf8
    json-error-premature-end-of-input json-error-end-of-input-expected
    json-error-invalid-syntax json-error-invalid-format json-error-wrong-type
    json-error-null-character json-error-null-value json-error-null-byte-in-key
    json-error-duplicate-key json-error-numeric-overflow json-error-item-not-found
    json-error-index-out-of-range
    json-validate-only json-strict json-reject-duplicates json-disable-eof-check
    json-decode-any json-decode-int-as-real json-allow-nul json-max-indent
    json-compact json-ensure-ascii json-sort-keys json-preserve-order
    json-encode-any json-escape-slash json-embed json-indent json-real-precision
    scheme->jansson jansson->scheme chez-json-parse chez-json-serialize)
  (import (chezscheme))

  (define-ftype json-t
    (struct [type int] [refcount size_t]))
  (define-ftype json-error-t
    (struct [line int] [column int] [position int]
            [source (array 80 char)] [text (array 160 char)]))
  (define-ftype json-type int)

  (define-syntax fp
    (syntax-rules ()
      [(_ name args result)
       (begin
         (load-shared-object "libjansson.so")
         (load-shared-object "./libjansson-bridge.so")
         (foreign-procedure name args result))]))

  (define json-object (fp "json_object" () void*))
  (define json-array (fp "json_array" () void*))
  (define json-string (fp "json_string" (string) void*))
  (define json-stringn (fp "json_stringn" (string size_t) void*))
  (define json-string-nocheck (fp "json_string_nocheck" (string) void*))
  (define json-stringn-nocheck (fp "json_stringn_nocheck" (string size_t) void*))
  (define json-integer (fp "json_integer" (integer-64) void*))
  (define json-real (fp "json_real" (double-float) void*))
  (define json-true (fp "json_true" () void*))
  (define json-false (fp "json_false" () void*))
  (define json-null (fp "json_null" () void*))
  (define json-delete (fp "json_delete" (void*) void))
  (define json-incref (fp "jansson_json_incref" (void*) void*))
  (define json-decref (fp "jansson_json_decref" (void*) void))
  (define json-decrefp (fp "jansson_json_decrefp" (void*) void))
  (define json-boolean (fp "jansson_json_boolean" (int) void*))

  (define json-typeof (fp "jansson_json_typeof" (void*) int))
  (define json-is-object (fp "jansson_json_is_object" (void*) boolean))
  (define json-is-array (fp "jansson_json_is_array" (void*) boolean))
  (define json-is-string (fp "jansson_json_is_string" (void*) boolean))
  (define json-is-integer (fp "jansson_json_is_integer" (void*) boolean))
  (define json-is-real (fp "jansson_json_is_real" (void*) boolean))
  (define json-is-number (fp "jansson_json_is_number" (void*) boolean))
  (define json-is-true (fp "jansson_json_is_true" (void*) boolean))
  (define json-is-false (fp "jansson_json_is_false" (void*) boolean))
  (define json-is-boolean (fp "jansson_json_is_boolean" (void*) boolean))
  (define json-is-null (fp "jansson_json_is_null" (void*) boolean))
  (define json-boolean-value (fp "jansson_json_boolean_value" (void*) boolean))
  (define json-error-code (fp "jansson_json_error_code" (void*) int))

  (define json-object-seed (fp "json_object_seed" (size_t) void))
  (define json-object-size (fp "json_object_size" (void*) size_t))
  (define json-object-get (fp "json_object_get" (void* string) void*))
  (define json-object-getn (fp "json_object_getn" (void* string size_t) void*))
  (define json-object-set-new (fp "json_object_set_new" (void* string void*) int))
  (define json-object-setn-new (fp "json_object_setn_new" (void* string size_t void*) int))
  (define json-object-set-new-nocheck (fp "json_object_set_new_nocheck" (void* string void*) int))
  (define json-object-setn-new-nocheck (fp "json_object_setn_new_nocheck" (void* string size_t void*) int))
  (define json-object-set (fp "jansson_json_object_set" (void* string void*) int))
  (define json-object-setn (fp "jansson_json_object_setn" (void* string size_t void*) int))
  (define json-object-set-nocheck (fp "jansson_json_object_set_nocheck" (void* string void*) int))
  (define json-object-setn-nocheck (fp "jansson_json_object_setn_nocheck" (void* string size_t void*) int))
  (define json-object-del (fp "json_object_del" (void* string) int))
  (define json-object-deln (fp "json_object_deln" (void* string size_t) int))
  (define json-object-clear (fp "json_object_clear" (void*) int))
  (define json-object-update (fp "json_object_update" (void* void*) int))
  (define json-object-update-existing (fp "json_object_update_existing" (void* void*) int))
  (define json-object-update-missing (fp "json_object_update_missing" (void* void*) int))
  (define json-object-update-recursive (fp "json_object_update_recursive" (void* void*) int))
  (define json-object-update-new (fp "jansson_json_object_update_new" (void* void*) int))
  (define json-object-update-existing-new (fp "jansson_json_object_update_existing_new" (void* void*) int))
  (define json-object-update-missing-new (fp "jansson_json_object_update_missing_new" (void* void*) int))
  (define json-object-iter (fp "json_object_iter" (void*) void*))
  (define json-object-iter-at (fp "json_object_iter_at" (void* string) void*))
  (define json-object-key-to-iter (fp "json_object_key_to_iter" (string) void*))
  (define json-object-iter-next (fp "json_object_iter_next" (void* void*) void*))
  (define json-object-iter-key (fp "json_object_iter_key" (void*) string))
  (define json-object-iter-key-len (fp "json_object_iter_key_len" (void*) size_t))
  (define json-object-iter-value (fp "json_object_iter_value" (void*) void*))
  (define json-object-iter-set-new (fp "json_object_iter_set_new" (void* void* void*) int))
  (define json-object-iter-set (fp "jansson_json_object_iter_set" (void* void* void*) int))

  (define json-array-size (fp "json_array_size" (void*) size_t))
  (define json-array-get (fp "json_array_get" (void* size_t) void*))
  (define json-array-set-new (fp "json_array_set_new" (void* size_t void*) int))
  (define json-array-append-new (fp "json_array_append_new" (void* void*) int))
  (define json-array-insert-new (fp "json_array_insert_new" (void* size_t void*) int))
  (define json-array-remove (fp "json_array_remove" (void* size_t) int))
  (define json-array-clear (fp "json_array_clear" (void*) int))
  (define json-array-extend (fp "json_array_extend" (void* void*) int))
  (define json-array-set (fp "jansson_json_array_set" (void* size_t void*) int))
  (define json-array-append (fp "jansson_json_array_append" (void* void*) int))
  (define json-array-insert (fp "jansson_json_array_insert" (void* size_t void*) int))

  (define json-string-value (fp "json_string_value" (void*) string))
  (define json-string-length (fp "json_string_length" (void*) size_t))
  (define json-integer-value (fp "json_integer_value" (void*) integer-64))
  (define json-real-value (fp "json_real_value" (void*) double-float))
  (define json-number-value (fp "json_number_value" (void*) double-float))
  (define json-string-set (fp "json_string_set" (void* string) int))
  (define json-string-setn (fp "json_string_setn" (void* string size_t) int))
  (define json-string-set-nocheck (fp "json_string_set_nocheck" (void* string) int))
  (define json-string-setn-nocheck (fp "json_string_setn_nocheck" (void* string size_t) int))
  (define json-integer-set (fp "json_integer_set" (void* integer-64) int))
  (define json-real-set (fp "json_real_set" (void* double-float) int))

  (define json-equal (fp "json_equal" (void* void*) boolean))
  (define json-copy (fp "json_copy" (void*) void*))
  (define json-deep-copy (fp "json_deep_copy" (void*) void*))
  (define json-loads (fp "json_loads" (string size_t void*) void*))
  (define json-loadb (fp "json_loadb" (u8* size_t size_t void*) void*))
  (define json-loadf (fp "json_loadf" (void* size_t void*) void*))
  (define json-loadfd (fp "json_loadfd" (int size_t void*) void*))
  (define json-load-file (fp "json_load_file" (string size_t void*) void*))
  (define json-dumps (fp "json_dumps" (void* size_t) string))
  (define json-dumpb (fp "json_dumpb" (void* u8* size_t size_t) size_t))
  (define json-dumpf (fp "json_dumpf" (void* void* size_t) int))
  (define json-dumpfd (fp "json_dumpfd" (void* int size_t) int))
  (define json-dump-file (fp "json_dump_file" (void* string size_t) int))
  (define json-set-alloc-funcs (fp "json_set_alloc_funcs" (void* void*) void))
  (define json-set-alloc-funcs2 (fp "json_set_alloc_funcs2" (void* void* void*) void))
  (define jansson-version-str (fp "jansson_version_str" () string))
  (define jansson-version-cmp (fp "jansson_version_cmp" (int int int) int))

  (define json-object-type 0)
  (define json-array-type 1)
  (define json-string-type 2)
  (define json-integer-type 3)
  (define json-real-type 4)
  (define json-true-type 5)
  (define json-false-type 6)
  (define json-null-type 7)
  (define json-error-unknown 0)
  (define json-error-out-of-memory 1)
  (define json-error-stack-overflow 2)
  (define json-error-cannot-open-file 3)
  (define json-error-invalid-argument 4)
  (define json-error-invalid-utf8 5)
  (define json-error-premature-end-of-input 6)
  (define json-error-end-of-input-expected 7)
  (define json-error-invalid-syntax 8)
  (define json-error-invalid-format 9)
  (define json-error-wrong-type 10)
  (define json-error-null-character 11)
  (define json-error-null-value 12)
  (define json-error-null-byte-in-key 13)
  (define json-error-duplicate-key 14)
  (define json-error-numeric-overflow 15)
  (define json-error-item-not-found 16)
  (define json-error-index-out-of-range 17)
  (define json-validate-only #x1)
  (define json-strict #x2)
  (define json-reject-duplicates #x1)
  (define json-disable-eof-check #x2)
  (define json-decode-any #x4)
  (define json-decode-int-as-real #x8)
  (define json-allow-nul #x10)
  (define json-max-indent #x1f)
  (define json-compact #x20)
  (define json-ensure-ascii #x40)
  (define json-sort-keys #x80)
  (define json-preserve-order #x100)
  (define json-encode-any #x200)
  (define json-escape-slash #x400)
  (define json-embed #x10000)
  (define (json-indent n) (bitwise-and n json-max-indent))
  (define (json-real-precision n) (bitwise-arithmetic-shift-left
                                   (bitwise-and n #x1f) 11))

  (define (jansson-alist? value)
    (and (pair? value)
         (list? value)
         (for-all
          (lambda (entry)
            (and (pair? entry)
                 (or (string? (car entry)) (symbol? (car entry)))))
          value)))

  (define (scheme->jansson value)
    (cond
      [(eq? value #t) (json-true)]
      [(eq? value #f) (json-false)]
      [(string? value) (json-string value)]
      [(and (symbol? value) (eq? value 'null)) (json-null)]
      [(symbol? value) (json-string (symbol->string value))]
      [(and (integer? value) (exact? value)) (json-integer value)]
      [(real? value) (json-real (exact->inexact value))]
      [(vector? value)
       (let ([array (json-array)])
         (do ([index 0 (+ index 1)])
             [(= index (vector-length value)) array]
           (json-array-append-new array
                                  (scheme->jansson (vector-ref value index)))))]
      [(jansson-alist? value)
       (let ([object (json-object)])
         (for-each
          (lambda (entry)
            (let ([key (car entry)] [item (cdr entry)])
              (json-object-set-new
               object
               (if (string? key) key (symbol->string key))
               (scheme->jansson item))))
          value)
         object)]
      [(pair? value)
       (let ([array (json-array)])
         (for-each
          (lambda (item) (json-array-append-new array (scheme->jansson item)))
          value)
         array)]
      [(null? value) (json-array)]
      [else (json-null)]))

  (define (parse-option options option)
    (memq option options))

  (define (jansson-object-key iterator key-type)
    (let ([key (json-object-iter-key iterator)])
      (if (eq? key-type 'string)
          key
          (string->symbol key))))

  (define (jansson->scheme value key-type object-type)
    (cond
      [(not value) #f]
      [(json-is-null value) 'null]
      [(json-is-true value) #t]
      [(json-is-false value) #f]
      [(json-is-string value) (json-string-value value)]
      [(json-is-integer value) (json-integer-value value)]
      [(json-is-real value) (json-real-value value)]
      [(json-is-array value)
       (let* ([length (json-array-size value)]
              [result (make-vector length)])
         (do ([index 0 (+ index 1)])
             [(= index length) result]
           (vector-set! result index
                        (jansson->scheme (json-array-get value index)
                                         key-type
                                         object-type))))]
      [(json-is-object value)
       (if (eq? object-type 'hash-table)
           (let ([result (make-hashtable equal-hash equal?)])
             (let loop ([iterator (json-object-iter value)])
               (unless (or (not iterator)
                           (and (integer? iterator) (zero? iterator)))
                 (hashtable-set!
                  result
                  (jansson-object-key iterator key-type)
                  (jansson->scheme (json-object-iter-value iterator)
                                   key-type
                                   object-type))
                 (loop (json-object-iter-next value iterator))))
             result)
           (let loop ([iterator (json-object-iter value)] [result '()])
             (if (or (not iterator)
                     (and (integer? iterator) (zero? iterator)))
                 (reverse result)
                 (loop (json-object-iter-next value iterator)
                       (cons (cons (jansson-object-key iterator key-type)
                                   (jansson->scheme
                                    (json-object-iter-value iterator)
                                    key-type
                                    object-type))
                             result)))))]
      [else #f]))

  (define (chez-json-parse input . options)
    (let ([key-type (if (parse-option options 'string) 'string 'symbol)]
          [object-type (if (parse-option options 'hash-table)
                           'hash-table
                           'alist)])
      (let ([error-address (foreign-alloc (ftype-sizeof json-error-t))])
        (let ([root (json-loads input 0 error-address)])
          (if (and root (not (and (integer? root) (zero? root))))
              (let ([result (jansson->scheme root key-type object-type)])
                (json-decref root)
                (foreign-free error-address)
                result)
              (begin
                (foreign-free error-address)
                #f))))))

  (define (chez-json-serialize value)
    (let ([root (scheme->jansson value)])
      (let ([result (json-dumps root json-compact)])
        (json-decref root)
        result))))
