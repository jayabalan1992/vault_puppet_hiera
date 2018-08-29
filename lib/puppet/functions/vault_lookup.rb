Puppet::Functions.create_function(:vault_lookup) do
  begin
    require 'json'
  rescue LoadError => e
    raise Puppet::DataBinding::LookupError, "[hiera-vault] Must install json gem to use hiera-vault backend"
  end
  begin
    require 'vault'
  rescue LoadError => e
    raise Puppet::DataBinding::LookupError, "[hiera-vault] Must install vault gem to use hiera-vault backend"
  end
    
  local_types do
    type 'SecretPath     = Pattern[/\/secret\/?.*/]'
    type 'SecretBase     = Variant[SecretPath, Array[SecretPath]]'
  end

  dispatch :vault_lookup do
    param 'Variant[String, Numeric]', :key
    param 'Struct[{secret_base              => SecretBase,
                   Optional[vault_addr]     => Pattern[/http(s)?:\/\/.*/],
                   Optional[vault_token]    => String[1],
                   Optional[default_key]    => String[1],
                   Optional[vault_key_file] => String[1],
                   Optional[ssl_verify]     => Boolean,
                   Optional[ssl_ciphers]    => Any,
                   Optional[ssl_ca_cert]    => Any,
                   Optional[ssl_ca_path]    => Any}]', :options
    param 'Puppet::LookupContext', :context
  end

  def vault_lookup(key, options, context)

    return context.cached_value(key) if context.cache_has_key(key)

    if ENV['VAULT_TOKEN'] == 'IGNORE-VAULT'
      return context.not_found
    end

    result = vault_get(key, options, context)
    context.not_found if result_raw.empty?
    context.cache(key, result)
  end

  def vault_get(key, options, context)
    Vault.address = options["vault_addr"] if options["vault_addr"]
    Vault.token = options["vault_token"] if options["vault_token"]
    Vault.ssl_verify = options["ssl_verify"] if options["ssl_verify"]
    Vault.ssl_ciphers = options["ssl_ciphers"] if options["ssl_ciphers"]
    Vault.ssl_ca_cert = options["ssl_ca_cert"] if options["ssl_ca_cert"]
    Vault.ssl_ca_path = options["ssl_ca_path"] if options["ssl_ca_path"]

    if options["vault_key_file"]
      begin
        @vault_token ||= File.open(options["vault_key_file"]).read.strip
        Vault.token = @vault_token
      rescue Errno::ENOENT => err
        Puppet.warning(err)
      end
    end

    data = normalized_paths(options["secret_base"]).collect do |base|
      Vault.with_retries(Vault::HTTPError) do
        secret = Vault.logical.read(File.join(base, key))
        break secret.data unless secret.nil?
      end
    end.compact.first

    if data.is_a?(Hash)
      Puppet::Pops::Lookup::HieraConfig.symkeys_to_string(data)
    else
      {}
    end
  end

  # Munge String or Array of SecretPaths into an array of paths
  # removing consecutive duplicates
  def normalized_paths(paths)
    Array[paths].flatten.collect do |path|
      path.sub(%r{\/+$}, '')
    end.uniq
  end
end
