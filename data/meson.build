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
      join_paths('logo', 'logo.png'),
      install_dir: join_paths(get_option('prefix'), get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'),
      rename: meson.project_name() + '.png'
  )

  install_data(
      join_paths('logo', 'logo.png'),
      install_dir: join_paths(get_option('prefix'), get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps'),
      rename: meson.project_name() + '.png'
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
        input: 'com.vysp3r.RetroPlus.metainfo.xml.in',
       output: 'com.vysp3r.RetroPlus.metainfo.xml',
       po_dir: '../po',
      install: true,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)

appstreamcli = find_program('appstreamcli', required: true)
if appstreamcli.found()
  test('Validate appstream file',
       appstreamcli,
       args: ['validate', '--no-net', '--explain', appstream_file.full_path()],
       depends: appstream_file,
       workdir: meson.current_build_dir()
  )
endif

compile_schemas = find_program('glib-compile-schemas', required: true)
if compile_schemas.found()
  test('Validate schema file',
       compile_schemas,
       args: ['--strict', '--dry-run', meson.current_source_dir()])
endif
