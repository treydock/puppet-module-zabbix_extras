require 'spec_helper'

describe 'zabbix_extras::agent::edac' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :operatingsystemmajrelease  => '6',
    }
  end

  it { should create_class('zabbix_extras::agent::edac') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('edac').with_ensure('present') }

  it "should create UserParameter for edac" do
    content = catalogue.resource('zabbix::agent::userparameter', 'edac').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      "UserParameter=edac.ecc.uncorrected,/usr/bin/edac-util --report=ue | /bin/sed -r -e 's/^UE: ([0-9]+)/\\1/g'",
      "UserParameter=edac.ecc.corrected,/usr/bin/edac-util --report=ce | /bin/sed -r -e 's/^CE: ([0-9]+)/\\1/g'",
      "UserParameter=edac.status,(/usr/sbin/edac-ctl --status --quiet ; echo $?)",
    ]
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('edac').with_ensure('absent') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it { expect { should create_class('zabbix_extras::agent::edac') }.to raise_error(Puppet::Error, /does not match/) }
  end
end
