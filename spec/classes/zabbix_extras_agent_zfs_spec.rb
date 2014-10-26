require 'spec_helper'

describe 'zabbix_extras::agent::zfs' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :operatingsystemmajrelease  => '6',
    }
  end

  it { should create_class('zabbix_extras::agent::zfs') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('zfs').with_ensure('present') }

  it "should create UserParameter for zfs" do
    content = catalogue.resource('zabbix::agent::userparameter', 'zfs').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=zpool.health[*],sudo /sbin/zpool list -H -o health $1',
      'UserParameter=zfs.arcstat[*],grep "^$1 " /proc/spl/kstat/zfs/arcstats | awk -F" " \'{ print $$3 }\'',
      'UserParameter=zfs.property[*],sudo /sbin/zfs get -H -p $2 -o value $1',
    ]
  end

  it do
    should contain_zabbix__agent__sudo('zfs').with({
      :command  => [
        '/sbin/zpool list *',
        '/sbin/zpool get *',
        '/sbin/zfs list *',
        '/sbin/zfs get *',
      ]
    })
  end

  it do
    should contain_file('zfs_trapper.sh').with({
      :ensure   => 'present',
      :path     => '/var/lib/zabbix/bin/zfs_trapper.sh',
      :source   => 'puppet:///modules/zabbix_extras/agent/zfs/zfs_trapper.sh',
      :owner    => 'zabbix',
      :group    => 'zabbix',
      :mode     => '0755',
      :before   => 'Zabbix::Agent::Userparameter[zfs]',
    })
  end

  it do
    should contain_file('zabbix-zfs-trapper').with({
      :ensure   => 'present',
      :path     => '/etc/cron.d/zabbix-zfs-trapper',
      :owner    => 'root',
      :group    => 'root',
      :mode     => '0644',
      :require  => 'File[zfs_trapper.sh]',
    })
  end

  it "should have valid cron entry" do
    verify_contents(catalogue, 'zabbix-zfs-trapper', [
      '*/5 * * * * root /var/lib/zabbix/bin/zfs_trapper.sh -z "tank" -f "tank" &>/dev/null'
    ])
  end

  context 'when trapper_minute => "*/10"' do
    let(:params) {{ :trapper_minute => "*/10" }}

    it "should have valid cron entry" do
      verify_contents(catalogue, 'zabbix-zfs-trapper', [
        '*/10 * * * * root /var/lib/zabbix/bin/zfs_trapper.sh -z "tank" -f "tank" &>/dev/null'
      ])
    end
  end

  context 'when trapper_zpools => ["tank","tank2"]' do
    let(:params) {{ :trapper_zpools => ["tank","tank2"] }}

    it "should have valid cron entry" do
      verify_contents(catalogue, 'zabbix-zfs-trapper', [
        '*/5 * * * * root /var/lib/zabbix/bin/zfs_trapper.sh -z "tank tank2" -f "tank" &>/dev/null'
      ])
    end
  end

  context 'when trapper_filesystems => ["tank","tank2"]' do
    let(:params) {{ :trapper_filesystems => ["tank","tank2"] }}

    it "should have valid cron entry" do
      verify_contents(catalogue, 'zabbix-zfs-trapper', [
        '*/5 * * * * root /var/lib/zabbix/bin/zfs_trapper.sh -z "tank" -f "tank tank2" &>/dev/null'
      ])
    end
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('zfs').with_ensure('absent') }
    it { should_not contain_zabbix__agent__sudo('zfs') }
    it { should contain_file('zfs_trapper.sh').with_ensure('absent') }
    it { should contain_file('zabbix-zfs-trapper').with_ensure('absent') }
  end

  context 'when manage_sudo => false' do
    let(:params) {{ :manage_sudo => false }}
    it { should_not contain_zabbix__agent__sudo('zfs') }
  end

  context 'when manage_trapper => false' do
    let(:params) {{ :manage_trapper => false }}
    it { should_not contain_file('zabbix-zfs-trapper') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/does not match/)
    end
  end

  context "with trapper_ensure => 'foo'" do
    let(:params) {{ :trapper_ensure => 'foo' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/does not match/)
    end
  end

  context "with manage_sudo => 'foo'" do
    let(:params) {{ :manage_sudo => 'foo' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/is not a boolean/)
    end
  end

  context "with manage_trapper => 'foo'" do
    let(:params) {{ :manage_trapper => 'foo' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/is not a boolean/)
    end
  end

  context "when trapper_zpools => 'foo'" do
    let(:params) {{ :trapper_zpools => 'foo' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/is not an Array/)
    end
  end

  context "when trapper_filesystems => 'foo'" do
    let(:params) {{ :trapper_filesystems => 'foo' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/is not an Array/)
    end
  end
end
