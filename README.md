# 基于平头哥的QEMU的验证项目
1. 在MacBook air M2上开发，需要手动编译工具链和QEMU
2. 使用newlib基础库
3. 使用CMake进行项目管理
4. 目标为E907，其他也应该类似

# 发现的差异点
1. newlib在crt0时没有初始化栈地址，这里手动初始化
2. newlib实现了部分的半虚拟化接口，会导致运行异常

# 编译与运行测试
1. 编译安装工具链到/opt/riscv64
2. mkdir build
3. cd build
4. cmake -DCMAKE_TOOLCHAIN_FILE=../scripts/riscv-elf.cmake  ..
5. 返回项目目录，执行cskysim -soc qemu-cskysim/soccfg/riscv32/smartl_907_cfg.xml -kernel build/modern-e907 -display none -serial stdio

# 调试程序
1. 指的编译为Debug版本cmake -DCMAKE_TOOLCHAIN_FILE=../scripts/riscv-elf.cmake  -DCMAKE_BUILD_TYPE=Debug ..
2. 添加运行参数-s -S即可建立gdb调试
3. 将gdb链接到:1234进行远程调试即可或者使用vscode也行