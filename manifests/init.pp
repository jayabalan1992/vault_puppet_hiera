# Class: hiera_vault
# ===========================
class hiera_vault (
  Boolean $manage_package   = true,
  String  $package_ensure   = 'installed',
  Hash    $package_options  = {},
){
  if $manage_package {
    package { 'vault':
      ensure => $package_ensure,
      *      => $package_options,
    }
  }
}
