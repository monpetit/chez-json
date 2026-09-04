# =========================================================================
# Ubuntu 24.04 (Linuxbrew) + Chez Scheme 10.4.1 + Jansson FFI 빌드 설정
# =========================================================================

# 빌드 타겟 이름 (출력될 공유 라이브러리)
TARGET = libchezjson.so
JANSSON_BRIDGE_TARGET = libjansson-bridge.so

# 소스 파일
SRCS = chez_json.c
OBJS = $(SRCS:.c=.o)
BRIDGE_SRC = jansson_bridge.c
BRIDGE_OBJ = $(BRIDGE_SRC:.c=.o)

# 1. Linuxbrew 기본 경로 정의
BREW_PREFIX = /home/linuxbrew/.linuxbrew

# 2. Chez Scheme 10.4.1 헤더 파일 경로
CHEZ_INCLUDE_DIR = $(BREW_PREFIX)/Cellar/chezscheme/10.4.1/lib/csv10.4.1/ta6le
CHEZ_INCLUDE_DIR += $(BREW_PREFIX)/include

# 컴파일러 및 플래그 설정
CC = gcc
CFLAGS = -Wall -O2 -fPIC -I$(CHEZ_INCLUDE_DIR) -I$(BREW_PREFIX)/include

# 링크 플래그 설정
# -L: 빌드할 때 brew lib 폴더에서 libjansson을 찾도록 함
# -Wl,-rpath: 프로그램 실행 시점에 시스템(/usr/lib) 대신 brew lib 폴더를 먼저 뒤지도록 고정함
LDFLAGS = -shared -L$(BREW_PREFIX)/lib -Wl,-rpath,$(BREW_PREFIX)/lib -ljansson

# =========================================================================
# 빌드 규칙 (Rules)
# =========================================================================

all: $(TARGET) $(JANSSON_BRIDGE_TARGET)

# 공유 라이브러리 링크
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET) $(LDFLAGS)

$(JANSSON_BRIDGE_TARGET): $(BRIDGE_OBJ)
	$(CC) $(BRIDGE_OBJ) -o $(JANSSON_BRIDGE_TARGET) $(LDFLAGS)

# C 소스 컴파일
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# 정리 (Clean)
clean:
	rm -f $(OBJS) $(BRIDGE_OBJ) $(TARGET) $(JANSSON_BRIDGE_TARGET)

.PHONY: all clean
