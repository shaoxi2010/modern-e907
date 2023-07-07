# Apple silicon build change
for build in apple silicon, need to modify some file of gcc

# brew is not linux
Macos have cslpit but outputs is different, use coreutils in brew instead.
```
brew install coreutils
``` 
patch
```
diff --git a/gcc/Makefile.in b/gcc/Makefile.in
index ed0f58a3951..00cc53286c1 100644
--- a/gcc/Makefile.in
+++ b/gcc/Makefile.in
@@ -2387,7 +2387,7 @@ $(simple_generated_c:insn-%.c=s-%): s-%: build/gen%$(build_exeext)
        $(RUN_GEN) build/gen$*$(build_exeext) $(md_file) \
          $(filter insn-conditions.md,$^) > tmp-$*.c
        $(SHELL) $(srcdir)/../move-if-change tmp-$*.c insn-$*.c
-       $*v=$$(echo $$(LC_MESSAGES=C csplit insn-$*.c /parallel\ compilation/ -k -s {$(INSN-GENERATED-SPLIT-NUM)} -f insn-$* -b "%d.c" 2>&1));\
+       $*v=$$(echo $$(LC_MESSAGES=C gcsplit insn-$*.c /parallel\ compilation/ -k -s {$(INSN-GENERATED-SPLIT-NUM)} -f insn-$* -b "%d.c" 2>&1));\
        [ ! "$$$*v" ] || grep "match not found" <<< $$$*v
        [ -s insn-$*0.c ] || (for i in $(insn-generated-split-num); do touch insn-$*$$i.c; done && echo "" > insn-$*.c)
        $(STAMP) s-$*
```
[Homebrew](https://brew.sh) can be used to install the GNU versions of tools onto your Mac, but they are all prefixed with "g" by default.

# Apple silicon undefined sysbols error
this is a gcc bug for apple silicon
```
Undefined symbols for architecture arm64:
  "_host_hooks", referenced from:
      c_common_no_more_pch() in c-pch.o
      toplev::main(int, char**) in libbackend.a(toplev.o)
      gt_pch_save(__sFILE*) in libbackend.a(ggc-common.o)
      gt_pch_restore(__sFILE*) in libbackend.a(ggc-common.o)
ld: symbol(s) not found for architecture arm64
```
1. seems to work [patch](https://dev.haiku-os.org/ticket/17191#no1)
```
diff --git a/gcc/config/aarch64/aarch64.h b/gcc/config/aarch64/aarch64.h
index 1ce23c68781..1cde126a1c1 100644
--- a/gcc/config/aarch64/aarch64.h
+++ b/gcc/config/aarch64/aarch64.h
@@ -1177,7 +1177,7 @@ extern const char *aarch64_rewrite_mcpu (int argc, const char **argv);
 #define MCPU_TO_MARCH_SPEC_FUNCTIONS \
   { "rewrite_mcpu", aarch64_rewrite_mcpu },
 
-#if defined(__aarch64__)
+#if defined(__aarch64__) && !defined(__APPLE__)
 extern const char *host_detect_local_cpu (int argc, const char **argv);
 #define HAVE_LOCAL_CPU_DETECT
 # define EXTRA_SPEC_FUNCTIONS                                          \
diff --git a/gcc/config/host-darwin.c b/gcc/config/host-darwin.c
index 0face6c450f..aa0a42c0038 100644
--- a/gcc/config/host-darwin.c
+++ b/gcc/config/host-darwin.c
@@ -22,6 +22,8 @@
 #include "coretypes.h"
 #include "diagnostic-core.h"
 #include "config/host-darwin.h"
+#include "hosthooks.h"
+#include "hosthooks-def.h"
 
 /* Yes, this is really supposed to work.  */
 static char pch_address_space[1024*1024*1024] __attribute__((aligned (4096)));
@@ -75,3 +77,5 @@ darwin_gt_pch_use_address (void *addr, size_t sz, int fd, size_t off)
 
   return ret;
 }
+
+const struct host_hooks host_hooks = HOST_HOOKS_INITIALIZER;
```

2. another way [issue](https://github.com/riscv-software-src/homebrew-riscv/issues/47)
```
sed -i '' "s/.*=host-darwin.o$//" riscv-gcc/gcc/config.host
sed -i '' "s/.* x-darwin.$//" riscv-gcc/gcc/config.host
```

# multilib newlib patch
multilib build error for pthread
```
diff --git a/newlib/libc/machine/riscv/pthread.c b/newlib/libc/machine/riscv/pthread.c
index e6fef2ab5..7e62b7b90 100644
--- a/newlib/libc/machine/riscv/pthread.c
+++ b/newlib/libc/machine/riscv/pthread.c
@@ -4,8 +4,7 @@
 
 #include <pthread.h>
 
-#include "../../libgloss/libnosys/config.h"
-#include "../../../libgloss/libnosys/warning.h"
+#include "../../../../libgloss/libnosys/warning.h"
 
 int _ATTRIBUTE((__weak__))
 pthread_once (pthread_once_t *__once_control,
```

# multilib build fail
have no idea, the genmultilib script cant not exit. 
after genmultilib, make will no responed.
ref t-elf-multilib configure.ac

```
echo "" > tmp-mlib-args
echo "" >> tmp-mlib-args
echo "" >> tmp-mlib-args
echo "" >> tmp-mlib-args
echo "" >> tmp-mlib-args
echo "" >> tmp-mlib-args
echo "" >> tmp-mlib-args
echo "" >> tmp-mlib-args
echo "" >> tmp-mlib-args
echo "" >> tmp-mlib-args
echo "no" >> tmp-mlib-args
if test no = yes \
	   || test -n ""; then \
	  /bin/sh ../.././riscv-gcc/gcc/genmultilib --from-file tmp-mlib-args \
	    > tmp-mlib.h; \
	else \
	  /bin/sh ../.././riscv-gcc/gcc/genmultilib '' '' '' '' '' '' '' '' \
	    "" '' no \
	    > tmp-mlib.h; \
	fi
```

# multilib-generator execute failed
python is remove in homwbrew, use python3 instead.

# GDB not working
run gdb say I'm sorry, Dave, I can't do that.  Symbol format `elf64-littleriscv' unknown.
see the commit [GDB: Fix detection of ELF support when configuring with -Werror=implicit-function-declaration](https://github.com/bminor/binutils-gdb/commit/b413232211bf7c7754095b017f27774d7064648)

# build configure
./configure --prefix=/opt/riscv64 --with-multilib-generator="rv64imafdc-lp64d--;rv32imafdc-ilp32d--"
1. -march=rv64gc compile or link as rv64gc
2. -march=rv32gc compile or link as rv32gc
3. -march=rv32imafdc zfh xtheadc for compile E907 thread extend
4. -march=rv64imafdc zfh xtheadc for compile C906 thread extend