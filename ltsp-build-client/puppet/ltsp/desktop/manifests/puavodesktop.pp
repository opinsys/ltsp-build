class desktop::puavodesktop {
  include desktop::dconf::laptop,
          desktop::dconf::puavodesktop,
          desktop::enable_indicator_power_service,
          desktop::mimedefaults,
          packages,
          webmenu

  file {
    '/etc/dconf/db/puavodesktop.d/locks/session_locks':
      content => template('desktop/dconf_session_locks'),
      notify  => Exec['update dconf'];

    '/etc/dconf/db/puavodesktop.d/session_profile':
      content => template('desktop/dconf_session_profile'),
      notify  => Exec['update dconf'],
      require => [ Package['faenza-icon-theme']
                 , Package['light-themes']
                 , Package['webmenu'] ];

    # webmenu takes care of the equivalent functionality
    '/etc/xdg/autostart/indicator-session.desktop':
      ensure  => absent,
      require => Package['indicator-session'];

    '/usr/share/icons/Faenza/apps/24/calendar.png':
      ensure  => link,
      require => Package['faenza-icon-theme'],
      target  => 'evolution-calendar.png';
  }

  Package <| title == faenza-icon-theme
          or title == indicator-session
          or title == light-themes
          or title == webmenu           |>
}
