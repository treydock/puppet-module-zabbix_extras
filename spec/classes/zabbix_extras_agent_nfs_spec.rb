require 'spec_helper'

describe 'zabbix_extras::agent::nfs' do
  include_context :defaults

  let(:facts){ default_facts }

  it { should create_class('zabbix_extras::agent::nfs') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('nfs').with_ensure('present') }

  it "should create UserParameter for nfs" do
    content = catalogue.resource('zabbix::agent::userparameter', 'nfs').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=nfsd.proc.hung,pgrep nfsd | xargs ps -o state= | egrep -v -c "R|S"',
      'UserParameter=nfsd.threads.count,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f2',
      'UserParameter=nfsd.threads.fullcnt,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f3',
      'UserParameter=nfsd.threads.10pct_used,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f4',
      'UserParameter=nfsd.threads.20pct_used,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f5',
      'UserParameter=nfsd.threads.30pct_used,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f6',
      'UserParameter=nfsd.threads.40pct_used,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f7',
      'UserParameter=nfsd.threads.50pct_used,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f8',
      'UserParameter=nfsd.threads.60pct_used,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f9',
      'UserParameter=nfsd.threads.70pct_used,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f10',
      'UserParameter=nfsd.threads.80pct_used,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f11',
      'UserParameter=nfsd.threads.90pct_used,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f12',
      'UserParameter=nfsd.threads.100pct_used,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f13',
    ]
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('nfs').with_ensure('absent') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it { expect { should create_class('zabbix_extras::agent::nfs') }.to raise_error(Puppet::Error, /does not match/) }
  end

end
