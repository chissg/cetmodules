#[================================================================[.rst:
ParseUpsVersion
===============
#]================================================================]
include_guard()

cmake_minimum_required(VERSION 3.18.2...3.22 FATAL_ERROR)

include(Compatibility)
include(ParseVersionString)
include(private/CetHandleExtendedVersion)

macro(parse_ups_version _puv_ups_version)
  warn_deprecated("parse_ups_version()" NEW "parse_version_string(${_puv_ups_version} VMAJ VMIN VPRJ VPT VEXTRA)")
  parse_version_string(${_puv_ups_version} VMAJ VMIN VPRJ VPT VEXTRA)
endmacro()

macro(to_ups_version _tuv_dot_version _tuv_outvar)
  parse_version_string("${_tuv_dot_version}" PREAMBLE v SEP _ ${_tuv_outvar})
endmacro()

function(set_dot_version PRODUCTNAME UPS_VERSION)
  warn_deprecated("set_dot_version()" " - refer to \${PROJECT_NAME}_VERSION instead")
  string(TOUPPER ${PRODUCTNAME} PRODUCTNAME_UC)
  to_version_string(${UPS_VERSION} tmp)
  if (${PRODUCTNAME_UC}_DOT_VERSION AND NOT tmp STREQUAL ${PRODUCTNAME_UC}_DOT_VERSION)
    message(WARNING "replacing existing value of ${PRODUCTNAME_UC}_DOT_VERSION (${${PRODUCTNAME_UC}_DOT_VERSION}) with ${tmp}")
  endif()
  set(${PRODUCTNAME_UC}_DOT_VERSION ${tmp} PARENT_SCOPE)
endfunction()

macro(set_version_from_ups _SVFU_UPS_VERSION)
  warn_deprecated("set_version_from_ups()" NEW "project(<project-name> VERSION <dot-version>) or set(<project-name>_CMAKE_PROJECT_VERSION_STRING <version-string>")
  if (NOT PROJECT_NAME)
    message(FATAL_ERROR "set_version_from_ups() called before PROJECT()")
  elseif ("${_SVFU_UPS_VERSION}" STREQUAL "")
    message(SEND_ERROR "attempt to set_version_from_ups(\"\")")
    return()
  elseif (NOT ${PROJECT_NAME}_CMAKE_PROJECT_VERSION_STRING STREQUAL "")
    message(WARNING "set_version_from_ups() overridden by ${PROJECT_NAME}_CMAKE_PROJECT_VERSION_STRING (${${PROJECT_NAME}_CMAKE_PROJECT_VERSION_STRING})")
    return()
  endif()
  _cet_set_version_from_ups(${_SVFU_UPS_VERSION})
endmacro()

macro(_cet_set_version_from_ups _csvfu_ups_version)
  to_version_string("${_csvfu_ups_version}" _csvfu_version_string)
  if (PROJECT_NAME STREQUAL CETMODULES_CURRENT_PROJECT_NAME)
    # cet_cmake_env() has already been called.
    set(${PROJECT_NAME}_CMAKE_PROJECT_VERSION_STRING ${_csvfu_version_string})
    _cet_handle_extended_version()
  else()
    # Deal with this when cet_cmake_env() is called.
    set(${PROJECT_NAME}_CMAKE_PROJECT_VERSION_STRING_INIT ${_csvfu_version_string})
  endif()
endmacro()
