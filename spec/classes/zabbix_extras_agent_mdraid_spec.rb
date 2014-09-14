require 'spec_helper'

describe 'zabbix_extras::agent::mdraid' do
  include_context :defaults

  let(:facts){ default_facts }

  it { should create_class('zabbix_extras::agent::mdraid') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('mdraid').with_ensure('present') }

  it "should create UserParameter for mdraid" do
    content = catalogue.resource('zabbix::agent::userparameter', 'mdraid').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=mdraid.state[*],cat /sys/block/$1/md/degraded',
      'UserParameter=mdraid.discovery,/var/lib/zabbix/bin/mdraid_discovery.rb',
    ]
  end

  it do
    should contain_file('mdraid_discovery.rb').with({
      'ensure'  => 'present',
      'path'    => '/var/lib/zabbix/bin/mdraid_discovery.rb',
      'source'  => 'puppet:///modules/zabbix_extras/agent/mdraid/mdraid_discovery.rb',
      'owner'   => 'zabbix',
      'group'   => 'zabbix',
      'mode'    => '0755',
      'before'  => 'Zabbix::Agent::Userparameter[mdraid]',
    })
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('mdraid').with_ensure('absent') }
    it { should contain_file('mdraid_discovery.rb').with_ensure('absent') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it { expect { should create_class('zabbix_extras::agent::mdraid') }.to raise_error(Puppet::Error, /does not match/) }
  end

end
