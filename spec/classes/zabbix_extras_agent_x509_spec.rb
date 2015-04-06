require 'spec_helper'

describe 'zabbix_extras::agent::x509' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :operatingsystemmajrelease  => '6',
    }
  end

  it { should create_class('zabbix_extras::agent::x509') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('x509').with_ensure('present') }

  it "should create UserParameter for x509" do
    content = catalogue.resource('zabbix::agent::userparameter', 'x509').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=x509.expiration[*],/var/lib/zabbix/bin/x509_expiration.sh $1',
    ]
  end

  it do
    should contain_file('x509_expiration.sh').with({
      'ensure'  => 'present',
      'path'    => "/var/lib/zabbix/bin/x509_expiration.sh",
      'source'  => 'puppet:///modules/zabbix_extras/agent/x509/x509_expiration.sh',
      'owner'   => 'zabbix',
      'group'   => 'zabbix',
      'mode'    => '0755',
      'before'  => 'Zabbix::Agent::Userparameter[x509]',
    })
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('x509').with_ensure('absent') }
    it { should contain_file('x509_expiration.sh').with_ensure('absent') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/does not match/)
    end
  end
end
