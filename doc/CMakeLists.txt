include(CetGenerateSphinxDocs)

# Default set of formats to generate.
if (NOT DEFINED CACHE{${PROJECT_NAME}_SPHINX_DOC_FORMATS_INIT})
  set(${PROJECT_NAME}_SPHINX_DOC_FORMATS_INIT html man)
endif()

# Define information for substitution in conf.py.in.
set(PROJ_AUTHORS "Lynn Garren" "Patrick Gartung" "Chris Green" "scisoft-team <scisoft-team@fnal.gov>")
set(PROJ_NAME "${PROJECT_NAME}")
set(PROJ_COPYRIGHT_START 2010)
set(PROJ_COPYRIGHT_OWNER "Fermi Research Alliance, LLC")

# Activate version switching.
set(SPHINX_DOC_ARGS -A versionswitch=1)

# Generate the Sphinx configuration file.
if (EXISTS ${PROJECT_SOURCE_DIR}/.git)
  execute_process(COMMAND git branch --show-current
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE current_branch
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(PROJ_VERSION "git-${current_branch}")
  if (NOT PROJ_VERSION STREQUAL "git-develop")
    list(APPEND SPHINX_DOC_ARGS -A outdated=1)
  endif()
  execute_process(COMMAND git rev-parse --short HEAD
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE current_commit
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if (NOT "${current_commit}" STREQUAL "")
    set(PROJ_RELEASE "${PROJ_VERSION}-${current_commit}")
  else()
    set(PROJ_RELEASE "${PROJ_VERSION}")
  endif()
else()
  set(PROJ_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR})
  set(PROJ_RELEASE ${${PROJECT_NAME}_CMAKE_PROJECT_VERSION_STRING})

  file(DOWNLOAD https://raw.githubusercontent.com/FNALssi/cetmodules/gh-pages/latest
    latest
    TIMEOUT 15
    STATUS latest_status
    )
  if (latest_status MATCHES "^0(;|$)")
    file(READ ${PROJECT_BINARY_DIR}/latest latest_version)
    cet_compare_versions(OUTDATED "${PROJ_VERSION}" VERSION_LESS "${latest_version}")
    if (OUTDATED)
      list(APPEND SPHINX_DOC_ARGS -A outdated=1)
    endif()
  endif()
endif()
configure_file(conf.py.in conf.py @ONLY)

set(verbose_levels VERBOSE DEBUG TRACE)
set(quiet_levels ERROR WARNING NOTICE STATUS)
if (NOT CMAKE_MESSAGE_LOG_LEVEL OR CMAKE_MESSAGE_LOG_LEVEL IN_LIST quiet_levels)
  set(qv_arg QUIET)
elseif (CMAKE_MESSAGE_LOG_LEVEL IN_LIST verbose_levels)
  set(qv_arg VERBOSITY ${verbosity})
endif()

# Use it to generate our documentation.
cet_generate_sphinxdocs(${qv_arg} NITPICKY
  CONF_DIR "${CMAKE_CURRENT_BINARY_DIR}"
  EXTRA_ARGS ${SPHINX_DOC_ARGS}
)
