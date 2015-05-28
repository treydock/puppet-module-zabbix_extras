require 'spec_helper'

describe 'zabbix_extras::agent::fhgfs' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :operatingsystemmajrelease  => '6',
    }
  end

  it { should create_class('zabbix_extras::agent::fhgfs') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('fhgfs').with_ensure('present') }

  it "should create UserParameter for fhgfs" do
    content = catalogue.resource('zabbix::agent::userparameter', 'fhgfs').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=fhgfs.client.status,ls /proc/fs/fhgfs/*/.status &>/dev/null && echo "1" || echo "0"',
      'UserParameter=fhgfs.config.value[*],awk \'/^$1/{ print $$NF }\' $2',
      'UserParameter=fhgfs.list_unreachable,fhgfs-check-servers | grep UNREACHABLE | sed -r -e \'s/^(.*)\s+\[.*\]:\s+UNREACHABLE/\1/g\' | paste -sd ","',
      'UserParameter=fhgfs.management.reachable[*],fhgfs-ctl --listnodes --reachable --nodetype=management | grep -A1 \'^$1 \[\' | grep -c "Reachable: <yes>"',
      'UserParameter=fhgfs.metadata.reachable[*],fhgfs-ctl --listnodes --reachable --nodetype=metadata | grep -A1 \'^$1 \[\' | grep -c "Reachable: <yes>"',
      'UserParameter=fhgfs.storage.reachable[*],fhgfs-ctl --listnodes --reachable --nodetype=storage | grep -A1 \'^$1 \[\' | grep -c "Reachable: <yes>"',
      'UserParameter=fhgfs.client.reachable[*],fhgfs-ctl --listnodes --reachable --nodetype=client | grep -A1 \'^$1 \[\' | grep -c "Reachable: <yes>"',
      'UserParameter=fhgfs.pool.status[*],fhgfs-ctl --listpools --nodetype=$2 | sed -r -n -e \'s|^\s+$1+\s+\[(.*)\]$|\1|p\'',
      'UserParameter=fhgfs.client.num,fhgfs-ctl --listnodes --nodetype=client | wc -l',
      'UserParameter=fhgfs.metadata.iostat[*],/var/lib/zabbix/bin/fhgfs_metadata_iostat.sh $1 $2 $3',
      'UserParameter=fhgfs.storage.iostat[*],/var/lib/zabbix/bin/fhgfs_storage_iostat.sh $1 $2 $3',
    ]
  end

  it do
    should contain_file('fhgfs_metadata_iostat.sh').with({
      'ensure'  => 'present',
      'path'    => "/var/lib/zabbix/bin/fhgfs_metadata_iostat.sh",
      'source'  => 'puppet:///modules/zabbix_extras/agent/fhgfs/metadata_iostat.sh',
      'owner'   => 'zabbix',
      'group'   => 'zabbix',
      'mode'    => '0755',
      'before'  => 'Zabbix::Agent::Userparameter[fhgfs]',
    })
  end

  it do
    should contain_file('fhgfs_storage_iostat.sh').with({
      'ensure'  => 'present',
      'path'    => "/var/lib/zabbix/bin/fhgfs_storage_iostat.sh",
      'source'  => 'puppet:///modules/zabbix_extras/agent/fhgfs/storage_iostat.sh',
      'owner'   => 'zabbix',
      'group'   => 'zabbix',
      'mode'    => '0755',
      'before'  => 'Zabbix::Agent::Userparameter[fhgfs]',
    })
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('fhgfs').with_ensure('absent') }
    it { should contain_file('fhgfs_metadata_iostat.sh').with_ensure('absent') }
    it { should contain_file('fhgfs_storage_iostat.sh').with_ensure('absent') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it { expect { should create_class('zabbix_extras::agent::fhgfs') }.to raise_error(Puppet::Error, /does not match/) }
  end

end
