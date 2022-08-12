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

# install_data(
#     join_paths('assets', 'icons', '64x64', meson.project_name() + '.square-blank.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '64x64', 'status'),
#     rename: '@0@.square-blank.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '64x64', meson.project_name() + '.square-blank.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '64x64@2', 'status'),
#     rename: '@0@.square-blank.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '64x64', meson.project_name() + '.square-close.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '64x64', 'status'),
#     rename: '@0@.square-close.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '64x64', meson.project_name() + '.square-close.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '64x64@2', 'status'),
#     rename: '@0@.square-close.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '64x64', meson.project_name() + '.square-close-high-contrast.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '64x64', 'status'),
#     rename: '@0@.square-close-high-contrast.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '64x64', meson.project_name() + '.square-close-high-contrast.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '64x64@2', 'status'),
#     rename: '@0@.square-close-high-contrast.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '64x64', meson.project_name() + '.square-incorrect.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '64x64', 'status'),
#     rename: '@0@.square-incorrect.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '64x64', meson.project_name() + '.square-incorrect.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '64x64@2', 'status'),
#     rename: '@0@.square-incorrect.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '64x64', meson.project_name() + '.square-correct.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '64x64', 'status'),
#     rename: '@0@.square-correct.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '64x64', meson.project_name() + '.square-correct.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '64x64@2', 'status'),
#     rename: '@0@.square-correct.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '64x64', meson.project_name() + '.square-correct-high-contrast.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '64x64', 'status'),
#     rename: '@0@.square-correct-high-contrast.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '64x64', meson.project_name() + '.square-correct-high-contrast.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '64x64@2', 'status'),
#     rename: '@0@.square-correct-high-contrast.svg'.format(application_id)
# )

# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-blank.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'status'),
#     rename: '@0@.key-blank.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-blank.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32@2', 'status'),
#     rename: '@0@.key-blank.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-pressed-blank.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'status'),
#     rename: '@0@.key-pressed-blank.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-pressed-blank.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32@2', 'status'),
#     rename: '@0@.key-pressed-blank.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-close.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'status'),
#     rename: '@0@.key-close.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-close.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32@2', 'status'),
#     rename: '@0@.key-close.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-close-high-contrast.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'status'),
#     rename: '@0@.key-close-high-contrast.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-close-high-contrast.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32@2', 'status'),
#     rename: '@0@.key-close-high-contrast.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-pressed-close.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'status'),
#     rename: '@0@.key-pressed-close.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-pressed-close.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32@2', 'status'),
#     rename: '@0@.key-pressed-close.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-pressed-close-high-contrast.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'status'),
#     rename: '@0@.key-pressed-close-high-contrast.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-pressed-close-high-contrast.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32@2', 'status'),
#     rename: '@0@.key-pressed-close-high-contrast.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-incorrect.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'status'),
#     rename: '@0@.key-incorrect.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-incorrect.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32@2', 'status'),
#     rename: '@0@.key-incorrect.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-pressed-incorrect.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'status'),
#     rename: '@0@.key-pressed-incorrect.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-pressed-incorrect.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32@2', 'status'),
#     rename: '@0@.key-pressed-incorrect.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-correct.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'status'),
#     rename: '@0@.key-correct.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-correct.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32@2', 'status'),
#     rename: '@0@.key-correct.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-correct-high-contrast.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'status'),
#     rename: '@0@.key-correct-high-contrast.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-correct-high-contrast.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32@2', 'status'),
#     rename: '@0@.key-correct-high-contrast.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-pressed-correct.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'status'),
#     rename: '@0@.key-pressed-correct.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-pressed-correct.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32@2', 'status'),
#     rename: '@0@.key-pressed-correct.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-pressed-correct-high-contrast.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'status'),
#     rename: '@0@.key-pressed-correct-high-contrast.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '32x32', meson.project_name() + '.key-pressed-correct-high-contrast.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32@2', 'status'),
#     rename: '@0@.key-pressed-correct-high-contrast.svg'.format(application_id)
# )

# install_data(
#     join_paths('assets', 'icons', '48x48', meson.project_name() + '.control-key.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '48x48', 'status'),
#     rename: '@0@.control-key.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '48x48', meson.project_name() + '.control-key.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '48x48@2', 'status'),
#     rename: '@0@.control-key.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '48x48', meson.project_name() + '.control-key-pressed.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '48x48', 'status'),
#     rename: '@0@.control-key-pressed.svg'.format(application_id)
# )
# install_data(
#     join_paths('assets', 'icons', '48x48', meson.project_name() + '.control-key-pressed.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '48x48@2', 'status'),
#     rename: '@0@.control-key-pressed.svg'.format(application_id)
# )

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

# sass_command = [
#     sass,
#     '@INPUT@',
#     '@OUTPUT@'
# ]

# stylesheet_light = custom_target(
#     'theme-warble-light',
#     input: './styles/warble-light.scss',
#     output: 'warble-light.css',
#     command: sass_command,
#     build_by_default: true
# )

# stylesheet_dark = custom_target(
#     'theme-warble-dark',
#     input: './styles/warble-dark.scss',
#     output: 'warble-dark.css',
#     command: sass_command,
#     build_by_default: true
# )

# Use GResource
css_gresource = gnome.compile_resources(
    'gresource_css',
    meson.project_name() + '.gresource.xml',
    source_dir: 'stylesheet',
    # c_name: 'as2',
    # dependencies: [ stylesheet_light, stylesheet_dark ]
)