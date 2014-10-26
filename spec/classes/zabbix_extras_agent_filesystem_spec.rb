require 'spec_helper'

describe 'zabbix_extras::agent::filesystem' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :operatingsystemmajrelease  => '6',
    }
  end

  it { should create_class('zabbix_extras::agent::filesystem') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('filesystem').with_ensure('present') }

  it "should create UserParameter for filesystem" do
    content = catalogue.resource('zabbix::agent::userparameter', 'filesystem').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=filesystem.mounted[*], /bin/mountpoint -q $1 && echo 1 || echo 0',
      'UserParameter=filesystem.checkro[*],/var/lib/zabbix/bin/checkro.sh "$1"',
    ]
  end

  it do
    should contain_file('checkro.sh').with({
      'ensure'  => 'present',
      'path'    => "/var/lib/zabbix/bin/checkro.sh",
      'source'  => 'puppet:///modules/zabbix_extras/agent/filesystem/checkro.sh',
      'owner'   => 'zabbix',
      'group'   => 'zabbix',
      'mode'    => '0755',
      'before'  => 'Zabbix::Agent::Userparameter[filesystem]',
    })
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('filesystem').with_ensure('absent') }
    it { should contain_file('checkro.sh').with_ensure('absent') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it { expect { should create_class('zabbix_extras::agent::filesystem') }.to raise_error(Puppet::Error, /does not match/) }
  end

end
