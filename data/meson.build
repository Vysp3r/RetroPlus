icons_gresource = gnome.compile_resources(
	'gresource_icons',
	'icons/icons.gresource.xml',
	source_dir: 'icons'
)

css_gresource = gnome.compile_resources(
	'gresource_css',
	'css/css.gresource.xml',
  source_dir: 'css'
)

install_data('com.vysp3r.RetroPlus.gschema.xml',
  install_dir: get_option('datadir') + '/glib-2.0/schemas'
)

icon_sizes = ['32', '48', '64', '128']
foreach i : icon_sizes
  install_data(
      join_paths('logo', 'logo.svg'),
      install_dir: join_paths(get_option('prefix'), get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'),
      rename: meson.project_name() + '.svg'
  )

  install_data(
      join_paths('logo', 'logo.svg'),
      install_dir: join_paths(get_option('prefix'), get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps'),
      rename: meson.project_name() + '.svg'
  )
endforeach

desktop_file = i18n.merge_file(
        input: 'com.vysp3r.RetroPlus.desktop.in',
       output: 'com.vysp3r.RetroPlus.desktop',
         type: 'desktop',
       po_dir: '../po',
      install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils, args: [desktop_file])
endif

appstream_file = i18n.merge_file(
        input: 'com.vysp3r.RetroPlus.appdata.xml.in',
       output: 'com.vysp3r.RetroPlus.appdata.xml',
       po_dir: '../po',
      install: true,
  install_dir: join_paths(get_option('datadir'), 'appdata')
)

appstream_util = find_program('appstream-util', required: true)
if appstream_util.found()
  test('Validate appstream file', appstream_util, args: ['validate', appstream_file])
endif

compile_schemas = find_program('glib-compile-schemas', required: true)
if compile_schemas.found()
  test('Validate schema file',
       compile_schemas,
       args: ['--strict', '--dry-run', meson.current_source_dir()])
endif
