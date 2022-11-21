cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "msk")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "msk_plugin")

add_library(${PLUGIN_NAME} SHARED
  "msk_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(msk_bundled_libraries
  ""
  PARENT_SCOPE
) 

# Incluir arquivo sqlite3.dll na pasta windows dos projetos
install(FILES "sqlite3.dll" DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)