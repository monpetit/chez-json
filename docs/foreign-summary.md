요청하신 웹페이지 내용을 정리한 마크다운 문서입니다.

---

# Chapter 4. Foreign Interface

Chez Scheme은 외부 언어(예: C 언어)로 작성된 코드와 상호작용하는 두 가지 방법을 제공합니다.

1. **서브프로세스 생성 및 통신** (Section 4.1)
2. **C 프로시저의 정적/동적 로딩 및 호출, C에서 Scheme 프로시저 호출** (Section 4.2 ~ 4.4)

---

## Section 4.1. Subprocess Communication

서브프로세스를 생성하기 위해 `system`과 `process` 두 가지 프로시저를 사용합니다. 두 프로시저 모두 실행할 셸 명령어를 담은 문자열을 인자로 받습니다.

* `system`: 프로세스가 종료될 때까지 대기합니다.
* `process` / `open-process-ports`: 프로세스를 생성한 후 종료를 기다리지 않고 즉시 반환합니다.

### 1. `system`

* **형식**: `(system command)`
* **반환값**: 프로세스의 종료 코드 (Unix 계열에서 시그널로 종료된 경우 시그널 번호의 음수 값 반환, 예: `SIGHUP`은 `-1`)
* **설명**: `command`에 지정된 작업을 수행하는 서브프로세스를 생성합니다. Chez Scheme 프로세스와 동일한 콘솔 입출력 파일을 사용하여 사용자와 통신할 수 있습니다.

### 2. `open-process-ports`

* **형식**:
* `(open-process-ports command)`
* `(open-process-ports command b-mode)`
* `(open-process-ports command b-mode ?transcoder)`


* **반환값**: 다음 4개의 값을 반환합니다.
1. `to-stdin`: 서브프로세스의 `stdin`으로 데이터를 보낼 출력 포트
2. `from-stdout`: 서브프로세스의 `stdout`에서 데이터를 읽을 입력 포트
3. `from-stderr`: 서브프로세스의 `stderr`에서 데이터를 읽을 입력 포트
4. `process-id`: 생성된 서브프로세스의 PID (정수)


* **설명**: 지정된 명령어를 수행하는 서브프로세스를 생성하고 즉시 반환합니다. `?transcoder`가 전달되면 텍스트 포트를, 그렇지 않으면 바이너리 포트를 생성합니다.

### 3. `process`

* **형식**: `(process command)`
* **반환값**: `(list from-stdout to-stdin process-id)`
* **설명**: `open-process-ports`보다 단순화된 버전입니다. `stderr` 포트를 반환하지 않으며, 항상 텍스트 포트를 생성합니다.

---

## Section 4.2. Calling out of Scheme

Chez Scheme의 `foreign-procedure` 인터페이스를 사용하면 C 언어 또는 C 호출 규약을 따르는 언어로 작성된 프로시저를 호출할 수 있습니다.

### 구문 (Syntax)

```scheme
(foreign-procedure conv ... entry-exp (param-type ...) res-type)

```

* **entry-exp**: 유효한 C 프로시저 진입점(문자열) 또는 함수 주소를 나타내는 정수.
* **param-type ... / res-type**: 인자 및 반환값의 데이터 타입.
* **conv**: 호출 규약 및 옵션 플래그.

### 호출 규약 및 주요 플래그 (`conv`)

* `__stdcall` / `__cdecl` / `__com`: Windows API 및 COM 인터페이스 호출용 규약.
* `__collect_safe`: C 함수가 실행되는 동안 Concurrent Garbage Collection(가비지 컬렉션)이 발생할 수 있도록 허용합니다. Blocking I/O 호출 시 다른 Scheme 스레드가 멈추지 않도록 할 때 유용합니다.
* `__atomic`: C 함수가 Scheme으로 다시 콜백하지 않고 Scheme의 C 라이브러리 루틴을 호출하지 않음을 선언하여 호출 효율을 높입니다.
* `__disable_interrupts`: C 함수 호출 전후로 인터럽트를 비활성화/활성화합니다.
* `__errno`: 반환값과 함께 C 라이브러리의 `errno` 값을 추가로 반환받습니다.

### 주요 데이터 타입 (Parameter & Result Types)

* **정수형**: `integer-8`, `unsigned-8`, `integer-16`, `unsigned-16`, `integer-32`, `unsigned-32`, `integer-64`, `unsigned-64`
* **실수형**: `single-float`, `double-float`
* **C 타입 별칭**: `char`, `short`, `int`, `long`, `long-long`, `stddef.h` 타입 (`size_t`, `ssize_t`, `ptrdiff_t`), 포인터 크기 정수 (`iptr`, `uptr`, `void*`)
* **기타**: `boolean`, `stdbool`, `char`, `wchar_t`
* **포인터 및 바이트버퍼**:
* `u8*`, `u16*`, `u32*`: Scheme bytevector의 데이터 포인터를 전달.
* `utf-8`, `utf-16`, `utf-32`, `string`, `wstring`: Scheme 문자열을 널 종료(Null-terminated) 인코딩 바이트로 변환하여 전달.
* `scheme-object` / `ptr`: 변환 없이 Scheme 객체 자체를 직접 전달 (GC에 의해 이동될 수 있으므로 유의 필요).
