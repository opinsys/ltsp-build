class firefox {
  include config,
          packages

  $api_server = $config::api_server

  # Firefox configuration system is still a mess... if there really is a more
  # straightforward way, I would like to hear about it.
  file {
    '/etc/firefox/puavodesktop.js':
      content => template('firefox/puavodesktop.js'),
      require => Package['firefox'];

    '/etc/firefox/syspref.js':
      content => template('firefox/syspref.js'),
      require => File['/usr/lib/firefox/firefox-puavodesktop.js'];

    '/usr/lib/firefox/firefox-puavodesktop.js':
      content => template('firefox/firefox-puavodesktop.js'),
      require => File['/etc/firefox/puavodesktop.js'];

    '/etc/puavo-external-files-actions.d/firefox':
      require => Package['puavo-ltsp-client'],
      content => template('firefox/puavo-external-files-actions.d/firefox'),
      mode    => 755;
  }

  Package <| title == firefox |>
}
