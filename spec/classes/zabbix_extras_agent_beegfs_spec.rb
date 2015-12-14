require 'spec_helper'

describe 'zabbix_extras::agent::beegfs' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :operatingsystemmajrelease  => '6',
    }
  end

  it { should create_class('zabbix_extras::agent::beegfs') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('beegfs').with_ensure('present') }

  it "should create UserParameter for beegfs" do
    content = catalogue.resource('zabbix::agent::userparameter', 'beegfs').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=beegfs.client.status,ls /proc/fs/beegfs/*/.status &>/dev/null && echo "1" || echo "0"',
      'UserParameter=beegfs.config.value[*],awk \'/^$1/{ print $$NF }\' $2',
      'UserParameter=beegfs.list_unreachable,beegfs-check-servers | grep UNREACHABLE | sed -r -e \'s/^(.*)\s+\[.*\]:\s+UNREACHABLE/\1/g\' | paste -sd ","',
      'UserParameter=beegfs.management.reachable[*],beegfs-ctl --listnodes --reachable --nodetype=management | grep -A1 \'^$1 \[\' | grep -c "Reachable: <yes>"',
      'UserParameter=beegfs.metadata.reachable[*],beegfs-ctl --listnodes --reachable --nodetype=metadata | grep -A1 \'^$1 \[\' | grep -c "Reachable: <yes>"',
      'UserParameter=beegfs.storage.reachable[*],beegfs-ctl --listnodes --reachable --nodetype=storage | grep -A1 \'^$1 \[\' | grep -c "Reachable: <yes>"',
      'UserParameter=beegfs.client.reachable[*],beegfs-ctl --listnodes --reachable --nodetype=client | grep -A1 \'^$1 \[\' | grep -c "Reachable: <yes>"',
      'UserParameter=beegfs.pool.status[*],beegfs-ctl --listpools --nodetype=$2 | sed -r -n -e \'s|^\s+$1+\s+\[(.*)\]$|\1|p\'',
      'UserParameter=beegfs.client.num,beegfs-ctl --listnodes --nodetype=client | wc -l',
      'UserParameter=beegfs.metadata.iostat[*],/var/lib/zabbix/bin/beegfs_metadata_iostat.sh $1 $2 $3',
      'UserParameter=beegfs.storage.iostat[*],/var/lib/zabbix/bin/beegfs_storage_iostat.sh $1 $2 $3',
    ]
  end

  it do
    should contain_file('beegfs_metadata_iostat.sh').with({
      'ensure'  => 'present',
      'path'    => "/var/lib/zabbix/bin/beegfs_metadata_iostat.sh",
      'source'  => 'puppet:///modules/zabbix_extras/agent/beegfs/metadata_iostat.sh',
      'owner'   => 'zabbix',
      'group'   => 'zabbix',
      'mode'    => '0755',
      'before'  => 'Zabbix::Agent::Userparameter[beegfs]',
    })
  end

  it do
    should contain_file('beegfs_storage_iostat.sh').with({
      'ensure'  => 'present',
      'path'    => "/var/lib/zabbix/bin/beegfs_storage_iostat.sh",
      'source'  => 'puppet:///modules/zabbix_extras/agent/beegfs/storage_iostat.sh',
      'owner'   => 'zabbix',
      'group'   => 'zabbix',
      'mode'    => '0755',
      'before'  => 'Zabbix::Agent::Userparameter[beegfs]',
    })
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('beegfs').with_ensure('absent') }
    it { should contain_file('beegfs_metadata_iostat.sh').with_ensure('absent') }
    it { should contain_file('beegfs_storage_iostat.sh').with_ensure('absent') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it { expect { should create_class('zabbix_extras::agent::beegfs') }.to raise_error(Puppet::Error, /does not match/) }
  end

end
