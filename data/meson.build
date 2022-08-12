icon_sizes = ['24', '32', '48', '64', '128']

# Install the icons
foreach i : icon_sizes
    install_data(
        join_paths('assets', 'icons', i + 'x' + i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'),
        rename: '@0@.svg'.format(application_id)
    )
    install_data(
        join_paths('assets', 'icons', i + 'x' + i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps'),
        rename: '@0@.svg'.format(application_id)
    )
endforeach

# Install the dictionary and candidate words files
install_data(
    'dictionary.txt',
    install_dir: join_paths(get_option('prefix'), get_option('datadir'), meson.project_name())
)
install_data(
    'words.txt',
    install_dir: join_paths(get_option('prefix'), get_option('datadir'), meson.project_name())
)

# Install the settings schema
schema_path = '/com/github/avojak/warble/'
schema_conf = configuration_data()
schema_conf.set('appid', application_id)
schema_conf.set('schema-path', schema_path)

configure_file(
    input: '@0@.gschema.xml.in'.format(meson.project_name()),
    output: '@0@.gschema.xml'.format(application_id),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas'),
    configuration: schema_conf
)

# Translate and install our .desktop file so the Applications Menu will see it
desktop_conf = configuration_data()
desktop_conf.set('icon', application_id)
desktop_conf.set('binary', application_id)
desktop_conf.set('name', application_name)

i18n.merge_file(
    input: configure_file(
        input: '@0@.desktop.in.in'.format(meson.project_name()),
        output: '@0@.desktop.in'.format(application_id),
        configuration: desktop_conf
    ),
    output: '@0@.desktop'.format(application_id),
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

# Translate and install our .appdata.xml file so AppCenter will see it
appdata_conf = configuration_data()
appdata_conf.set('appid', application_id)
appdata_conf.set('name', application_name)

i18n.merge_file(
    input: configure_file(
        input: '@0@.appdata.xml.in.in'.format(meson.project_name()),
        output: '@0@.appdata.xml.in'.format(application_id),
        configuration: appdata_conf
    ),
    output: '@0@.appdata.xml'.format(application_id),
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

# Use GResource
css_gresource = gnome.compile_resources(
    'gresource_css',
    meson.project_name() + '.gresource.xml',
    source_dir: 'stylesheet'
)