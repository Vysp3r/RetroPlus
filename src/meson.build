configuration = configuration_data()
configuration.set_quoted('APP_ID', meson.project_name())
configuration.set_quoted('APP_VERSION', meson.project_version())
configuration.set_quoted('LOCALE_DIR', join_paths (get_option('prefix'), get_option('localedir')))

constants = configure_file(
    input : 'constants.vala.in',
    output : 'constants.vala',
    configuration : configuration
)

sources = [
  'application.vala',
  
  'main-window.vala',
  'preferences-dialog.vala',
  'status-window.vala',

  'widgets/download-popover.vala',
  'widgets/download-row.vala',
  'widgets/search-filter-box.vala',
  'widgets/search-row.vala',

  'widgets/game-detail-dialogs/vimms-lair-game-detail-dialog.vala',
  'widgets/game-detail-dialogs/myrient-game-detail-dialog.vala',

  'utils/web.vala',
  'utils/filesystem.vala',
  'utils/parser.vala',
  
  'utils/parsers/myrient-parser.vala',
  'utils/parsers/vimms-lair-parser.vala',

  'models/game.vala',
  'models/system.vala',
  'models/media.vala',
  'models/region.vala',
  'models/extra.vala',
  'models/source.vala',

  'models/games/myrient-game.vala',
  'models/games/vimms-lair-game.vala',
]

sources += gnome.compile_resources('sources',
  'gresource.xml',
  c_name: 'ui'
)

deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.3'),
  dependency('libarchive'),
  dependency('libsoup-3.0'),
  dependency('json-glib-1.0'),
  dependency('gee-0.8'),
  dependency('libxml-2.0')
]

executable(
  meson.project_name(),
  sources,
  icons_gresource,
  css_gresource,
  constants,
  dependencies: deps,
  install: true,
  link_args : '-lm'
)
