#include <jansson.h>
#include <stddef.h>

/* jansson.h의 매크로와 static inline 함수는 동적 심볼이 아니므로
 * Chez Scheme FFI가 직접 찾을 수 있는 외부 함수로 노출한다. */

json_type jansson_json_typeof(const json_t *json) { return json_typeof(json); }
int jansson_json_is_object(const json_t *json) { return json_is_object(json); }
int jansson_json_is_array(const json_t *json) { return json_is_array(json); }
int jansson_json_is_string(const json_t *json) { return json_is_string(json); }
int jansson_json_is_integer(const json_t *json) { return json_is_integer(json); }
int jansson_json_is_real(const json_t *json) { return json_is_real(json); }
int jansson_json_is_number(const json_t *json) { return json_is_number(json); }
int jansson_json_is_true(const json_t *json) { return json_is_true(json); }
int jansson_json_is_false(const json_t *json) { return json_is_false(json); }
int jansson_json_is_boolean(const json_t *json) { return json_is_boolean(json); }
int jansson_json_is_null(const json_t *json) { return json_is_null(json); }
int jansson_json_boolean_value(const json_t *json) { return json_boolean_value(json); }

json_t *jansson_json_boolean(int value) { return json_boolean(value); }
json_t *jansson_json_incref(json_t *json) { return json_incref(json); }
void jansson_json_decref(json_t *json) { json_decref(json); }
void jansson_json_decrefp(json_t **json) { json_decrefp(json); }
enum json_error_code jansson_json_error_code(const json_error_t *error) {
    return json_error_code(error);
}

int jansson_json_object_set(json_t *object, const char *key, json_t *value) {
    return json_object_set(object, key, value);
}
int jansson_json_object_setn(json_t *object, const char *key, size_t length,
                            json_t *value) {
    return json_object_setn(object, key, length, value);
}
int jansson_json_object_set_nocheck(json_t *object, const char *key, json_t *value) {
    return json_object_set_nocheck(object, key, value);
}
int jansson_json_object_setn_nocheck(json_t *object, const char *key, size_t length,
                                    json_t *value) {
    return json_object_setn_nocheck(object, key, length, value);
}
int jansson_json_object_iter_set(json_t *object, void *iter, json_t *value) {
    return json_object_iter_set(object, iter, value);
}
int jansson_json_object_update_new(json_t *object, json_t *other) {
    return json_object_update_new(object, other);
}
int jansson_json_object_update_existing_new(json_t *object, json_t *other) {
    return json_object_update_existing_new(object, other);
}
int jansson_json_object_update_missing_new(json_t *object, json_t *other) {
    return json_object_update_missing_new(object, other);
}

int jansson_json_array_set(json_t *array, size_t index, json_t *value) {
    return json_array_set(array, index, value);
}
int jansson_json_array_append(json_t *array, json_t *value) {
    return json_array_append(array, value);
}
int jansson_json_array_insert(json_t *array, size_t index, json_t *value) {
    return json_array_insert(array, index, value);
}
