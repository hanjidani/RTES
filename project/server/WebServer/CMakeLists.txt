cmake_minimum_required(VERSION 3.10)

project(WebServer)

set(CMAKE_CXX_STANDARD 17)

find_package(Boost 1.66 REQUIRED COMPONENTS system)
include_directories(${CMAKE_SOURCE_DIR}/include)
# Find Boost
find_package(Boost 1.71 REQUIRED COMPONENTS system thread)

# Find MySQL Connector/C++
find_library(MYSQLCPPCONN mysqlcppconn)
include_directories(${MYSQLCPPCONN_INCLUDE_DIR})

# Add the executable
add_executable(WebServer src/main.cpp)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
target_link_libraries(WebServer Boost::system Boost::thread ${MYSQLCPPCONN})