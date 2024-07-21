cmake_minimum_required(VERSION 3.10)
project(remote_monitor)

# Print entered values (optional)
message(STATUS "Remote Host: ${RH}")
message(STATUS "Username: ${UN}")
message(STATUS "Password: ${PASS}")
message(STATUS "CPU: ${CPU}")
message(STATUS "MEM: ${MEM}")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
include_directories(include)

add_definitions(-DRH="${RH}")
add_definitions(-DUN="${UN}")
add_definitions(-DPASS="${PASS}")
add_definitions(-DCPU="${CPU}")
add_definitions(-DMEM="${MEM}")

add_executable(remote_monitor src/main.cpp src/ssh_connection.cpp src/hardware_monitor.cpp)
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBSSH REQUIRED libssh)

include_directories(${LIBSSH_INCLUDE_DIRS})
target_link_libraries(remote_monitor ${LIBSSH_LIBRARIES})

