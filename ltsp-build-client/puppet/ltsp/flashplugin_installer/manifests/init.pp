class flashplugin_installer {
  # XXX /root/debs/flashplugin-installer_*.deb is not going to be updated
  # XXX unless a fresh image build is started

  exec {
    'install flashplugin_install debian package':
      command => '/usr/bin/apt-get install --download-only flashplugin-installer && ls -1 /var/cache/apt/archives/flashplugin-installer_* | tail -n 1 | xargs cp -t /root/debs/',
      require => File['/root/debs'],
      unless  => '/bin/ls /root/debs/flashplugin-installer_*';
  }

  file {
    '/root/debs':
      ensure => directory;

    '/usr/lib/mozilla/plugins/flashplugin-alternative.so':
      ensure => link,
      target => '/state/proprietary/usr/lib/flashplugin-installer/libflashplayer.so';

    '/usr/local/sbin/install_flashplugin_with_installer_package':
      mode   => 755,
      source => 'puppet:///modules/flashplugin_installer/install_flashplugin_with_installer_package';
  }
}
