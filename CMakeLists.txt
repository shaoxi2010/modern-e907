cmake_minimum_required(VERSION 3.18)
project(modern-e907)

include_directories(include)

# 子项目
add_subdirectory(cpu)
add_subdirectory(newlib-stub)
add_subdirectory(app)

# 目标
add_executable(${PROJECT_NAME})
target_link_libraries(${PROJECT_NAME}  ${TARGET_OBJS})


# newlib的标准初始化代码没有初始化sp栈，这里重写了栈入口地址
target_link_options(${PROJECT_NAME} PRIVATE -nostartfiles)
