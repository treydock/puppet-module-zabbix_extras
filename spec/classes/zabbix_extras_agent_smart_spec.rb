require 'spec_helper'

describe 'zabbix_extras::agent::smart' do
  include_context :defaults

  let(:facts){ default_facts }

  it { should create_class('zabbix_extras::agent::smart') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('smart').with_ensure('present') }

  it "should create UserParameter for smart" do
    content = catalogue.resource('zabbix::agent::userparameter', 'smart').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=smartctl.health[*],sudo /usr/sbin/smartctl -H $1 | sed -n -r -e \'s/^(SMART overall-health self-assessment test result|SMART Health Status): (.*)$/\2/p\' | grep -c \'OK\|PASSED\'',
    ]
  end

  it { should contain_zabbix__agent__sudo('smart').with_command('/usr/sbin/smartctl -H /dev/*') }

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('smart').with_ensure('absent') }
  end

  context 'when manage_sudo => false' do
    let(:params) {{ :manage_sudo => false }}
    it { should_not contain_zabbix__agent__sudo('smart') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it { expect { should create_class('zabbix_extras::agent::smart') }.to raise_error(Puppet::Error, /does not match/) }
  end

  context "with manage_sudo => 'foo'" do
    let(:params) {{ :manage_sudo => 'foo' }}
    it { expect { should create_class('zabbix_extras::agent::smart') }.to raise_error(Puppet::Error, /is not a boolean/) }
  end
end
