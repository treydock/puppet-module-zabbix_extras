require 'spec_helper'

describe 'zabbix_extras::agent::discovery' do
  include_context :defaults

  let(:facts){ default_facts }

  it { should create_class('zabbix_extras::agent::discovery') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('discovery').with_ensure('present') }

  it "should create UserParameter for discovery" do
    content = catalogue.resource('zabbix::agent::userparameter', 'discovery').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=block_device.discovery,/var/lib/zabbix/bin/block_device_discovery.rb',
    ]
  end

  it do
    should contain_file('block_device_discovery.rb').with({
      :ensure   => 'present',
      :path     => '/var/lib/zabbix/bin/block_device_discovery.rb',
      :source   => 'puppet:///modules/zabbix_extras/agent/discovery/block_device_discovery.rb',
      :owner    => 'zabbix',
      :group    => 'zabbix',
      :mode     => '0755',
      :before   => 'Zabbix::Agent::Userparameter[discovery]',
    })
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('discovery').with_ensure('absent') }
    it { should contain_file('block_device_discovery.rb').with_ensure('absent') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/does not match/)
    end
  end

end
