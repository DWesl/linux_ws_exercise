cmake_minimum_required(VERSION 3.23)
enable_language(Fortran)
project(computeCirc LANGUAGES Fortran C)

# find_package(Python COMPONENTS Interpreter Development.Module NumPy)
find_package(PythonExtensions REQUIRED)
find_package(NumPy REQUIRED)
find_package(F2PY REQUIRED)
find_package(Cython REQUIRED)
include_directories(${Python_NumPy_INCLUDE_DIR} ${Python_INCLUDE_DIR})

set(f2py_module_name "_f_circ")
set(
    fortran_src_file
    "${CMAKE_CURRENT_SOURCE_DIR}/interp.f90" "${CMAKE_CURRENT_SOURCE_DIR}/circ.f90"
)

set(
    generated_module_file
    ${CMAKE_CURRENT_BINARY_DIR}/${f2py_module_name}${PYTHON_EXTENSION_MODULE_SUFFIX}
)

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

install(
    FILES ${generated_module_file}
    DESTINATION "computeCirc"
    PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
)

# if(CYTHON_FOUND)

add_cython_target(
    _cy_circ
    _cy_circ.pyx
    C PY3
    OUTPUT_VAR "cy_circ_src"
  )

# add_library("_cy_circ${PYTHON_EXTENSION_MODULE_SUFFIX}" MODULE ${cy_circ_src})
add_library("_cy_circ" MODULE ${cy_circ_src})
python_extension_module("_cy_circ")
# target_link_libraries("_cy_circ${PYTHON_EXTENSION_MODULE_SUFFIX}" "${Python_LIBRARIES}")
# target_include_directories("_cy_circ${PYTHON_MODULE_SUFFIX}")
# install(
#     TARGETS
#     "_cy_circ${PYTHON_EXTENSION_MODULE_SUFFIX}"
#     DESTINATION "computeCirc"
#     PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
# )

# Python_add_library(_cy_circ MODULE WITH_SOABI ${cy_circ_src})
# # python_extension_module(_cy_circ)

install(
    TARGETS _cy_circ
    DESTINATION "computeCirc"
    PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
)

# endif()
