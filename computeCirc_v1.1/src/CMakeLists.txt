cmake_minimum_required(VERSION 3.23)
enable_language(Fortran)
project(computeCirc LANGUAGES Fortran C)

find_package(Python COMPONENTS Interpreter Development.Module NumPy)
find_package(PythonExtensions REQUIRED)
find_package(NumPy REQUIRED)
find_package(F2PY REQUIRED)
include_directories(Python_NumPy_INCLUDE_DIR Python_INCLUDE_DIR)

set(f2py_module_name "_f_circ")
set(fortran_src_file "${CMAKE_CURRENT_SOURCE_DIR}/circ.f90" "${CMAKE_CURRENT_SOURCE_DIR}/interp.f90")

set(generated_module_file ${CMAKE_CURRENT_BINARY_DIR}/${f2py_module_name}${PYTHON_EXTENSION_MODULE_SUFFIX})

add_custom_target(${f2py_module_name} ALL
  DEPENDS ${generated_module_file}
)

add_custom_command(
  OUTPUT ${generated_module_file}
  COMMAND ${F2PY_EXECUTABLE}
    -m ${f2py_module_name}
    -c
    ${fortran_src_file}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

install(FILES ${generated_module_file} DESTINATION "computeCirc")
