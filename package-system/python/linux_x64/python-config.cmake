#
# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
# 
# SPDX-License-Identifier: Apache-2.0 OR MIT
#
#

# this file actually ingests the library and defines targets.
set(MY "Python")
set(TARGET_WITH_NAMESPACE "3rdParty::${MY}")
if (TARGET ${TARGET_WITH_NAMESPACE})
    return()
endif()

# this FindPython file is designed to be compatible with the base FindPython
# to at least some degree.  As such, it uses the same variable names:

# this script defines:
# Python_EXECUTABLE - full path to executable
# Python_INTERPRETER_ID - "Python"
# Python_HOME - Where the python folder root is (ie, folder has subfolder of 'Lib')
# Python_PATHS - Where sys.path should point at to find modules, libraries, etc.
# Python_Development_FOUND - The platform we are cross compiling for can link to python
# and a target called 3rdParty::Python that you can use to depend on

set(${MY}_VERSION 3.10.5)
set(${MY}_INTERPRETER_ID    "Python")
set(${MY}_EXECUTABLE        ${CMAKE_CURRENT_LIST_DIR}/python/bin/python)
set(${MY}_HOME              ${CMAKE_CURRENT_LIST_DIR}/python)
set(${MY}_PATHS             ${CMAKE_CURRENT_LIST_DIR}/python/lib
                            ${CMAKE_CURRENT_LIST_DIR}/python/lib/python3.10
                            ${CMAKE_CURRENT_LIST_DIR}/python/lib/python3.10/lib-dynload
                            ${CMAKE_CURRENT_LIST_DIR}/python/lib/python3.10/site-packages) 

# only if we're compiling FOR on one of the available platforms, add the target and libraries:
if (${PAL_PLATFORM_NAME} STREQUAL "Linux" )
    set(${MY}_Development_FOUND TRUE)
    # Do not use these  PYTHON_LIBRARY_* or other variables, instead, use the 
    # target '3rdParty::Python'
    # note:  we built the shared version of python, you must use the .so
    # in order to load it.  If you don't, then python itself will load a module
    # from a .so and that module will try to load the dylib for python itself
    # and bad things will occur since there'll essentially be both the static 
    # and dy version of python in one address space.
    # also, because the regular .so is a symlink, we actually skip that and link
    # to the real one, so that there's no conflict between what library we copy
    # and what library we link to.
    set(${MY}_LIBRARY_DEBUG   ${CMAKE_CURRENT_LIST_DIR}/python/lib/libpython3.10.so.1.0)
    set(${MY}_LIBRARY_RELEASE ${CMAKE_CURRENT_LIST_DIR}/python/lib/libpython3.10.so.1.0)
    set(${MY}_INCLUDE_DIR     ${CMAKE_CURRENT_LIST_DIR}/python/include/python3.10)
    # DYLIBS causes things to be copied to the bin folder to satisfy RPATH origin
    set(${MY}_DYLIBS_DEBUG    ${CMAKE_CURRENT_LIST_DIR}/python/lib/libpython3.10.so.1.0)
    set(${MY}_DYLIBS_RELEASE  ${CMAKE_CURRENT_LIST_DIR}/python/lib/libpython3.10.so.1.0)

    set(${MY}_COMPILE_DEFINITIONS DEFAULT_LY_PYTHONHOME="${CMAKE_CURRENT_LIST_DIR}/python")

    # the rest of this file could be reused for almost any target:
    # we set it to a generator expression for multi-config situations:
    set(${MY}_LIBRARY "$<IF:$<CONFIG:Debug>,${${MY}_LIBRARY_DEBUG},${${MY}_LIBRARY_RELEASE}>")
    set(${MY}_DYLIBS "$<IF:$<CONFIG:Debug>,${${MY}_DYLIBS_DEBUG},${${MY}_DYLIBS_RELEASE}>")

    # now set up the target using the above declarations....
    add_library(${TARGET_WITH_NAMESPACE} INTERFACE IMPORTED GLOBAL)
    ly_target_include_system_directories(TARGET ${TARGET_WITH_NAMESPACE} INTERFACE ${${MY}_INCLUDE_DIR})
    target_link_libraries(${TARGET_WITH_NAMESPACE} INTERFACE "${${MY}_LIBRARY}")
    target_compile_definitions(${TARGET_WITH_NAMESPACE} INTERFACE "${${MY}_COMPILE_DEFINITIONS}")

    # we also need to add the python dlls to be copied to the binaries folder...
    set_target_properties(${TARGET_WITH_NAMESPACE} PROPERTIES INTERFACE_IMPORTED_LOCATION "${${MY}_DYLIBS}")
endif()

set(${MY}_FOUND True)
