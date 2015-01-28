require 'spec_helper'

describe 'zabbix_extras::agent::dell' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :operatingsystemmajrelease  => '6',
      :manufacturer               => 'Dell Inc.',
    }
  end

  it { should create_class('zabbix_extras::agent::dell') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('dell').with_ensure('present') }

  it "should create UserParameter for dell" do
    content = catalogue.resource('zabbix::agent::userparameter', 'dell').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      "UserParameter=omreport.chassis.health[*],/opt/dell/srvadmin/bin/omreport chassis -fmt ssv | sed -r 's/^([-a-zA-Z]+);($1)$/\\1/;tx;d;:x'",
      "UserParameter=omreport.esmlog.health,/opt/dell/srvadmin/bin/omreport system esmlog -fmt ssv | /bin/egrep \"^Health\" | /bin/sed -r 's/^Health;([-a-zA-Z]+)$/\\1/'",
      "UserParameter=omreport.storage.controller[*],/opt/dell/srvadmin/bin/omreport storage controller | /bin/egrep \"^$1\" | /bin/sed -r 's/^(.*):\\s(.*)$/\\2/g'",
      "UserParameter=omreport.storage.pdisk[*],/opt/dell/srvadmin/bin/omreport storage pdisk controller=0 | /bin/egrep \"^$1\" | /bin/sed -r 's/^(.*):\\s(.*)$/\\2/g'",
    ]
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('dell').with_ensure('absent') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it { expect { should create_class('zabbix_extras::agent::dell') }.to raise_error(Puppet::Error, /does not match/) }
  end

  context "when manufacturer is not Dell" do
    let :facts do
      {
        :osfamily                   => 'RedHat',
        :operatingsystemmajrelease  => '6',
        :manufacturer               => 'Supermicro',
      }
    end

    it { should_not contain_zabbix__agent__userparameter('dell') }
  end
end
