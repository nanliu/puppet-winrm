require 'winrm' unless Puppet.run_mode.master?

module PuppetX::Puppetlabs::Transport
  class Winrm
    attr_accessor :winrm
    attr_reader :name

    def initialize(opts)
      @name = opts[:name]
      options = opts[:options] || {}
      @options = options.inject({}){|h, (k, v)| h[k.to_sym] = v; h}

      @port = @options.fetch(:port, 5985)
      @connection = @options.fetch(:connection, :plaintext)
      case connection
      when :plaintext
        @endpoint = "http://#{opts[:server]}:#{opts[:port]}/wsman"
        @options[:user] = opts[:username]
        @options[:pass] = opts[:password]
        @options[:basic_auth_only] ||= true
        @options[:disable_sspi] ||= true
      when :ssl
        @endpoint = "https://#{opts[:server]}:#{opts[:port]}/wsman"
        @options[:user] = opts[:username]
        @options[:pass] = opts[:password]
        @options[:basic_auth_only] ||= true
        @options[:disable_sspi] ||= true
      when :kerberos
        @endpoint = "https://#{opts[:server]}:#{opts[:port]}/wsman"
      end
      Puppet.debug("#{self.class} initializing connection to: #{@options[:host]}")
    end

    def connect
      @winrm ||= WinRM::WinRMWebService.new(
        @endpoint,
        @connection,
        @options
      )
    end
  end
end
