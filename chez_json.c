#include <jansson.h>
#include <scheme.h>
#include <stdlib.h>
#include <string.h>

/* =========================================================================
   Sstring_to_utf8 - Scheme String -> UTF-8 C String
   ========================================================================= */
char* Sstring_to_utf8(ptr x, size_t *out_len) {
    if (!Sstringp(x)) return NULL;
    
    iptr len = Sstring_length(x);
    char* buffer = (char*)malloc(len * 4 + 1);
    if (!buffer) return NULL;
    
    char* out = buffer;
    for (iptr i = 0; i < len; i++) {
        unsigned int ch = (unsigned int)Sstring_ref(x, i);
        
        if (ch < 0x80) {
            *out++ = (char)ch;
        } else if (ch < 0x800) {
            *out++ = (char)(0xC0 | (ch >> 6));
            *out++ = (char)(0x80 | (ch & 0x3F));
        } else if (ch >= 0xD800 && ch <= 0xDFFF) {
            // 유효하지 않은 UTF-16 서러게이트 영역 방어
            *out++ = '?';
        } else if (ch < 0x10000) {
            *out++ = (char)(0xE0 | (ch >> 12));
            *out++ = (char)(0x80 | ((ch >> 6) & 0x3F));
            *out++ = (char)(0x80 | (ch & 0x3F));
        } else if (ch < 0x110000) {
            *out++ = (char)(0xF0 | (ch >> 18));
            *out++ = (char)(0x80 | ((ch >> 12) & 0x3F));
            *out++ = (char)(0x80 | ((ch >> 6) & 0x3F));
            *out++ = (char)(0x80 | (ch & 0x3F));
        } else {
            *out++ = '?';
        }
    }
    *out = '\0';
    if (out_len) *out_len = (size_t)(out - buffer);
    return buffer;
}

/* =========================================================================
   is_alist - alist 확인
   ========================================================================= */
int is_alist(ptr x) {
    if (!Spairp(x)) return 0;
    
    ptr curr = x;
    while (Spairp(curr)) {
        ptr pair = Scar(curr);
        if (!Spairp(pair)) return 0;
        
        ptr key = Scar(pair);
        if (!Sstringp(key) && !Ssymbolp(key)) {
            return 0;
        }
        curr = Scdr(curr);
    }
    return (curr == Snil);
}

/* =========================================================================
   1. DECODING: JSON -> Scheme
   ========================================================================= */
ptr jansson_to_scheme(json_t *element) {
  if (!element) return Snil;

  switch (json_typeof(element)) {
  case JSON_NULL:    return Sstring_to_symbol("null");
  case JSON_TRUE:    return Strue;
  case JSON_FALSE:   return Sfalse;
  case JSON_STRING: {
    const char *str = json_string_value(element);
    size_t len = json_string_length(element);
    return Sstring_utf8(str, (iptr)len);
  }
  case JSON_INTEGER: return Sinteger((iptr)json_integer_value(element));
  case JSON_REAL:    return Sflonum(json_real_value(element));

  case JSON_ARRAY: {
    size_t size = json_array_size(element);
    ptr scheme_vector = Smake_vector(size, Sfalse);
    size_t index;
    json_t *value;
    json_array_foreach(element, index, value) {
      Svector_set(scheme_vector, index, jansson_to_scheme(value));
    }
    return scheme_vector;
  }

  case JSON_OBJECT: {
    ptr alist = Snil;
    const char *key;
    json_t *value;
    json_object_foreach(element, key, value) {
      ptr s_key = Sstring_utf8(key, (iptr)strlen(key));
      ptr s_val = jansson_to_scheme(value);
      ptr pair = Scons(s_key, s_val);
      alist = Scons(pair, alist);
    }
    return alist;
  }
  default: return Snil;
  }
}

ptr chez_json_parse(const char *json_in) {
  json_error_t error;
  json_t *root = json_loads(json_in, 0, &error);
  if (!root) return Sfalse;

  ptr result = jansson_to_scheme(root);
  json_decref(root);
  return result;
}

/* =========================================================================
   2. ENCODING: Scheme -> JSON
   ========================================================================= */
json_t *scheme_to_jansson(ptr x) {
  if (x == Strue) return json_true();
  if (x == Sfalse) return json_false();

  // String -> JSON String
  if (Sstringp(x)) {
    size_t byte_len = 0;
    char *c_str = Sstring_to_utf8(x, &byte_len);
    if (!c_str) return json_null();
    json_t *j_str = json_stringn(c_str, byte_len);
    free(c_str);
    return j_str;
  }

  // Number -> JSON Number
  if (Sfixnump(x)) return json_integer((json_int_t)Sfixnum_value(x));
  if (Sbignump(x)) return json_integer((json_int_t)Sinteger_value(x));
  if (Sflonump(x)) return json_real(Sflonum_value(x));

  // Symbol -> JSON Null or JSON String
  if (Ssymbolp(x)) {
    if (x == Sstring_to_symbol("null")) {
      return json_null();
    }
    ptr sym_str = Ssymbol_to_string(x);
    size_t byte_len = 0;
    char *c_str = Sstring_to_utf8(sym_str, &byte_len);
    if (!c_str) return json_null();
    json_t *j_str = json_stringn(c_str, byte_len);
    free(c_str);
    return j_str;
  }

  // Vector -> JSON Array
  if (Svectorp(x)) {
    json_t *j_arr = json_array();
    iptr len = Svector_length(x);
    for (iptr i = 0; i < len; i++) {
      json_array_append_new(j_arr, scheme_to_jansson(Svector_ref(x, i)));
    }
    return j_arr;
  }

  // Alist -> JSON Object
  if (is_alist(x)) {
    json_t *j_obj = json_object();
    ptr curr = x;

    while (Spairp(curr)) {
      ptr pair = Scar(curr);
      ptr key_obj = Scar(pair);
      ptr val_obj = Scdr(pair);

      size_t key_len = 0;
      char *key_str = NULL;
      if (Sstringp(key_obj)) {
        key_str = Sstring_to_utf8(key_obj, &key_len);
      } else if (Ssymbolp(key_obj)) {
        ptr sym_str = Ssymbol_to_string(key_obj);
        key_str = Sstring_to_utf8(sym_str, &key_len);
      }
      
      if (key_str) {
        json_object_setn_new(j_obj, key_str, key_len, scheme_to_jansson(val_obj));
        free(key_str);
      }
      curr = Scdr(curr);
    }
    return j_obj;
  }

  // 일반 리스트 -> JSON Array
  if (Spairp(x)) {
    json_t *j_arr = json_array();
    ptr curr = x;
    while (Spairp(curr)) {
      json_array_append_new(j_arr, scheme_to_jansson(Scar(curr)));
      curr = Scdr(curr);
    }
    return j_arr;
  }

  // 빈 리스트 -> JSON Array
  if (x == Snil) return json_array();

  return json_null();
}

ptr chez_json_serialize(ptr x) {
  json_t *root = scheme_to_jansson(x);
  if (!root) return Sfalse;

  char *json_out = json_dumps(root, JSON_COMPACT);
  json_decref(root);

  if (!json_out) return Sfalse;

  ptr s_res = Sstring_utf8(json_out, strlen(json_out));
  free(json_out);
  return s_res;
}
