require 'puppet/provider/exec'

begin
  require 'puppet_x/puppetlabs/transport'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  mod = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
  require File.join mod.path, 'lib/puppet_x/puppetlabs/transport'
end

begin
  require 'puppet_x/puppetlabs/transport/winrm'
rescue LoadError => e 
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  require File.join module_lib, 'puppet_x/puppetlabs/transport/winrm'
end

Puppet::Type.type(:exec).provide(:winrm_ps, :parent => Puppet::Provider::Exec) do
  # We need to simulate command $?.exitstatus:
  ExitStatus = Struct.new(:exitstatus)

  # We can only have a single parent provider, so small amount of duplicate code:
  def winrm
    @transport ||= PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => resource[:transport], :catalog => resource.catalog, :provider => 'winrm')
    @transport.winrm
  end

  def run(command, check = false)
    output = winrm.powershell(command)
    stdout = output[:data].collect{|line| line[:stdout]}.join
    stderr = output[:data].collect{|line| line[:stderr]}.join
    Puppet.debug(stdout)
    # This is required to provide exitstatus for parent provider
    exitcode = ExitStatus.new(output[:exitcode])
    [stdout+stderr, exitcode]
  end

  def checkexe(command)
  end

  def validatecmd(command)
    true
  end

  private
  def native_path(path)
    path.gsub(File::SEPARATOR, File::ALT_SEPARATOR)
  end

  # not inuse, require monkey patch of winrm gem.
  def args
    '-NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass'
  end
end
