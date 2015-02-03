require 'spec_helper'

describe 'zabbix_extras::agent::proc' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :operatingsystemmajrelease  => '6',
    }
  end

  it { should create_class('zabbix_extras::agent::proc') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('proc').with_ensure('present') }

  it "should create UserParameter for proc" do
    content = catalogue.resource('zabbix::agent::userparameter', 'proc').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      "UserParameter=pgrep.num[*],/usr/bin/pgrep \"$1\" | wc -l",
    ]
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('proc').with_ensure('absent') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it { expect { should create_class('zabbix_extras::agent::proc') }.to raise_error(Puppet::Error, /does not match/) }
  end
end
