# Project name and programming language
project('com.github.avojak.warble', 'vala', 'c', version: '2.0.1')

i18n = import('i18n')
gnome = import('gnome')

vala_args = ['--pkg', 'posix']

application_id = meson.project_name()
application_name = 'Warble'

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language: 'c')

subdir('data')
subdir('src')
subdir('po')

meson.add_install_script('meson/post_install.py')
