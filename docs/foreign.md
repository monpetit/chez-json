# Chez Scheme 외부 인터페이스 가이드

## 목차
- [4.1 서브프로세스 통신](#41-서브프로세스-통신)
- [4.2 Scheme에서 외부 호출](#42-scheme에서-외부-호출)
- [4.3 Scheme으로의 호출](#43-scheme으로의-호출)
- [4.4 연속성과 외부 호출](#44-연속성과-외부-호출)
- [4.5 외부 데이터](#45-외부-데이터)
- [4.6 관리 객체의 외부 배열](#46-관리-객체의-외부-배열)
- [4.7 외부 프로시저 접근 제공](#47-외부-프로시저-접근-제공)
- [4.8 다른 외부 언어 사용](#48-다른-외부-언어-사용)
- [4.9 외부 오류 결과](#49-외부-오류-결과)
- [4.10 C 라이브러리 루틴](#410-c-라이브러리-루틴)
- [4.11 예제: 소켓 연산](#411-예제-소켓-연산)

---

Chez Scheme은 외부 코드(다른 언어로 작성된 코드)와 상호작용하는 두 가지 방법을 제공합니다.

첫 번째는 서브프로세스 생성 및 통신을 통한 방식이며, 4.1절에서 논의됩니다.

두 번째는 C로 작성된 프로시저를 Scheme에서 정적 또는 동적으로 로드 및 호출하고, Scheme에서 작성된 프로시저를 C에서 호출하는 방식입니다. 이러한 메커니즘은 4.2절부터 4.4절까지 논의됩니다.

C 오브젝트 코드의 정적 로딩 방법은 실행 중인 머신에 따라 다릅니다; Chez Scheme과 함께 배포된 설치 지침을 참조하세요.

---

## 4.1 서브프로세스 통신

두 개의 프로시저, `system`과 `process`는 서브프로세스를 생성하는 데 사용됩니다. 두 프로시저 모두 단일 문자열 인자를 받아들이고 문자열에 포함된 셸 명령을 실행할 서브프로세스를 생성합니다. `system` 프로시저는 프로세스가 종료될 때까지 대기한 후 반환하지만, `process` 프로시저는 프로세스가 종료될 때까지 기다리지 않고 즉시 반환합니다. `system`으로 생성된 서브프로세스의 표준 입력 및 출력 파일은 사용자의 콘솔과 통신하는 데 사용될 수 있습니다. `process`로 생성된 서브프로세스의 표준 입력 및 출력 파일은 Scheme 프로세스와 통신하는 데 사용될 수 있습니다.

---

### 프로시저: `(system command)`

**반환값:** 아래 설명 참조  
**라이브러리:** `(chezscheme)`

`command`는 문자열이어야 합니다.

`system` 프로시저는 `command`에 의해 지정된 연산을 수행할 서브프로세스를 생성합니다. 서브프로세스는 Scheme 프로세스에서 사용하는 동일한 콘솔 입력 및 콘솔 출력 파일을 통해 사용자와 통신할 수 있습니다. 서브프로세스를 생성한 후, `system`은 프로세스가 종료될 때까지 대기한 후 반환합니다.

서브프로세스가 종료되면, `system`은 서브프로세스의 종료 코드를 반환합니다. 단, (Unix 기반 시스템에서) 시그널이 서브프로세스를 종료시킨 경우, `system`은 종료를 야기한 시그널의 부정 값을 반환합니다(예: SIGHUP의 경우 -1).

---

### 프로시저: `(open-process-ports command)`  
### 프로시저: `(open-process-ports command b-mode)`  
### 프로시저: `(open-process-ports command b-mode ?transcoder)`

**반환값:** 아래 설명 참조  
**라이브러리:** `(chezscheme)`

`command`는 문자열이어야 합니다. `?transcoder`가 존재하고 `#f`가 아닌 경우, 트랜스코더여야 하며, 이 프로시저는 텍스트 포트를 생성하고 각 포트의 트랜스코더는 `?transcoder`입니다. 그렇지 않으면 이 프로시저는 바이너리 포트를 반환합니다. `b-mode`는 이 프로시저가 반환하는 각 포트에서 사용하는 버퍼 모드를 지정하며 기본값은 `block`입니다. 버퍼 모드는 *The Scheme Programming Language, 4th Edition*의 7.2절에 설명되어 있습니다.

`open-process-ports`는 `command`에 의해 지정된 연산을 수행할 서브프로세스를 생성합니다. `system`과 달리, `process`는 서브프로세스를 생성한 후 즉시 반환합니다(즉, 서브프로세스가 종료될 때까지 기다리지 않습니다). 네 가지 값을 반환합니다:

1. `to-stdin` - Scheme이 서브프로세스의 표준 입력 파일을 통해 서브프로세스로 출력을 보낼 수 있는 출력 포트
2. `from-stdout` - Scheme이 서브프로세스의 표준 출력 파일을 통해 서브프로세스로부터 입력을 읽을 수 있는 입력 포트
3. `from-stderr` - Scheme이 서브프로세스의 표준 오류 파일을 통해 서브프로세스로부터 입력을 읽을 수 있는 입력 포트
4. `process-id` - 호스트 운영 체제에서 제공하는 생성된 서브프로세스를 식별하는 정수

프로세스가 종료되거나 표준 출력 파일 디스크립터를 닫으면, `from-stdout`에서 입력을 읽는 프로시저는 파일 끝(eof) 객체를 반환합니다. 마찬가지로, 프로세스가 종료되거나 표준 오류 파일 디스크립터를 닫으면, `from-stderr`에서 입력을 읽는 프로시저는 파일 끝 객체를 반환합니다.

`input-port-ready?` 술어는 서브프로세스가 Scheme으로 입력을 보냈는지 감지하는 데 사용될 수 있습니다.

Chez Scheme은 효율성을 위해 출력을 버퍼링하므로, `flush-output-port`를 `to-stdin`에 호출하여 즉시 서브프로세스로 출력을 강제로 보내야 하는 경우가 있습니다.

UNIX 시스템에서 `process-id`는 `command`를 실행하기 위해 생성된 셸의 프로세스 식별자입니다. `command`가 셸 명령이 아닌 실행 파일을 호출하는 데 사용되는 경우, `command` 앞에 문자열 `"exec "`를 붙이는 것이 유용할 수 있습니다. 이는 셸이 새 프로세스를 포크하지 않고 명명된 실행 파일을 직접 로드하고 실행하도록 합니다(셸의 꼬리 호출에 해당). 이렇게 하면 생성되는 서브프로세스 수가 하나 줄어들고, 셸이 제어를 이전한 후 `process-id`가 실행 파일의 프로세스 식별자를 반영하게 됩니다.

---

### 프로시저: `(process command)`

**반환값:** 설명 참조  
**라이브러리:** `(chezscheme)`

`command`는 문자열이어야 합니다.

`process`는 `open-process-ports`와 유사하지만 덜 일반적입니다. 서브프로세스의 표준 오류 출력을 읽을 수 있는 포트를 반환하지 않으며, 항상 텍스트 포트를 생성합니다. `open-process-ports`의 네 개의 개별 값 대신 세 개의 값의 리스트를 반환합니다. 반환된 리스트는 순서대로 `from-stdout`, `to-stdin`, `process-id`를 포함하며, 이는 `open-process-ports`의 두 번째, 첫 번째, 네 번째 반환값에 해당합니다.

---

## 4.2 Scheme에서 외부 호출

Chez Scheme의 외부-프로시저 인터페이스를 통해 Scheme 프로그램은 C 또는 C와 동일한 호출 규약을 따르는 언어로 작성된 프로시저를 호출할 수 있습니다.

외부 프로시저를 Scheme에서 호출하려면 두 단계가 필요합니다:
1. 외부 프로시저를 컴파일하고 로드합니다(정적 또는 동적으로, 4.7절 설명 참조).
2. Scheme에서 외부 프로시저에 대한 접근을 설정합니다(이 절에서 설명).

외부 프로시저에 대한 접근이 설정되면 일반 Scheme 프로시저처럼 호출할 수 있습니다.

외부 프로시저는 Scheme 메모리 관리 및 예외 처리 시스템과 독립적으로 작동하므로 사용 시 각별히 주의해야 합니다. 외부-프로시저 인터페이스는 타입 검사(최적화 수준 3 미만에서)와 타입 변환을 제공하지만, 적절한 인자 및 결과 타입을 지정하여 Scheme과 외부 프로시저 간의 데이터 공유가 안전하게 이루어지도록 프로그래머가 보장해야 합니다.

Scheme에서 호출 가능한 외부 프로시저의 래퍼는 `ftype-ref`와 함수 ftype을 통해서도 생성할 수 있습니다(4.5절).

---

### 문법: `(foreign-procedure conv ... entry-exp (param-type ...) res-type)`

**반환값:** 프로시저  
**라이브러리:** `(chezscheme)`

`entry-exp`은 유효한 외부 프로시저 진입점을 나타내는 문자열 또는 외부 프로시저의 주소를 나타내는 정수로 평가되어야 합니다. `param-types`와 `res-type`은 아래 설명된 대로 심볼 또는 구조화된 형태여야 합니다.

`foreign-procedure` 표현식이 평가되면, `entry-exp`에 의해 지정된 외부 프로시저를 호출할 Scheme 프로시저가 생성됩니다. 프로시저가 호출될 때 각 인자는 지정된 `param-type`에 따라 검사되고 변환된 후 외부 프로시저에 전달됩니다. 외부 프로시저 호출의 결과는 `res-type`에 지정된 대로 변환됩니다. 동일한 외부 진입점에 대해 여러 프로시저가 생성될 수 있습니다.

각 `conv`는 사용할 호출 규약을 조정합니다. `#f`는 대상 머신의 기본 호출 규약을 나타내는 `conv`로 허용됩니다(따라서 `#f`는 효과가 없습니다). Windows에서는 세 가지 다른 규약이 지원됩니다: `__stdcall`, `__cdecl`, `__com`(32비트 전용). `__cdecl`이 기본값이므로 `__cdecl`을 지정하는 것은 `#f` 또는 규약을 지정하지 않는 것과 동일합니다.

추가적으로, `conv`는 다음과 같을 수 있습니다:
- `__collect_safe` - 외부 프로시저 호출 중에 가비지 컬렉션이 동시에 허용됨을 나타냄
- `__atomic` - 외부 프로시저가 Scheme으로 다시 호출하거나 C 라이브러리 루틴을 호출하지 않음을 나타냄
- `__alloc` - `__atomic`을 수정하여 Scheme의 C 라이브러리 루틴을 통한 할당을 허용
- `__disable_interrupts` - 호출 중 Scheme 인터럽트를 비활성화
- `__errno` 또는 `__get_last_error`(Windows 전용) - 외부 프로시저 호출 시 오류 값을 추가 결과로 반환
- `__varargs` 또는 `(__varargs_after n)` - 프로시저가 가변 인자 수로 작동하는 규약을 사용함을 나타냄

`__com` 인터페이스의 경우에만 `entry-exp`가 COM vtable에서 메서드의 바이트 오프셋으로 평가되어야 합니다. 예를 들어:

```scheme
(foreign-procedure __com 12 (iptr double-float) integer-32)
```

이는 첫 번째 인자로 전달된 COM 인스턴스 내에 캡슐화된 vtable의 오프셋 12에 있는 COM 메서드에 대한 인터페이스를 생성하며, 두 번째 인자는 double float이고 반환값은 정수입니다.

`__collect_safe` 선언은 외부 프로시저와 동시에 가비지 컬렉션이 허용됨을 선언합니다. 이는 외부 프로시저가 호출될 때 현재 스레드를 비활성화하고(`fork-thread` 참조), 외부 프로시저가 반환될 때 스레드를 다시 활성화하여 동시 컬렉션을 허용합니다. 예를 들어, 차단 I/O 호출을 호출할 때 다른 Scheme 스레드가 정상적으로 실행되도록 허용하는 데 유용합니다. `__collect_safe` 외부 프로시저에 수집 가능한 메모리를 전달하지 않거나, `lock-object`를 사용하여 메모리를 고정하세요. `__collect_safe` 선언은 스레드되지 않은 시스템 버전에서는 효과가 없습니다.

예를 들어, C `sleep` 함수를 기본 규약으로 호출하면 다른 Scheme 스레드가 가비지 컬렉션을 수행하는 것을 차단하지만, `__collect_safe` 선언을 추가하면 해당 문제를 피할 수 있습니다:

```scheme
(define c-sleep
  (foreign-procedure __collect_safe "sleep" (unsigned) unsigned))
(c-sleep 10) ; 10초 동안 다른 스레드를 차단하지 않고 sleep
```

`__atomic`을 사용하여 외부 프로시저가 외부 호출 가능을 통해 Scheme으로 다시 호출하지 않고, 4.10절에 설명된 Scheme의 C 라이브러리 루틴을 호출하지 않음을 선언합니다. `__atomic` 다음에 `__alloc`을 사용하면 외부 프로시저가 문자열이나 쌍 할당과 같은 단순 할당만 수행하는 Scheme C 라이브러리 루틴을 호출할 수 있습니다. `__atomic`은 외부 함수 호출의 더 효율적인 구현을 허용할 수 있습니다. `__atomic`과 `__collect_safe` 선언은 동시에 사용할 수 없습니다.

`__disable_interrupts`를 사용하여 외부 프로시저 호출 직전에 `(disable-interrupts)` 호출을 추가하고 직후에 `(enable-interrupts)` 호출을 추가합니다. `__disable_interrupts` 규약은 외부 호출 가능과 함께 사용하기 위한 것으로, `with-interrupts-disabled`를 사용하거나 `disable-interrupts`와 `enable-interrupts`를 호출하여 구현하기가 덜 용이합니다.

`__errno`를 사용하면 외부 프로시저 호출이 하나의 값 대신 두 개의 값을 반환합니다: 외부 프로시저의 직접 결과와 외부 프로시저 반환 직후(현재 스레드에 대해 해당 값이 변경되기 전)의 C 라이브러리 `errno` 값입니다. Windows에서는 `current-errno-source`를 참조하거나, `__errno` 대신 `__get_last_error`를 사용하여 `errno` 대신 `GetLastError`에서 결과를 얻을 수 있습니다.

외부 프로시저의 매개변수에 대해 완전한 타입 검사 및 변환이 수행됩니다.

**유효한 매개변수 타입:**

| 타입 | 설명 |
|------|------|
| `integer-8` | -2⁷부터 2⁸-1까지의 정확한 정수 유효 |
| `unsigned-8` | -2⁷부터 2⁸-1까지의 정확한 정수 유효 |
| `integer-16` | -2¹⁵부터 2¹⁶-1까지의 정확한 정수 유효 |
| `unsigned-16` | -2¹⁵부터 2¹⁶-1까지의 정확한 정수 유효 |
| `integer-32` | -2³¹부터 2³²-1까지의 정확한 정수 유효 |
| `unsigned-32` | -2³¹부터 2³²-1까지의 정확한 정수 유효 |
| `integer-64` | -2⁶³부터 2⁶⁴-1까지의 정확한 정수 유효 |
| `unsigned-64` | -2⁶³부터 2⁶⁴-1까지의 정확한 정수 유효 |
| `double-float` | Scheme flonum만 유효 |
| `single-float` | Scheme flonum만 유효 |
| `short` | C `short`의 크기에 따라 적절한 고정 크기 타입의 별칭 |
| `unsigned-short` | C `unsigned short`의 크기에 따라 적절한 고정 크기 타입의 별칭 |
| `int` | C `int`의 크기에 따라 적절한 고정 크기 타입의 별칭 |
| `unsigned` | C `unsigned`의 크기에 따라 적절한 고정 크기 타입의 별칭 |
| `long` | C `long`의 크기에 따라 적절한 고정 크기 타입의 별칭 |
| `unsigned-long` | C `unsigned long`의 크기에 따라 적절한 고정 크기 타입의 별칭 |
| `iptr` | C 포인터의 크기에 따라 적절한 고정 크기 타입의 별칭 |
| `uptr` | C 포인터의 크기에 따라 적절한 (unsigned) 고정 크기 타입의 별칭 |
| `void*` | `uptr`의 별칭 |
| `fixnum` | `iptr`과 동일하지만 fixnum 범위의 값만 유효 |
| `boolean` | `#f`는 0으로, 다른 모든 객체는 1로 변환되어 C `int`로 전달 |
| `char` | 0-255 범위의 유니코드 스칼라 값을 가진 Scheme 문자만 유효 |
| `wchar_t` | Scheme 문자만 유효 |
| `scheme-object` | 변환 없이 직접 전달 (주의 필요) |
| `u8*` | Scheme bytevector 또는 `#f`여야 함 |
| `utf-8` | Scheme 문자열 또는 `#f`여야 함, `string->utf8`로 변환 |
| `utf-16` | `utf-8`과 유사하지만 `string->utf16`으로 변환 |
| `string` | `utf-8`의 별칭 |
| `wstring` | `utf-16` 또는 `utf-32`의 별칭 |

**유효한 결과 타입:**

| 타입 | 설명 |
|------|------|
| `void` | 결과가 무시되고 불특정 Scheme 객체 반환 |
| `integer-8` | 부호 있는 8비트 정수로 해석되어 Scheme 정확한 정수로 변환 |
| `unsigned-8` | 부호 없는 8비트 정수로 해석 |
| `integer-16` | 부호 있는 16비트 정수로 해석 |
| `unsigned-16` | 부호 없는 16비트 정수로 해석 |
| `integer-32` | 부호 있는 32비트 정수로 해석 |
| `unsigned-32` | 부호 없는 32비트 정수로 해석 |
| `integer-64` | 부호 있는 64비트 정수로 해석 |
| `unsigned-64` | 부호 없는 64비트 정수로 해석 |
| `double-float` | double float로 해석되어 Chez Scheme flonum으로 변환 |
| `single-float` | single float로 해석되어 Chez Scheme flonum으로 변환 |
| `boolean` | C `int` 반환값을 Scheme boolean으로 변환 (0→#f, 기타→#t) |
| `char` | C `unsigned char` 반환값을 Scheme 문자로 변환 |
| `scheme-object` | 유효한 Scheme 객체로 가정, 변환 없음 (위험) |
| `u8*` | 널 종료된 8비트 부호 없는 정수 시퀀스의 포인터로 해석 |
| `utf-8` | 널 종료된 8비트 부호 없는 문자값 시퀀스의 포인터로 해석 |
| `string` | `utf-8`의 별칭 |

**예제:**

```scheme
;; C identity 프로시저: int id(x) int x; { return x; }
(foreign-procedure "id" (int) int) => #<procedure>

((foreign-procedure "id" (int) int) 1) => 1

(define int-id (foreign-procedure "id" (int) int))
(int-id 1) => 1

;; boolean으로 해석
(define bool-id (foreign-procedure "id" (boolean) boolean))
(bool-id #f) => #f
(bool-id #t) => #t
(bool-id 1) => #t
```

외부 진입점은 `foreign-procedure` 표현식이 평가될 때 해결되며, 코드가 로드될 때나 프로시저가 호출될 때마다가 아닙니다.

---

## 4.3 Scheme으로의 호출

4.2절은 Scheme 코드가 C 또는 C-호환 외부 프로시저를 호출할 수 있도록 하는 `foreign-procedure` 형식을 설명합니다. 이 절은 C 또는 C-호환 코드가 Scheme 프로시저를 호출할 수 있도록 하는 `foreign-callable` 형식을 설명합니다. Scheme 프로시저를 C에서 호출하는 더 원시적인 메커니즘은 4.10절에 설명되어 있습니다.

Scheme에서 외부 프로시저를 호출할 때와 마찬가지로, Scheme의 메모리 관리 시스템을 손상시키지 않도록 Scheme과 Scheme을 호출하는 외부 코드 간의 데이터 공유에 각별히 주의해야 합니다.

Scheme 프로시저에 대한 외부-호출-가능 래퍼는 적절한 함수 ftype(4.5절)과 함께 `make-ftype-pointer`에 프로시저를 전달하여 생성할 수도 있습니다.

---

### 문법: `(foreign-callable conv ... proc-exp (param-type ...) res-type)`

**반환값:** 코드 객체  
**라이브러리:** `(chezscheme)`

`proc-exp`은 외부 코드에 의해 호출될 Scheme 프로시저로 평가되어야 합니다. 매개변수 및 결과 타입은 4.2절의 `foreign-procedure`에 대해 설명된 대로이며, 요구사항과 변환이 효과적으로 반전됩니다(예: `foreign-procedure` 인자에 대해 설명된 변환이 `foreign-callable` 반환값에 대해 수행됨).

각 `conv`는 사용할 호출 규약을 조정합니다. `foreign-callable`은 `__com`, `__atomic`, `__alloc`, `__errno`, `__get_last_error`를 제외한 `foreign-procedure`와 동일한 규약을 지원합니다(무시됨).

`foreign-callable`이 생성하는 값은 Scheme 코드 객체로, 캡슐화된 Scheme 프로시저를 호출하는 코드와 함께 일부 헤더 정보를 포함합니다. 코드 객체는 `foreign-callable-entry-point`를 통해 외부-호출-가능 주소로 변환될 수 있으며, 이는 코드 객체 내 진입점의 주소를 나타내는 정수를 반환합니다.

**예제:**

```scheme
(let ([x (foreign-callable
          (lambda (x y) (pretty-print (cons x (* y 2))))
          (string integer-32)
          void)])
  (lock-object x)
  (foreign-callable-entry-point x))
```

다음 예제는 `foreign-callable`을 사용하여 콜백 함수를 정의하는 방법을 보여줍니다:

```scheme
;; C 코드 (콜백 등록 및 이벤트 루프)
;; typedef void (*CB)(char);
;; CB callbacks[256];
;; void cb_init(void) { ... }
;; void register_callback(char c, CB cb) { ... }
;; void event_loop(void) { ... }

(define cb-init
  (foreign-procedure "cb_init" () void))
(define register-callback
  (foreign-procedure "register_callback" (char void*) void))
(define event-loop
  (foreign-procedure __collect_safe "event_loop" () void))

(define callback
  (lambda (p)
    (let ([code (foreign-callable __collect_safe p (char) void)])
      (lock-object code)
      (foreign-callable-entry-point code))))

(define ouch
  (callback
    (lambda (c)
      (printf "Ouch! Hit by '~c'~%" c))))

(cb-init)
(register-callback #\a ouch)
```

---

### 프로시저: `(foreign-callable-entry-point code)`

**반환값:** `code` 내 외부-호출-가능 진입점의 주소  
**라이브러리:** `(chezscheme)`

`code`는 `foreign-callable`에 의해 생성된 코드 객체여야 합니다.

---

### 프로시저: `(foreign-callable-code-object address)`

**반환값:** 외부-호출-가능 진입점 `address`에 해당하는 코드 객체  
**라이브러리:** `(chezscheme)`

`address`는 정확한 정수여야 하며 `foreign-callable`에 의해 생성된 코드 객체의 진입점 주소여야 합니다.

---

## 4.4 연속성과 외부 호출

`foreign-callable`과 `foreign-procedure`는 외부 호출과 Scheme 호출의 임의의 중첩을 허용합니다. 다른 언어들은 Scheme의 완전히 일반적인 일급 연속성을 지원하지 않기 때문에, 연속성과 Scheme 및 외부 프로시저 간의 중첩 호출 간의 상호작용은 문제가 있습니다. Chez Scheme은 연속성의 사용을 직접 제한하는 대신 *오래된(stale)* 외부 컨텍스트로의 복귀 시도를 트래핑하여 이 상호작용을 일반적인 방식으로 처리합니다.

외부 컨텍스트는 외부 언어(예: C)에서 Scheme으로의 특정 호출에 해당하는 외부 프레임과 복귀 지점입니다. 외부 컨텍스트는 컨텍스트로의 정상 복귀 또는 제어 스택 아래의 다른 외부 컨텍스트로의 복귀 후에 오래됩니다.

이 처리의 결과로, Scheme 연속성은 제어를 Scheme 및 외부 프레임의 혼합을 통해 논리적으로 위나 아래로 던지는 데 사용될 수 있습니다. 또한, 실제로 외부 컨텍스트로의 복귀가 수행되기 전까지는 모든 복귀 지점이 유효합니다. 특히, 이는 비지역 탈출을 위해 연속성을 독점적으로 사용하는 프로그램은 오래된 외부 컨텍스트로 복귀를 시도하지 않음을 의미합니다. (비지역 탈출 자체는 문제가 없으며 C 라이브러리 함수 `longjmp` 또는 이에 상응하는 것으로 구현됩니다.)

한 가지 함의는 C 스택 포인터가 연속성이 Scheme 측에서 비지역 탈출을 수행하는 데 사용될 때 자동으로 기본값으로 복원되지 않는다는 것입니다. 프로그램이 비지역 탈출 후 계속 실행되면, C 스택의 추가적인 증가는 기존 증가에 더해져 C 스택 오버플로우를 초래할 수 있습니다.

---

## 4.5 외부 데이터

이 절에 설명된 프로시저는 외부 데이터, 즉 Scheme 힙 외부에 존재하는 데이터를 직접 생성하고 조작합니다. `foreign-alloc`, `foreign-sizeof`, `foreign-alignof`를 제외하고, 이 프로시저들은 본질적으로 안전하지 않습니다(전달받은 주소의 유효성을 확인하지 않거나 확인할 수 없음). 이 프로시저들을 부적절하게 사용하면 잘못된 메모리 참조, 데이터 손상 또는 시스템 충돌이 발생할 수 있습니다.

이 절은 또한 외부 구조체, 공용체, 배열, 비트 필드를 포함한 외부 데이터를 조작하기 위한 고급 구문 메커니즘을 설명합니다. 구문 인터페이스는 절차적 인터페이스보다 안전하지만, 주어진 주소가 조작되는 객체의 타입에 적합하다고 가정해야 합니다.

---

### 프로시저: `(foreign-alloc n)`

**반환값:** `n` 바이트 길이의 새로 할당된 외부 데이터 블록의 주소  
**라이브러리:** `(chezscheme)`

`n`은 양의 fixnum이어야 합니다. 반환값은 정확한 정수이며 기본 하드웨어의 요구사항에 따라 모든 타입의 값에 대해 적절히 정렬됨이 보장됩니다. 외부 데이터 블록을 할당할 수 없는 경우 `&assertion` 조건 타입으로 예외가 발생합니다.

---

### 프로시저: `(foreign-free address)`

**반환값:** 불특정  
**라이브러리:** `(chezscheme)`

이 프로시저는 `address`가 가리키는 저장소 블록을 해제합니다. `address`는 -2^(w-1)부터 2^w - 1 범위의 정확한 정수여야 하며, 여기서 w는 포인터의 비트 너비입니다(예: 64비트 머신의 경우 64). 이는 이전에 `foreign-alloc` 호출로 반환된 주소여야 하며, 이후에 `foreign-free`에 전달되지 않은 것이어야 합니다.

---

### 프로시저: `(foreign-ref type address offset)`

**반환값:** 아래 설명 참조  
**라이브러리:** `(chezscheme)`

`foreign-ref`는 `address`에서 `offset` 바이트 오프셋된 메모리 위치에서 `type` 타입의 값을 추출합니다.

`type`은 추출할 값의 타입을 식별하는 심볼이어야 합니다. 다음 타입들은 머신 의존적 크기를 가지며 동일한 이름의 C 타입에 해당합니다:
- `short`, `unsigned-short`, `int`, `unsigned`, `unsigned-int`, `long`, `unsigned-long`, `long-long`, `unsigned-long-long`, `ptrdiff_t`, `size_t`, `ssize_t`, `char`, `wchar_t`, `float`, `double`, `void*`

---

### 프로시저: `(foreign-set! type address offset value)`

**반환값:** 불특정  
**라이브러리:** `(chezscheme)`

`foreign-set!`는 `value`의 표현을 `type` 타입으로 `address`가 가리키는 외부 데이터 블록에서 `offset` 바이트 오프셋된 위치에 저장합니다.

---

### 프로시저: `(foreign-sizeof type)`

**반환값:** `type`의 바이트 크기  
**라이브러리:** `(chezscheme)`

`type`은 `foreign-ref` 설명에 나열된 심볼 중 하나여야 합니다.

---

### 프로시저: `(foreign-alignof type)`

**반환값:** `type`의 바이트 정렬  
**라이브러리:** `(chezscheme)`

`type`은 `foreign-ref` 설명에 나열된 심볼 중 하나여야 합니다.

---

### 문법: `(define-ftype ftype-name ftype)`  
### 문법: `(define-ftype ftype-name ftype (nongenerative uid))`  
### 문법: `(define-ftype (ftype-name ftype maybe-uid-clause) ...)`

**반환값:** 불특정  
**라이브러리:** `(chezscheme)`

`define-ftype` 형식은 정의이며 다른 정의가 나타날 수 있는 곳에 나타날 수 있습니다. 식별자 `ftype-name` 또는 식별자들 `ftype-name ...`에 대한 하나 이상의 외부-타입(ftype) 바인딩을 `ftype` 또는 `ftype ...`이 나타내는 외부 타입으로 설정합니다.

`ftype`는 다음 형태 중 하나여야 합니다:

```
ftype-name
(struct (field-name ftype) ...)
(union (field-name ftype) ...)
(array length ftype)
(* ftype)
(bits (field-name signedness bits) ...)
(function conv ... (ftype ...) ftype)
(packed ftype)
(unpacked ftype)
(endian endianness ftype)
```

**예제:**

```scheme
(define-ftype F (function (wchar_t int) int))
(define-ftype A (array 10 wchar_t))
(define-ftype E
  (struct
    [a int]
    [b double]
    [c (array 25
         (struct
           [a short]
           [_ long]
           [b A]))]
    [d (endian big
         (union
           [v1 unsigned-32]
           [v2 (bits
                 [hi unsigned 12]
                 [lo unsigned 20])]))]
    [e (* A)]
    [f (* F)]))
```

밑줄(`_`)은 `struct`, `union`, 또는 `bits` ftype의 하나 이상의 필드에 대한 필드 이름으로 사용할 수 있습니다. 이러한 필드는 레이아웃에 포함되지만 이름이 없는 것으로 간주되어 아래 설명된 ftype 연산자를 통해 접근할 수 없습니다.

---

### 문법: `(ftype-sizeof ftype-name)`

**반환값:** `ftype-name`으로 식별된 ftype의 바이트 크기  
**라이브러리:** `(chezscheme)`

크기는 식별된 ftype 내에 직접 포함된 ftype의 크기를 포함하지만 포인터 ftype을 통해 간접적으로 포함된 것은 제외합니다. 후자의 경우 포인터의 크기가 포함됩니다.

---

### 문법: `(make-ftype-pointer ftype-name expr)`

**반환값:** ftype-포인터 객체  
**라이브러리:** `(chezscheme)`

`ftype-name`이 함수 ftype을 설명하지 않는 경우, `expr`은 대상 머신에 적합한 범위의 정확한 정수로 표현된 `address`로 평가되어야 합니다.

`expr`이 프로시저로 평가되는 경우, `foreign-callable`(4.3절)을 통해 프로시저에 대한 외부-호출-가능 코드 객체가 생성됩니다. 결과 ftype-포인터 객체에 캡슐화된 주소는 프로시저의 진입점 주소입니다.

---

### 문법: `(make-ftype-scheme-object-pointer expr)`  
### 문법: `(make-ftype-scheme-object-pointer expr offset)`  
### 문법: `(make-ftype-scheme-object-pointer expr offset ftype-name)`

**반환값:** Scheme 객체를 참조하는 ftype-포인터 객체  
**라이브러리:** `(chezscheme)`

`object->reference-address`의 의미에서 참조 주소인 포인터에 의해 캡슐화된 주소와 함께 일반 ftype 포인터와 동일한 위치에서 사용할 수 있는 ftype 포인터 객체를 반환합니다. 참조 주소는 `#f`에 대한 특별한 처리 없이 `expr`의 결과에 대한 것입니다.

---

### 문법: `(ftype-pointer? obj)`  
### 문법: `(ftype-pointer? ftype-name obj)`

**반환값:** `obj`가 ftype 포인터이면 `#t`, 아니면 `#f`  
**라이브러리:** `(chezscheme)`

---

### 프로시저: `(ftype-pointer-address fptr)`

**반환값:** `fptr` 내에 캡슐화된 주소  
**라이브러리:** `(chezscheme)`

`fptr`은 ftype-포인터 객체여야 합니다.

---

### 문법: `(ftype-pointer=? fptr1 fptr2)`

**반환값:** `fptr1`과 `fptr2`가 동일한 주소를 가지면 `#t`, 아니면 `#f`  
**라이브러리:** `(chezscheme)`

---

### 문법: `(ftype-pointer-null? fptr)`

**반환값:** `fptr`의 주소가 0이면 `#t`, 아니면 `#f`  
**라이브러리:** `(chezscheme)`

---

### 문법: `(ftype-&ref ftype-name (a ...) fptr-expr)`  
### 문법: `(ftype-&ref ftype-name (a ...) fptr-expr index)`

**반환값:** ftype-포인터 객체  
**라이브러리:** `(chezscheme)`

`ftype-&ref`가 반환하는 ftype-포인터 객체는 `fptr-expr`의 값이 가리키는 외부 객체 내에 직접 또는 간접적으로 포함된 일부 객체의 주소를 캡슐화하며, `index`가 있는 경우 그만큼 오프셋됩니다.

---

### 문법: `(ftype-set! ftype-name (a ...) fptr-expr val-expr)`  
### 문법: `(ftype-set! ftype-name (a ...) fptr-expr index val-expr)`  
### 문법: `(ftype-ref ftype-name (a ...) fptr-expr)`  
### 문법: `(ftype-ref ftype-name (a ...) fptr-expr index)`

**반환값:** 불특정 (set!), Scheme 표현 (ref)  
**라이브러리:** `(chezscheme)`

이 형식들은 `fptr-expr`의 값이 가리키는 객체에 값을 저장하거나 검색하는 데 사용됩니다.

---

## 4.6 관리 객체의 외부 배열

바이트벡터 값이 `u8*` 타입의 인자로 외부 호출에 전달될 때, 외부 프로시저는 바이트벡터 내용의 시작 부분에 대한 포인터를 받습니다. `object->reference-address` 함수는 동일한 주소를 반환하지만, 바이트벡터가 이동하지 않는 경우에만 유효합니다. 저장소 관리자가 나중에 바이트벡터를 메모리에서 이동시키면 주소가 무효화됩니다.

*참조 바이트벡터*는 `bytevector-reference-set!`을 사용하여 Scheme 객체의 *내용* 주소를 저장함으로써 이 문제를 해결할 수 있는 바이트벡터 유형입니다. 참조 바이트벡터는 저장소 관리자에 의해 특별히 처리되어, 포함된 주소가 Scheme 객체에 대한 참조로 인식되고 저장소 관리자가 해당 객체를 이동시키면 적절히 업데이트됩니다.

---

### 프로시저: `(make-reference-bytevector n)`

**반환값:** 길이 `n`의 참조 바이트벡터  
**라이브러리:** `(chezscheme)`

`make-bytevector`와 유사하지만 결과는 참조 바이트벡터이며 모든 바이트가 `0`으로 초기화됩니다(즉, 모든 참조 객체가 `#f`).

---

### 프로시저: `(reference-bytevector? obj)`

**반환값:** `obj`가 참조 바이트벡터이면 `#t`, 아니면 `#f`  
**라이브러리:** `(chezscheme)`

모든 참조 바이트벡터는 `bytevector?`로 인식되는 바이트벡터이기도 합니다.

---

### 프로시저: `(bytevector-reference-set! bytevector n obj)`

**반환값:** 불특정  
**라이브러리:** `(chezscheme)`

`bytevector`는 참조 바이트벡터여야 하며, `n`은 음이 아닌 fixnum이어야 합니다. `bytevector` 내 바이트 오프셋 `n`에 `obj`에 대한 참조를 설치합니다.

---

### 프로시저: `(bytevector-reference-ref bytevector n)`

**반환값:** Scheme 객체  
**라이브러리:** `(chezscheme)`

`bytevector` 내 바이트 오프셋 `n`에서 참조되는 객체를 반환합니다.

---

### 프로시저: `(object->reference-address obj)`

**반환값:** 음이 아닌 정확한 정수  
**라이브러리:** `(chezscheme)`

`obj`가 `#f`이면 결과는 `0`이며, `obj`가 바이트벡터 또는 fl벡터인 경우 해당 내용의 주소입니다.

---

## 4.7 외부 프로시저 접근 제공

외부 프로시저에 대한 접근은 여러 가지 방법으로 제공될 수 있습니다:

1. `load-shared-object`를 사용하여 "공유 객체"에서 외부 프로시저 로드
2. 추가 외부 코드가 링크된 새 Chez Scheme 이미지 빌드
3. 외부 코드에 의해 동적으로 로드되거나 획득된 추가 진입점
4. 함수 포인터가 Scheme으로 전달되어 foreign-procedure 표현식의 진입점 값으로 사용

---

### 프로시저: `(foreign-entry? entry-name)`

**반환값:** `entry-name`이 기존 외부 프로시저 진입점이면 `#t`, 아니면 `#f`  
**라이브러리:** `(chezscheme)`

---

### 프로시저: `(foreign-entry entry-name)`

**반환값:** `entry-name`의 주소를 정확한 정수로 반환  
**라이브러리:** `(chezscheme)`

---

### 프로시저: `(load-shared-object path)`

**반환값:** 불특정  
**라이브러리:** `(chezscheme)`

`path`가 문자열이면, `path`로 명명된 공유 객체를 로드합니다. 공유 객체는 시스템 라이브러리이거나 일반 C 프로그램에서 생성된 파일일 수 있습니다. 공유 객체의 모든 외부 심볼과 공유 객체와 함께 링크된 다른 공유 객체에서 사용 가능한 외부 심볼이 외부 진입점으로 제공됩니다.

---

### 프로시저: `(remove-foreign-entry entry-name)`

**반환값:** 불특정  
**라이브러리:** `(chezscheme)`

`entry-name` 문자열로 지정된 진입점에 대한 추가 접근을 차단합니다.

---

## 4.8 다른 외부 언어 사용

Chez Scheme 외부 프로시저 인터페이스는 주로 C 또는 C 라이브러리에 정의된 프로시저를 대상으로 하지만, C 호출 규약을 따르는 다른 언어로 정의된 프로시저를 호출하는 것도 가능합니다. 한 가지 어려움은 이름의 해석일 수 있습니다. Unix 기반 C 컴파일러는 종종 외부 이름 앞에 밑줄을 붙이므로, 외부 인터페이스는 호스트 C 컴파일러와 일관된 방식으로 진입점 이름을 해석하려고 시도합니다. 어셈블리 코딩된 파일과 같이 이 진입점 이름 해석이 바람직하지 않을 수 있습니다. 진입점 이름 앞에 "=" 문자를 붙여 방지할 수 있습니다.

---

## 4.9 외부 오류 결과

### 스레드 매개변수: `current-errno-source`

**라이브러리:** `(chezscheme)`

`current-errno-source`는 모든 호스트 운영 체제에서 `#f`일 수 있습니다. Windows에서는 `msvcrt`와 `ucrt` 심볼도 허용됩니다.

글로벌 C 변수 `errno`는 Windows에서 다른 방식으로 링크될 수 있으며, Chez Scheme 실행 파일의 `errno` 링크가 동적으로 로드된 라이브러리의 링크와 다를 수 있습니다. 규약 `__errno`가 있는 외부 프로시저가 호출될 때, `current-errno-source`의 값이 사용되는 `errno`를 결정합니다:

- `#f`: Chez Scheme 실행 파일에 링크된 `errno` 사용
- `msvcrt`: `"msvcrt.dll"`에서 동적으로 `errno` 접근
- `ucrt`: `"ucrtbase.dll"`에서 동적으로 `errno` 접근

---

## 4.10 C 라이브러리 루틴

추가 외부 인터페이스 지원은 C 전처리기 매크로와 C-호출 가능 라이브러리 함수 세트를 통해 제공됩니다. 이러한 루틴 중 일부는 C 프로그램이 Scheme 객체를 검사, 할당 및 변경할 수 있게 합니다. 다른 것들은 C 함수가 4.3절에 정의된 것보다 더 원시적인 인터페이스를 통해 Scheme 프로시저를 호출할 수 있게 합니다. 또 다른 것들은 사용자 정의 실행 가능 이미지 개발과 다른 프로그램 내에서 하위 프로그램으로 Scheme 시스템 사용(예: 확장 언어로 사용)을 허용합니다.

이 루틴을 사용하는 C 코드는 Chez Scheme과 함께 배포된 `"scheme.h"` 헤더 파일을 포함해야 하며 Chez Scheme 커널과 링크되어야 합니다.

---

### 사용자 정의 함수

| 함수 | 설명 |
|------|------|
| `Skernel_version()` | Scheme 버전을 나타내는 문자열 반환 |
| `Sscheme_init(abnormal_exit)` | 정적 메모리 초기화 |
| `Sset_verbose(v)` | v가 0이 아니면 상세 모드 켬 |
| `Sregister_boot_file(name)` | 부트 파일 검색 및 등록 |
| `Sbuild_heap(exec, custom_init)` | 등록된 부트 파일에서 Scheme 힙 생성 |
| `Sscheme_start(argc, argv)` | 대화형 시작 프로시저 호출 |
| `Sscheme_deinit()` | 파일 닫고 Scheme 힙 정리 및 시스템 초기화 해제 |

---

### 술어 (Predicates)

| 매크로 | 설명 |
|--------|------|
| `Sfixnump(obj)` | fixnum인지 확인 |
| `Scharp(obj)` | 문자인지 확인 |
| `Snullp(obj)` | 빈 리스트인지 확인 |
| `Sbooleanp(obj)` | boolean인지 확인 |
| `Spairp(obj)` | 쌍인지 확인 |
| `Ssymbolp(obj)` | 심볼인지 확인 |
| `Sprocedurep(obj)` | 프로시저인지 확인 |
| `Sflonump(obj)` | flonum인지 확인 |
| `Svectorp(obj)` | 벡터인지 확인 |
| `Sbytevectorp(obj)` | 바이트벡터인지 확인 |
| `Sstringp(obj)` | 문자열인지 확인 |

---

### 접근자 (Accessors)

| 매크로/함수 | 설명 |
|------------|------|
| `Sfixnum_value(fixnum)` | fixnum의 C 정수값 반환 |
| `Schar_value(character)` | 문자의 유니코드 스칼라값 반환 |
| `Sboolean_value(obj)` | boolean의 C 정수값 반환 |
| `Sflonum_value(flonum)` | flonum의 double값 반환 |
| `Sinteger_value(integer)` | 정수의 C 정수값 반환 |
| `Scar(pair)` | 쌍의 car 반환 |
| `Scdr(pair)` | 쌍의 cdr 반환 |
| `Sstring_length(str)` | 문자열 길이 반환 |
| `Svector_length(vec)` | 벡터 길이 반환 |
| `Sbytevector_length(bytevec)` | 바이트벡터 길이 반환 |

---

### 생성자 (Constructors)

| 매크로/함수 | 설명 |
|------------|------|
| `Snil` | 빈 리스트 반환 |
| `Strue` | `#t` 반환 |
| `Sfalse` | `#f` 반환 |
| `Svoid` | void 객체 반환 |
| `Sfixnum(n)` | C 정수에서 fixnum 생성 |
| `Schar(c)` | C 문자에서 Scheme 문자 생성 |
| `Sboolean(b)` | C 정수에서 boolean 생성 |
| `Sflonum(x)` | double에서 flonum 생성 |
| `Sstring(s)` | C 문자열에서 Scheme 문자열 생성 |
| `Scons(obj1, obj2)` | 쌍 생성 |
| `Sstring_to_symbol(s)` | C 문자열에서 심볼 생성 |

---

### 객체 잠금 (Locking)

| 함수 | 설명 |
|------|------|
| `Slock_object(obj)` | 객체가 이동하거나 회수되지 않도록 잠금 |
| `Sunlock_object(obj)` | 객체 잠금 해제 |
| `Slocked_objectp(obj)` | 객체가 잠겨 있는지 확인 |

---

### 외부 진입점 등록

| 함수 | 설명 |
|------|------|
| `Sforeign_symbol(name, addr)` | 외부 심볼 등록 (이미 존재하면 예외) |
| `Sregister_symbol(name, addr)` | 외부 심볼 등록 (재정의 허용) |

---

### Scheme으로의 호출

| 함수 | 설명 |
|------|------|
| `Scall0(procedure)` | 인자 없는 Scheme 프로시저 호출 |
| `Scall1(procedure, obj1)` | 1개 인자로 Scheme 프로시저 호출 |
| `Scall2(procedure, obj1, obj2)` | 2개 인자로 Scheme 프로시저 호출 |
| `Scall3(procedure, obj1, obj2, obj3)` | 3개 인자로 Scheme 프로시저 호출 |
| `Scall(procedure, n)` | n개 인자로 Scheme 프로시저 호출 |

---

### 스레드 활성화

| 함수 | 설명 |
|------|------|
| `Sactivate_thread()` | 스레드 활성화 |
| `Sdeactivate_thread()` | 스레드 비활성화 |
| `Sdestroy_thread()` | 스레드 파괴 알림 |

---

## 4.11 예제: 소켓 연산

이 절은 Scheme과 C 코드의 조합을 사용하는 간단한 소켓 인터페이스를 제시합니다. C 코드는 저수준 운영 체제 인터페이스 세트를 정의하고, Scheme 코드는 이를 사용하여 소켓을 열고, 닫고, 읽고, 쓸 수 있습니다.

### C 코드 (csocket.c)

```c
/* csocket.c */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <unistd.h>

/* c_write - 전체 버퍼를 쓰려고 시도 */
int c_write(int fd, char *buf, ssize_t start, ssize_t n) {
    ssize_t i, m;
    buf += start;
    m = n;
    while (m > 0) {
        if ((i = write(fd, buf, m)) < 0) {
            if (errno != EAGAIN && errno != EINTR)
                return i;
        } else {
            m -= i;
            buf += i;
        }
    }
    return n;
}

/* c_read - 인터럽트와 소켓 지연 처리 */
int c_read(int fd, char *buf, size_t start, size_t n) {
    int i;
    buf += start;
    for (;;) {
        i = read(fd, buf, n);
        if (i >= 0) return i;
        if (errno != EAGAIN && errno != EINTR) return -1;
    }
}

/* bytes_ready - 읽을 수 있는 바이트가 있는지 확인 */
int bytes_ready(int fd) {
    int n;
    (void) ioctl(fd, FIONREAD, &n);
    return n;
}

/* 소켓 지원 함수들 */
int do_socket(void) {
    return socket(AF_UNIX, SOCK_STREAM, 0);
}

int do_bind(int s, char *name) {
    struct sockaddr_un sun;
    int length;
    sun.sun_family = AF_UNIX;
    (void) strcpy(sun.sun_path, name);
    length = sizeof(sun.sun_family) + sizeof(sun.sun_path);
    return bind(s, (struct sockaddr*)(&sun), length);
}

int do_accept(int s) {
    struct sockaddr_un sun;
    socklen_t length;
    length = sizeof(sun.sun_family) + sizeof(sun.sun_path);
    return accept(s, (struct sockaddr*)(&sun), &length);
}

int do_connect(int s, char *name) {
    struct sockaddr_un sun;
    int length;
    sun.sun_family = AF_UNIX;
    (void) strcpy(sun.sun_path, name);
    length = sizeof(sun.sun_family) + sizeof(sun.sun_path);
    return connect(s, (struct sockaddr*)(&sun), length);
}

char* get_error(void) {
    extern int errno;
    return strerror(errno);
}
```

### Scheme 코드 (socket.ss)

```scheme
;;; socket.ss

;;; csocket.so 필요 (csocket.c에서 빌드)
(load-shared-object "./csocket.so")

;;; C 라이브러리에서 필요: close, dup, execl, fork, kill, listen, tmpnam, unlink
(case (machine-type)
  [(i3le ti3le a6le ta6le) (load-shared-object "libc.so.6")]
  [(i3osx ti3osx a6osx ta6osx) (load-shared-object "libc.dylib")]
  [else (load-shared-object "libc.so")])

;;; 기본 C 라이브러리 함수들
(define close
  (foreign-procedure "close" (int) int))

(define dup
  (foreign-procedure "dup" (int) int))

(define fork
  (foreign-procedure "fork" () int))

(define listen
  (foreign-procedure "listen" (int int) int))

(define tmpnam
  (foreign-procedure "tmpnam" (void*) string))

(define unlink
  (foreign-procedure "unlink" (string) int))

;;; csocket.c에 정의된 루틴들
(define accept
  (foreign-procedure "do_accept" (int) int))

(define bytes-ready?
  (foreign-procedure "bytes_ready" (int) boolean))

(define bind
  (foreign-procedure "do_bind" (int string) int))

(define c-error
  (foreign-procedure "get_error" () string))

(define c-read
  (foreign-procedure "c_read" (int u8* size_t size_t) ssize_t))

(define c-write
  (foreign-procedure "c_write" (int u8* size_t ssize_t) ssize_t))

(define connect
  (foreign-procedure "do_connect" (int string) int))

(define socket
  (foreign-procedure "do_socket" () int))

;;; 고수준 루틴들
(define setup-server-socket
  (lambda (name)
    (let ([sock (check 'socket (socket))])
      (unlink name)
      (check 'bind (bind sock name))
      (check 'listen (listen sock 1))
      sock)))

(define setup-client-socket
  (lambda (name)
    (let ([sock (check 'socket (socket))])
      (check 'connect (connect sock name))
      sock)))

(define check
  (lambda (who x)
    (if (< x 0)
        (error who (c-error))
        x)))
```

---

### 샘플 세션

```
> (define client-pid)
> (define client-socket)
> (let* ([server-socket-name (tmpnam 0)]
         [server-socket (setup-server-socket server-socket-name)])
    (dofork
      (lambda ()
        (check 'close (close server-socket))
        (let ([sock (setup-client-socket server-socket-name)])
          (dodup 0 sock)
          (dodup 1 sock))
        (check 'execl (execl4 "/bin/sh" "/bin/sh" "-c" "exec scheme -q"))
        (errorf 'client "returned!"))
      (lambda (pid)
        (set! client-pid pid)
        (set! client-socket (accept-socket server-socket))
        (check 'close (close server-socket)))))

> (define put
    (lambda (x)
      (let ([s (format "~s~%" x)])
        (c-write client-socket s (string-length s)))
      (void)))

> (put '(let ([x 3]) x))
> (get)
client:
3
server:

> (terminate-process client-pid)
> (exit)
```

---

*Chez Scheme Version 10 User's Guide*  
Copyright © 2026 Cisco Systems, Inc.  
Apache License Version 2.0  
Revised May 2026 for Chez Scheme Version 10.4.0
