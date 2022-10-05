cmake_minimum_required(VERSION 3.23)
enable_language(Fortran)
project(computeCirc LANGUAGES Fortran C)

# find_package(Python COMPONENTS Interpreter Development.Module NumPy)
find_package(PythonExtensions REQUIRED)
find_package(NumPy REQUIRED)
find_package(F2PY REQUIRED)
find_package(Cython REQUIRED)
include_directories(${Python_NumPy_INCLUDE_DIR} ${Python_INCLUDE_DIR})

add_subdirectory(src)
