require 'spec_helper'

describe 'zabbix_extras::agent::osg_ce' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :operatingsystemmajrelease  => '6',
    }
  end

  it { should create_class('zabbix_extras::agent::osg_ce') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('osg-ce').with_ensure('present') }

  it "should create UserParameter for osg-ce" do
    content = catalogue.resource('zabbix::agent::userparameter', 'osg-ce').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=osg.ce.schedd.ad[*],/var/lib/zabbix/bin/htcondor-ce-schedd-ad.py --ad $1',
    ]
  end

  it do
    should contain_file('htcondor-ce-schedd-ad.py').with({
      'ensure'  => 'present',
      'path'    => "/var/lib/zabbix/bin/htcondor-ce-schedd-ad.py",
      'source'  => 'puppet:///modules/zabbix_extras/agent/osg-ce/htcondor-ce-schedd-ad.py',
      'owner'   => 'zabbix',
      'group'   => 'zabbix',
      'mode'    => '0755',
      'before'  => 'Zabbix::Agent::Userparameter[osg-ce]',
    })
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('osg-ce').with_ensure('absent') }
    it { should contain_file('htcondor-ce-schedd-ad.py').with_ensure('absent') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/does not match/)
    end
  end
end
